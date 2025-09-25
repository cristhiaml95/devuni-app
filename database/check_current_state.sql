-- =========================================
-- SCRIPT DE VERIFICACIÓN DE ESTADO ACTUAL
-- Solo lectura - no modifica nada
-- =========================================

-- Verificar tablas existentes
SELECT 
    'TABLAS' as categoria,
    table_name as nombre,
    CASE 
        WHEN table_name = 'apps' THEN '✓ Tabla principal de espacios de trabajo'
        WHEN table_name = 'app_members' THEN '✓ Tabla de miembros y roles'
        ELSE '? Tabla desconocida'
    END as descripcion
FROM information_schema.tables 
WHERE table_name IN ('apps', 'app_members')
ORDER BY table_name;

-- Verificar ENUMs
SELECT 
    'ENUMS' as categoria,
    typname as nombre,
    CASE 
        WHEN typname = 'app_member_role' THEN '✓ Roles de miembros (owner, admin, editor, viewer)'
        ELSE '? ENUM desconocido'
    END as descripcion
FROM pg_type 
WHERE typname IN ('app_member_role')
ORDER BY typname;

-- Verificar funciones RPC
SELECT 
    'FUNCIONES RPC' as categoria,
    proname as nombre,
    CASE 
        WHEN proname = 'get_user_apps' THEN '✓ Obtener apps donde es owner'
        WHEN proname = 'get_member_apps' THEN '✓ Obtener apps donde es miembro'
        WHEN proname = 'create_app' THEN '✓ Crear nueva app'
        ELSE '? Función desconocida'
    END as descripcion
FROM pg_proc 
WHERE proname IN ('get_user_apps', 'get_member_apps', 'create_app')
ORDER BY proname;

-- Verificar triggers
SELECT 
    'TRIGGERS' as categoria,
    tgname as nombre,
    CASE 
        WHEN tgname = 'update_apps_updated_at' THEN '✓ Auto-actualizar updated_at'
        WHEN tgname = 'trigger_set_app_slug' THEN '✓ Auto-generar slug'
        WHEN tgname = 'trigger_add_owner_as_member' THEN '✓ Auto-añadir owner como member'
        ELSE '? Trigger desconocido'
    END as descripcion
FROM pg_trigger 
WHERE tgname IN ('update_apps_updated_at', 'trigger_set_app_slug', 'trigger_add_owner_as_member')
ORDER BY tgname;

-- Verificar políticas RLS
SELECT 
    'POLÍTICAS RLS' as categoria,
    tablename || '.' || policyname as nombre,
    CASE 
        WHEN policyname LIKE '%view%' THEN '✓ Política de lectura'
        WHEN policyname LIKE '%create%' THEN '✓ Política de creación'
        WHEN policyname LIKE '%update%' THEN '✓ Política de actualización'
        WHEN policyname LIKE '%delete%' THEN '✓ Política de eliminación'
        WHEN policyname LIKE '%manage%' THEN '✓ Política de gestión'
        ELSE '? Política desconocida'
    END as descripcion
FROM pg_policies 
WHERE tablename IN ('apps', 'app_members')
ORDER BY tablename, policyname;

-- Verificar si RLS está habilitado
SELECT 
    'RLS STATUS' as categoria,
    tablename as nombre,
    CASE 
        WHEN rowsecurity THEN '✓ RLS habilitado'
        ELSE '✗ RLS deshabilitado'
    END as descripcion
FROM pg_tables 
WHERE tablename IN ('apps', 'app_members')
ORDER BY tablename;

-- Contar registros existentes (si las tablas existen)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'apps') THEN
        RAISE NOTICE 'APPS: % registros existentes', (SELECT COUNT(*) FROM apps);
    ELSE
        RAISE NOTICE 'APPS: Tabla no existe';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'app_members') THEN
        RAISE NOTICE 'APP_MEMBERS: % registros existentes', (SELECT COUNT(*) FROM app_members);
    ELSE
        RAISE NOTICE 'APP_MEMBERS: Tabla no existe';
    END IF;
END
$$;