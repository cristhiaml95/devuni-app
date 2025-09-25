-- Migration incremental para el sistema multi-tenant
-- EJECUTAR SOLO DESPUÉS DE VERIFICAR EL SCHEMA ACTUAL
-- ===================================================

-- PASO 1: Verificar que no existan las tablas antes de crearlas
-- (Ejecutar verify_current_schema.sql primero)

-- PASO 2: Crear tabla apps (si no existe)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'apps'
    ) THEN
        CREATE TABLE public.apps (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            name TEXT NOT NULL CHECK (length(name) >= 1 AND length(name) <= 100),
            description TEXT,
            owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
            created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
            updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
            
            -- Índices para optimización
            CONSTRAINT apps_name_owner_unique UNIQUE (name, owner_id)
        );
        
        -- Índices adicionales
        CREATE INDEX IF NOT EXISTS idx_apps_owner_id ON public.apps(owner_id);
        CREATE INDEX IF NOT EXISTS idx_apps_created_at ON public.apps(created_at);
        
        RAISE NOTICE 'Tabla apps creada exitosamente';
    ELSE
        RAISE NOTICE 'Tabla apps ya existe - omitiendo creación';
    END IF;
END $$;

-- PASO 3: Crear tabla app_members (si no existe)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'app_members'
    ) THEN
        CREATE TABLE public.app_members (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            app_id UUID REFERENCES public.apps(id) ON DELETE CASCADE NOT NULL,
            user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
            role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
            permissions JSONB DEFAULT '[]'::jsonb,
            invited_by UUID REFERENCES auth.users(id),
            invited_at TIMESTAMPTZ DEFAULT now() NOT NULL,
            joined_at TIMESTAMPTZ,
            
            -- Constraints
            CONSTRAINT app_members_app_user_unique UNIQUE (app_id, user_id)
        );
        
        -- Índices adicionales
        CREATE INDEX IF NOT EXISTS idx_app_members_app_id ON public.app_members(app_id);
        CREATE INDEX IF NOT EXISTS idx_app_members_user_id ON public.app_members(user_id);
        CREATE INDEX IF NOT EXISTS idx_app_members_role ON public.app_members(role);
        
        RAISE NOTICE 'Tabla app_members creada exitosamente';
    ELSE
        RAISE NOTICE 'Tabla app_members ya existe - omitiendo creación';
    END IF;
END $$;

-- PASO 4: Crear función para actualizar updated_at (si no existe)
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- PASO 5: Crear trigger para updated_at en apps (si no existe)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers 
        WHERE trigger_name = 'apps_updated_at' 
        AND event_object_table = 'apps'
    ) THEN
        CREATE TRIGGER apps_updated_at
            BEFORE UPDATE ON public.apps
            FOR EACH ROW
            EXECUTE FUNCTION public.handle_updated_at();
        RAISE NOTICE 'Trigger apps_updated_at creado exitosamente';
    ELSE
        RAISE NOTICE 'Trigger apps_updated_at ya existe - omitiendo creación';
    END IF;
END $$;

-- PASO 6: Habilitar RLS en apps (si no está habilitado)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename = 'apps' 
        AND rowsecurity = true
    ) THEN
        ALTER TABLE public.apps ENABLE ROW LEVEL SECURITY;
        RAISE NOTICE 'RLS habilitado en tabla apps';
    ELSE
        RAISE NOTICE 'RLS ya está habilitado en tabla apps';
    END IF;
END $$;

-- PASO 7: Habilitar RLS en app_members (si no está habilitado)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename = 'app_members' 
        AND rowsecurity = true
    ) THEN
        ALTER TABLE public.app_members ENABLE ROW LEVEL SECURITY;
        RAISE NOTICE 'RLS habilitado en tabla app_members';
    ELSE
        RAISE NOTICE 'RLS ya está habilitado en tabla app_members';
    END IF;
END $$;

-- PASO 8: Crear políticas RLS para apps (si no existen)
DO $$
BEGIN
    -- Política de SELECT para apps
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'apps' 
        AND policyname = 'Users can read apps they own or are members of'
    ) THEN
        CREATE POLICY "Users can read apps they own or are members of"
        ON public.apps FOR SELECT
        TO authenticated
        USING (
            owner_id = (SELECT auth.uid())
            OR
            id IN (
                SELECT app_id FROM public.app_members 
                WHERE user_id = (SELECT auth.uid())
            )
        );
        RAISE NOTICE 'Política SELECT para apps creada';
    END IF;

    -- Política de INSERT para apps
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'apps' 
        AND policyname = 'Users can create their own apps'
    ) THEN
        CREATE POLICY "Users can create their own apps"
        ON public.apps FOR INSERT
        TO authenticated
        WITH CHECK (owner_id = (SELECT auth.uid()));
        RAISE NOTICE 'Política INSERT para apps creada';
    END IF;

    -- Política de UPDATE para apps
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'apps' 
        AND policyname = 'App owners can update their apps'
    ) THEN
        CREATE POLICY "App owners can update their apps"
        ON public.apps FOR UPDATE
        TO authenticated
        USING (owner_id = (SELECT auth.uid()))
        WITH CHECK (owner_id = (SELECT auth.uid()));
        RAISE NOTICE 'Política UPDATE para apps creada';
    END IF;

    -- Política de DELETE para apps
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'apps' 
        AND policyname = 'App owners can delete their apps'
    ) THEN
        CREATE POLICY "App owners can delete their apps"
        ON public.apps FOR DELETE
        TO authenticated
        USING (owner_id = (SELECT auth.uid()));
        RAISE NOTICE 'Política DELETE para apps creada';
    END IF;
END $$;

-- PASO 9: Crear políticas RLS para app_members (si no existen)
DO $$
BEGIN
    -- Política de SELECT para app_members
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'app_members' 
        AND policyname = 'Users can read app memberships they are part of'
    ) THEN
        CREATE POLICY "Users can read app memberships they are part of"
        ON public.app_members FOR SELECT
        TO authenticated
        USING (
            user_id = (SELECT auth.uid())
            OR
            app_id IN (
                SELECT id FROM public.apps 
                WHERE owner_id = (SELECT auth.uid())
            )
            OR
            app_id IN (
                SELECT app_id FROM public.app_members 
                WHERE user_id = (SELECT auth.uid()) 
                AND role IN ('owner', 'admin')
            )
        );
        RAISE NOTICE 'Política SELECT para app_members creada';
    END IF;

    -- Política de INSERT para app_members
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'app_members' 
        AND policyname = 'App owners and admins can add members'
    ) THEN
        CREATE POLICY "App owners and admins can add members"
        ON public.app_members FOR INSERT
        TO authenticated
        WITH CHECK (
            app_id IN (
                SELECT id FROM public.apps 
                WHERE owner_id = (SELECT auth.uid())
            )
            OR
            app_id IN (
                SELECT app_id FROM public.app_members 
                WHERE user_id = (SELECT auth.uid()) 
                AND role IN ('owner', 'admin')
            )
        );
        RAISE NOTICE 'Política INSERT para app_members creada';
    END IF;

    -- Política de UPDATE para app_members
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'app_members' 
        AND policyname = 'App owners and admins can update memberships'
    ) THEN
        CREATE POLICY "App owners and admins can update memberships"
        ON public.app_members FOR UPDATE
        TO authenticated
        USING (
            app_id IN (
                SELECT id FROM public.apps 
                WHERE owner_id = (SELECT auth.uid())
            )
            OR
            app_id IN (
                SELECT app_id FROM public.app_members 
                WHERE user_id = (SELECT auth.uid()) 
                AND role IN ('owner', 'admin')
            )
        )
        WITH CHECK (
            app_id IN (
                SELECT id FROM public.apps 
                WHERE owner_id = (SELECT auth.uid())
            )
            OR
            app_id IN (
                SELECT app_id FROM public.app_members 
                WHERE user_id = (SELECT auth.uid()) 
                AND role IN ('owner', 'admin')
            )
        );
        RAISE NOTICE 'Política UPDATE para app_members creada';
    END IF;

    -- Política de DELETE para app_members
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'app_members' 
        AND policyname = 'App owners and admins can remove members'
    ) THEN
        CREATE POLICY "App owners and admins can remove members"
        ON public.app_members FOR DELETE
        TO authenticated
        USING (
            app_id IN (
                SELECT id FROM public.apps 
                WHERE owner_id = (SELECT auth.uid())
            )
            OR
            app_id IN (
                SELECT app_id FROM public.app_members 
                WHERE user_id = (SELECT auth.uid()) 
                AND role IN ('owner', 'admin')
            )
            OR
            user_id = (SELECT auth.uid()) -- Users can remove themselves
        );
        RAISE NOTICE 'Política DELETE para app_members creada';
    END IF;
END $$;

-- PASO 10: Crear función helper para obtener apps del usuario
CREATE OR REPLACE FUNCTION public.get_user_apps(target_user_id UUID DEFAULT NULL)
RETURNS TABLE (
    app_id UUID,
    app_name TEXT,
    app_description TEXT,
    user_role TEXT,
    is_owner BOOLEAN,
    member_count BIGINT
) AS $$
DECLARE
    current_user_id UUID;
BEGIN
    -- Usar el user_id pasado como parámetro o el usuario actual
    current_user_id := COALESCE(target_user_id, auth.uid());
    
    RETURN QUERY
    SELECT 
        a.id as app_id,
        a.name as app_name,
        a.description as app_description,
        COALESCE(am.role, 'owner') as user_role,
        (a.owner_id = current_user_id) as is_owner,
        (
            SELECT COUNT(*)::BIGINT 
            FROM public.app_members am2 
            WHERE am2.app_id = a.id
        ) + 1 as member_count -- +1 for the owner
    FROM public.apps a
    LEFT JOIN public.app_members am ON am.app_id = a.id AND am.user_id = current_user_id
    WHERE 
        a.owner_id = current_user_id  -- Apps owned by user
        OR 
        am.user_id = current_user_id  -- Apps where user is a member
    ORDER BY a.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- PASO 11: Crear datos de prueba (opcional - comentar en producción)
/*
DO $$
DECLARE 
    test_app_id UUID;
    current_user_id UUID;
BEGIN
    -- Solo crear datos de prueba si no existen apps
    IF NOT EXISTS (SELECT 1 FROM public.apps LIMIT 1) THEN
        current_user_id := auth.uid();
        
        IF current_user_id IS NOT NULL THEN
            -- Crear app de prueba
            INSERT INTO public.apps (name, description, owner_id)
            VALUES ('Mi Primera App', 'App de prueba para desarrollo', current_user_id)
            RETURNING id INTO test_app_id;
            
            RAISE NOTICE 'App de prueba creada: %', test_app_id;
        ELSE
            RAISE NOTICE 'No hay usuario autenticado - omitiendo datos de prueba';
        END IF;
    ELSE
        RAISE NOTICE 'Ya existen apps - omitiendo datos de prueba';
    END IF;
END $$;
*/

-- PASO 12: Verificación final
SELECT 
    'Migration completada exitosamente' as status,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('apps', 'app_members')) as tables_created,
    (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public' AND tablename IN ('apps', 'app_members')) as policies_created,
    (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name IN ('handle_updated_at', 'get_user_apps')) as functions_created;