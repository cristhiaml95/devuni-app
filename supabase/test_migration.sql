-- Script de prueba para verificar el funcionamiento del sistema multi-tenant
-- EJECUTAR DESPUÉS de incremental_migration.sql
-- ================================================

-- PASO 1: Verificar que las tablas fueron creadas correctamente
SELECT 
    'Verificación de tablas' as test_step,
    table_name,
    CASE 
        WHEN table_name IS NOT NULL THEN '✅ Existe'
        ELSE '❌ No existe'
    END as status
FROM (VALUES ('apps'), ('app_members')) as expected(table_name)
LEFT JOIN information_schema.tables t ON t.table_name = expected.table_name AND t.table_schema = 'public';

-- PASO 2: Verificar que RLS está habilitado
SELECT 
    'Verificación RLS' as test_step,
    tablename,
    CASE 
        WHEN rowsecurity THEN '✅ RLS habilitado'
        ELSE '❌ RLS deshabilitado'
    END as status
FROM pg_tables 
WHERE schemaname = 'public' AND tablename IN ('apps', 'app_members');

-- PASO 3: Verificar políticas RLS
SELECT 
    'Verificación políticas RLS' as test_step,
    tablename,
    COUNT(*) as policy_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Políticas creadas'
        ELSE '❌ Sin políticas'
    END as status
FROM pg_policies 
WHERE schemaname = 'public' AND tablename IN ('apps', 'app_members')
GROUP BY tablename;

-- PASO 4: Verificar funciones creadas
SELECT 
    'Verificación funciones' as test_step,
    routine_name,
    routine_type,
    CASE 
        WHEN routine_name IS NOT NULL THEN '✅ Función existe'
        ELSE '❌ Función no existe'
    END as status
FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_name IN ('handle_updated_at', 'get_user_apps');

-- PASO 5: Verificar triggers
SELECT 
    'Verificación triggers' as test_step,
    trigger_name,
    event_object_table,
    CASE 
        WHEN trigger_name IS NOT NULL THEN '✅ Trigger existe'
        ELSE '❌ Trigger no existe'
    END as status
FROM information_schema.triggers 
WHERE trigger_schema = 'public' AND trigger_name = 'apps_updated_at';

-- PASO 6: Test de inserción (solo si hay usuario autenticado)
DO $$
DECLARE 
    test_app_id UUID;
    current_user_id UUID;
    test_result TEXT;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NOT NULL THEN
        BEGIN
            -- Intentar crear una app de prueba
            INSERT INTO public.apps (name, description, owner_id)
            VALUES ('Test App ' || extract(epoch from now()), 'App creada por test automático', current_user_id)
            RETURNING id INTO test_app_id;
            
            -- Verificar que se puede leer la app creada
            IF EXISTS (SELECT 1 FROM public.apps WHERE id = test_app_id) THEN
                test_result := '✅ Test CRUD exitoso - App ID: ' || test_app_id::TEXT;
                
                -- Limpiar: eliminar la app de prueba
                DELETE FROM public.apps WHERE id = test_app_id;
            ELSE
                test_result := '❌ Error: No se puede leer la app creada';
            END IF;
            
            RAISE NOTICE '%', test_result;
            
        EXCEPTION WHEN OTHERS THEN
            test_result := '❌ Error en test CRUD: ' || SQLERRM;
            RAISE NOTICE '%', test_result;
        END;
    ELSE
        RAISE NOTICE '⚠️ No hay usuario autenticado - omitiendo test CRUD';
    END IF;
END $$;

-- PASO 7: Test de función get_user_apps
DO $$
DECLARE 
    app_count INTEGER;
    current_user_id UUID;
BEGIN
    current_user_id := auth.uid();
    
    IF current_user_id IS NOT NULL THEN
        SELECT COUNT(*) INTO app_count FROM public.get_user_apps();
        RAISE NOTICE '✅ Función get_user_apps() ejecutada exitosamente. Apps encontradas: %', app_count;
    ELSE
        RAISE NOTICE '⚠️ No hay usuario autenticado - omitiendo test de get_user_apps()';
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Error en función get_user_apps(): %', SQLERRM;
END $$;

-- PASO 8: Resumen final
SELECT 
    'RESUMEN FINAL' as test_step,
    (
        SELECT COUNT(*) 
        FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name IN ('apps', 'app_members')
    ) as tables_ok,
    (
        SELECT COUNT(*) 
        FROM pg_policies 
        WHERE schemaname = 'public' AND tablename IN ('apps', 'app_members')
    ) as policies_ok,
    (
        SELECT COUNT(*) 
        FROM information_schema.routines 
        WHERE routine_schema = 'public' AND routine_name IN ('handle_updated_at', 'get_user_apps')
    ) as functions_ok,
    CASE 
        WHEN (
            SELECT COUNT(*) 
            FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name IN ('apps', 'app_members')
        ) = 2 THEN '✅ Sistema multi-tenant listo'
        ELSE '❌ Faltan componentes'
    END as final_status;