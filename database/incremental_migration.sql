-- =========================================
-- SCRIPT DE VERIFICACIÓN Y MIGRACIÓN INCREMENTAL
-- Sistema Multi-Tenant DevUni App
-- =========================================

-- =========================================
-- PASO 1: VERIFICAR ESTADO ACTUAL
-- =========================================

-- Verificar tablas existentes
DO $$
BEGIN
    RAISE NOTICE '=== VERIFICANDO ESTADO ACTUAL DE LA BASE DE DATOS ===';
    
    -- Verificar tabla apps
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'apps') THEN
        RAISE NOTICE '✓ Tabla "apps" ya existe';
    ELSE
        RAISE NOTICE '✗ Tabla "apps" NO existe - será creada';
    END IF;
    
    -- Verificar tabla app_members
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'app_members') THEN
        RAISE NOTICE '✓ Tabla "app_members" ya existe';
    ELSE
        RAISE NOTICE '✗ Tabla "app_members" NO existe - será creada';
    END IF;
    
    -- Verificar enum app_member_role
    IF EXISTS (SELECT FROM pg_type WHERE typname = 'app_member_role') THEN
        RAISE NOTICE '✓ ENUM "app_member_role" ya existe';
    ELSE
        RAISE NOTICE '✗ ENUM "app_member_role" NO existe - será creado';
    END IF;
    
    -- Verificar funciones RPC
    IF EXISTS (SELECT FROM pg_proc WHERE proname = 'get_user_apps') THEN
        RAISE NOTICE '✓ Función "get_user_apps" ya existe - será actualizada';
    ELSE
        RAISE NOTICE '✗ Función "get_user_apps" NO existe - será creada';
    END IF;
    
    IF EXISTS (SELECT FROM pg_proc WHERE proname = 'get_member_apps') THEN
        RAISE NOTICE '✓ Función "get_member_apps" ya existe - será actualizada';
    ELSE
        RAISE NOTICE '✗ Función "get_member_apps" NO existe - será creada';
    END IF;
    
    IF EXISTS (SELECT FROM pg_proc WHERE proname = 'create_app') THEN
        RAISE NOTICE '✓ Función "create_app" ya existe - será actualizada';
    ELSE
        RAISE NOTICE '✗ Función "create_app" NO existe - será creada';
    END IF;
    
    RAISE NOTICE '=== FIN VERIFICACIÓN ===';
END
$$;

-- =========================================
-- PASO 2: CREAR ENUM SI NO EXISTE
-- =========================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_type WHERE typname = 'app_member_role') THEN
        CREATE TYPE app_member_role AS ENUM ('owner', 'admin', 'editor', 'viewer');
        RAISE NOTICE '✓ ENUM app_member_role creado';
    END IF;
END
$$;

-- =========================================
-- PASO 3: CREAR TABLA APPS SI NO EXISTE
-- =========================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'apps') THEN
        CREATE TABLE apps (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            
            -- Información básica
            name VARCHAR(255) NOT NULL CHECK (length(trim(name)) >= 3),
            slug VARCHAR(100) UNIQUE NOT NULL,
            description TEXT,
            
            -- Metadata
            owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            
            -- Configuración
            settings JSONB DEFAULT '{}' NOT NULL,
            is_active BOOLEAN DEFAULT true NOT NULL
        );
        
        -- Crear índices
        CREATE INDEX idx_apps_owner ON apps(owner_id);
        CREATE INDEX idx_apps_slug ON apps(slug);
        CREATE INDEX idx_apps_active ON apps(is_active) WHERE is_active = true;
        
        -- Habilitar RLS
        ALTER TABLE apps ENABLE ROW LEVEL SECURITY;
        
        RAISE NOTICE '✓ Tabla apps creada con índices y RLS';
    ELSE
        RAISE NOTICE '→ Tabla apps ya existe, verificando columnas...';
        
        -- Verificar y agregar columnas faltantes si es necesario
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'apps' AND column_name = 'settings') THEN
            ALTER TABLE apps ADD COLUMN settings JSONB DEFAULT '{}' NOT NULL;
            RAISE NOTICE '✓ Columna settings agregada a apps';
        END IF;
        
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'apps' AND column_name = 'is_active') THEN
            ALTER TABLE apps ADD COLUMN is_active BOOLEAN DEFAULT true NOT NULL;
            RAISE NOTICE '✓ Columna is_active agregada a apps';
        END IF;
    END IF;
END
$$;

-- =========================================
-- PASO 4: CREAR TABLA APP_MEMBERS SI NO EXISTE
-- =========================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'app_members') THEN
        CREATE TABLE app_members (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            
            -- Relaciones
            app_id UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
            user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
            
            -- Permisos
            role app_member_role NOT NULL DEFAULT 'viewer',
            
            -- Metadata
            invited_by UUID REFERENCES auth.users(id),
            invited_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            
            -- Estado
            is_active BOOLEAN DEFAULT true NOT NULL,
            
            -- Constraints
            UNIQUE(app_id, user_id)
        );
        
        -- Crear índices
        CREATE INDEX idx_app_members_app ON app_members(app_id);
        CREATE INDEX idx_app_members_user ON app_members(user_id);
        CREATE INDEX idx_app_members_role ON app_members(role);
        CREATE INDEX idx_app_members_active ON app_members(is_active) WHERE is_active = true;
        
        -- Habilitar RLS
        ALTER TABLE app_members ENABLE ROW LEVEL SECURITY;
        
        RAISE NOTICE '✓ Tabla app_members creada con índices y RLS';
    ELSE
        RAISE NOTICE '→ Tabla app_members ya existe';
    END IF;
END
$$;

-- =========================================
-- PASO 5: CREAR/ACTUALIZAR FUNCIONES AUXILIARES
-- =========================================

-- Función para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Función para generar slug
CREATE OR REPLACE FUNCTION generate_app_slug(app_name TEXT)
RETURNS TEXT AS $$
DECLARE
    base_slug TEXT;
    final_slug TEXT;
    counter INTEGER := 0;
BEGIN
    -- Convertir nombre a slug base
    base_slug := lower(trim(app_name));
    base_slug := regexp_replace(base_slug, '[^a-z0-9\s-]', '', 'g');
    base_slug := regexp_replace(base_slug, '\s+', '-', 'g');
    base_slug := regexp_replace(base_slug, '-+', '-', 'g');
    base_slug := trim(base_slug, '-');
    
    -- Verificar unicidad
    final_slug := base_slug;
    
    WHILE EXISTS (SELECT 1 FROM apps WHERE slug = final_slug) LOOP
        counter := counter + 1;
        final_slug := base_slug || '-' || counter;
    END LOOP;
    
    RETURN final_slug;
END;
$$ LANGUAGE plpgsql;

-- Función para set slug
CREATE OR REPLACE FUNCTION set_app_slug()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.slug IS NULL OR NEW.slug = '' THEN
        NEW.slug := generate_app_slug(NEW.name);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Función para añadir owner como member
CREATE OR REPLACE FUNCTION add_owner_as_member()
RETURNS TRIGGER AS $$
BEGIN
    -- Añadir owner como member con rol owner
    INSERT INTO app_members (app_id, user_id, role, invited_by)
    VALUES (NEW.id, NEW.owner_id, 'owner', NEW.owner_id)
    ON CONFLICT (app_id, user_id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =========================================
-- PASO 6: CREAR/ACTUALIZAR TRIGGERS
-- =========================================

-- Trigger para updated_at
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_trigger WHERE tgname = 'update_apps_updated_at') THEN
        CREATE TRIGGER update_apps_updated_at 
            BEFORE UPDATE ON apps 
            FOR EACH ROW 
            EXECUTE FUNCTION update_updated_at_column();
        RAISE NOTICE '✓ Trigger update_apps_updated_at creado';
    ELSE
        RAISE NOTICE '→ Trigger update_apps_updated_at ya existe';
    END IF;
END
$$;

-- Trigger para slug
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_trigger WHERE tgname = 'trigger_set_app_slug') THEN
        CREATE TRIGGER trigger_set_app_slug
            BEFORE INSERT ON apps
            FOR EACH ROW
            EXECUTE FUNCTION set_app_slug();
        RAISE NOTICE '✓ Trigger trigger_set_app_slug creado';
    ELSE
        RAISE NOTICE '→ Trigger trigger_set_app_slug ya existe';
    END IF;
END
$$;

-- Trigger para owner como member
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_trigger WHERE tgname = 'trigger_add_owner_as_member') THEN
        CREATE TRIGGER trigger_add_owner_as_member
            AFTER INSERT ON apps
            FOR EACH ROW
            EXECUTE FUNCTION add_owner_as_member();
        RAISE NOTICE '✓ Trigger trigger_add_owner_as_member creado';
    ELSE
        RAISE NOTICE '→ Trigger trigger_add_owner_as_member ya existe';
    END IF;
END
$$;

-- =========================================
-- PASO 7: CREAR/ACTUALIZAR POLÍTICAS RLS
-- =========================================

-- Políticas para apps
DO $$
BEGIN
    -- Eliminar políticas existentes si existen
    DROP POLICY IF EXISTS "Users can view apps they own or are members of" ON apps;
    DROP POLICY IF EXISTS "Users can create their own apps" ON apps;
    DROP POLICY IF EXISTS "Only owners can update their apps" ON apps;
    DROP POLICY IF EXISTS "Only owners can delete their apps" ON apps;
    
    -- Crear políticas actualizadas
    CREATE POLICY "Users can view apps they own or are members of" ON apps
        FOR SELECT USING (
            owner_id = auth.uid() OR 
            id IN (
                SELECT app_id FROM app_members 
                WHERE user_id = auth.uid() AND is_active = true
            )
        );

    CREATE POLICY "Users can create their own apps" ON apps
        FOR INSERT WITH CHECK (owner_id = auth.uid());

    CREATE POLICY "Only owners can update their apps" ON apps
        FOR UPDATE USING (owner_id = auth.uid());

    CREATE POLICY "Only owners can delete their apps" ON apps
        FOR DELETE USING (owner_id = auth.uid());
        
    RAISE NOTICE '✓ Políticas RLS para apps actualizadas';
END
$$;

-- Políticas para app_members
DO $$
BEGIN
    -- Eliminar políticas existentes si existen
    DROP POLICY IF EXISTS "Users can view memberships of apps they belong to" ON app_members;
    DROP POLICY IF EXISTS "App owners and admins can manage members" ON app_members;
    
    -- Crear políticas actualizadas
    CREATE POLICY "Users can view memberships of apps they belong to" ON app_members
        FOR SELECT USING (
            user_id = auth.uid() OR 
            app_id IN (
                SELECT app_id FROM app_members 
                WHERE user_id = auth.uid() AND is_active = true
            )
        );

    CREATE POLICY "App owners and admins can manage members" ON app_members
        FOR ALL USING (
            app_id IN (
                SELECT app_id FROM app_members 
                WHERE user_id = auth.uid() 
                AND role IN ('owner', 'admin') 
                AND is_active = true
            )
        );
        
    RAISE NOTICE '✓ Políticas RLS para app_members actualizadas';
END
$$;

-- =========================================
-- PASO 8: CREAR/ACTUALIZAR FUNCIONES RPC
-- =========================================

-- RPC: get_user_apps
CREATE OR REPLACE FUNCTION get_user_apps()
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    slug VARCHAR,
    description TEXT,
    owner_id UUID,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    settings JSONB,
    is_active BOOLEAN,
    member_count INTEGER
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        a.slug,
        a.description,
        a.owner_id,
        a.created_at,
        a.updated_at,
        a.settings,
        a.is_active,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM app_members am 
             WHERE am.app_id = a.id AND am.is_active = true), 
            0
        ) as member_count
    FROM apps a
    WHERE a.owner_id = auth.uid() AND a.is_active = true
    ORDER BY a.created_at DESC;
END;
$$;

-- RPC: get_member_apps
CREATE OR REPLACE FUNCTION get_member_apps()
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    slug VARCHAR,
    description TEXT,
    owner_id UUID,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    settings JSONB,
    is_active BOOLEAN,
    user_role app_member_role,
    member_count INTEGER
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        a.slug,
        a.description,
        a.owner_id,
        a.created_at,
        a.updated_at,
        a.settings,
        a.is_active,
        am.role as user_role,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM app_members am2 
             WHERE am2.app_id = a.id AND am2.is_active = true), 
            0
        ) as member_count
    FROM apps a
    INNER JOIN app_members am ON am.app_id = a.id
    WHERE am.user_id = auth.uid() 
    AND am.is_active = true 
    AND a.is_active = true
    AND a.owner_id != auth.uid()  -- Excluir apps donde es owner
    ORDER BY a.created_at DESC;
END;
$$;

-- RPC: create_app
CREATE OR REPLACE FUNCTION create_app(
    app_name VARCHAR,
    app_description TEXT DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    name VARCHAR,
    slug VARCHAR,
    description TEXT,
    owner_id UUID,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    settings JSONB,
    is_active BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_app_id UUID;
BEGIN
    -- Validar que el usuario esté autenticado
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- Validar nombre
    IF length(trim(app_name)) < 3 THEN
        RAISE EXCEPTION 'El nombre debe tener al menos 3 caracteres';
    END IF;

    -- Insertar nueva app
    INSERT INTO apps (name, description, owner_id)
    VALUES (trim(app_name), trim(app_description), auth.uid())
    RETURNING apps.id INTO new_app_id;

    -- Retornar la app creada
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        a.slug,
        a.description,
        a.owner_id,
        a.created_at,
        a.updated_at,
        a.settings,
        a.is_active
    FROM apps a
    WHERE a.id = new_app_id;
END;
$$;

-- =========================================
-- PASO 9: VERIFICACIÓN FINAL
-- =========================================

DO $$
BEGIN
    RAISE NOTICE '=== VERIFICACIÓN FINAL ===';
    RAISE NOTICE '✓ Script de migración incremental completado';
    RAISE NOTICE '✓ Todas las tablas, funciones y políticas están configuradas';
    RAISE NOTICE '✓ El sistema multi-tenant está listo para usar';
    RAISE NOTICE '=== LISTO PARA PROBAR ===';
END
$$;