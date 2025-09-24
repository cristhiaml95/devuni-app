-- =========================================
-- TABLA APPS (ESPACIOS DE TRABAJO)
-- Sistema multi-tenant para organizar inventarios
-- =========================================

-- Crear tabla apps
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

-- =========================================
-- TABLA APP_MEMBERS (MIEMBROS DE APPS)
-- Gestión de roles y permisos por App
-- =========================================

-- Crear enum para roles
CREATE TYPE app_member_role AS ENUM ('owner', 'admin', 'editor', 'viewer');

-- Tabla de miembros
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

-- =========================================
-- ÍNDICES PARA PERFORMANCE
-- =========================================

-- Apps
CREATE INDEX idx_apps_owner ON apps(owner_id);
CREATE INDEX idx_apps_slug ON apps(slug);
CREATE INDEX idx_apps_active ON apps(is_active) WHERE is_active = true;

-- App Members
CREATE INDEX idx_app_members_app ON app_members(app_id);
CREATE INDEX idx_app_members_user ON app_members(user_id);
CREATE INDEX idx_app_members_role ON app_members(role);
CREATE INDEX idx_app_members_active ON app_members(is_active) WHERE is_active = true;

-- =========================================
-- TRIGGERS PARA ACTUALIZACIÓN AUTOMÁTICA
-- =========================================

-- Trigger para updated_at en apps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_apps_updated_at 
    BEFORE UPDATE ON apps 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- =========================================
-- FUNCIÓN PARA GENERAR SLUG AUTOMÁTICO
-- =========================================

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

-- =========================================
-- TRIGGER PARA AUTO-GENERAR SLUG
-- =========================================

CREATE OR REPLACE FUNCTION set_app_slug()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.slug IS NULL OR NEW.slug = '' THEN
        NEW.slug := generate_app_slug(NEW.name);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_app_slug
    BEFORE INSERT ON apps
    FOR EACH ROW
    EXECUTE FUNCTION set_app_slug();

-- =========================================
-- TRIGGER PARA AUTO-AÑADIR OWNER COMO MEMBER
-- =========================================

CREATE OR REPLACE FUNCTION add_owner_as_member()
RETURNS TRIGGER AS $$
BEGIN
    -- Añadir owner como member con rol owner
    INSERT INTO app_members (app_id, user_id, role, invited_by)
    VALUES (NEW.id, NEW.owner_id, 'owner', NEW.owner_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_add_owner_as_member
    AFTER INSERT ON apps
    FOR EACH ROW
    EXECUTE FUNCTION add_owner_as_member();

-- =========================================
-- RLS (ROW LEVEL SECURITY)
-- =========================================

-- Habilitar RLS
ALTER TABLE apps ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_members ENABLE ROW LEVEL SECURITY;

-- Políticas para apps
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

-- Políticas para app_members
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

-- =========================================
-- FUNCIONES RPC PARA LA APP
-- =========================================

-- Obtener apps del usuario (como owner)
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

-- Obtener apps donde el usuario es miembro (no owner)
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

-- Crear nueva app
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
-- DATOS DE PRUEBA (OPCIONAL)
-- =========================================

-- Comentar estas líneas en producción
/*
-- Insertar app de ejemplo (requiere un usuario existente)
-- INSERT INTO apps (name, description, owner_id) 
-- VALUES ('Mi Inventario', 'App de prueba para gestión de inventarios', '00000000-0000-0000-0000-000000000000');
*/