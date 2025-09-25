-- Script para verificar el schema actual de la base de datos
-- Ejecutar este script en el SQL Editor de Supabase Dashboard

-- 1. Listar todas las tablas en el schema public
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2. Verificar estructura de tabla apps (si existe)
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'apps'
ORDER BY ordinal_position;

-- 3. Verificar estructura de tabla app_members (si existe)
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'app_members'
ORDER BY ordinal_position;

-- 4. Verificar políticas RLS existentes
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 5. Verificar si RLS está habilitado en las tablas
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- 6. Verificar funciones y triggers relacionados
SELECT 
    routine_name,
    routine_type,
    specific_name
FROM information_schema.routines 
WHERE routine_schema = 'public'
  AND routine_name LIKE '%app%'
ORDER BY routine_name;

-- 7. Verificar triggers
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers 
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;