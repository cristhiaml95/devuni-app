-- =====================================================
-- FUNCIONES RPC CORREGIDAS PARA SUPABASE
-- =====================================================
-- Ejecuta este script en el SQL Editor de Supabase Dashboard
-- REEMPLAZA al script anterior con estas versiones corregidas

-- 1. Función corregida para obtener apps donde el usuario es miembro
CREATE OR REPLACE FUNCTION get_member_apps(user_uuid UUID)
RETURNS TABLE (
  id UUID,
  nombre TEXT,
  descripcion TEXT,
  activa BOOLEAN,
  propietario_id UUID,
  creado_en TIMESTAMP WITH TIME ZONE,
  actualizado_en TIMESTAMP WITH TIME ZONE,
  rol_usuario TEXT,
  fecha_union TIMESTAMP WITH TIME ZONE
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.nombre,
    a.descripcion,
    true as activa, -- apps no tiene columna activa, asumimos true
    a.propietario_id,
    a.creado_en,
    a.actualizado_en,
    m.rol::TEXT as rol_usuario,
    m.anadido_en as fecha_union
  FROM apps a
  INNER JOIN app_miembros m ON a.id = m.app_id
  WHERE m.user_id = user_uuid
  ORDER BY a.nombre;
END;
$$;

-- 2. Función para obtener apps del usuario (alias para compatibilidad)
CREATE OR REPLACE FUNCTION get_user_apps(user_uuid UUID)
RETURNS TABLE (
  id UUID,
  nombre TEXT,
  descripcion TEXT,
  activa BOOLEAN,
  propietario_id UUID,
  creado_en TIMESTAMP WITH TIME ZONE,
  actualizado_en TIMESTAMP WITH TIME ZONE,
  rol_usuario TEXT,
  fecha_union TIMESTAMP WITH TIME ZONE
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY SELECT * FROM get_member_apps(user_uuid);
END;
$$;

-- 3. Función corregida para crear app y membresía
CREATE OR REPLACE FUNCTION create_app_and_membership(
  user_uuid UUID,
  app_name TEXT,
  app_description TEXT DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  nombre TEXT,
  descripcion TEXT,
  activa BOOLEAN,
  propietario_id UUID,
  creado_en TIMESTAMP WITH TIME ZONE,
  actualizado_en TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  new_app_id UUID;
BEGIN
  -- Crear la app
  INSERT INTO apps (nombre, descripcion, propietario_id)
  VALUES (app_name, app_description, user_uuid)
  RETURNING apps.id INTO new_app_id;
  
  -- Crear la membresía del propietario
  INSERT INTO app_miembros (app_id, user_id, rol, anadido_por)
  VALUES (new_app_id, user_uuid, 'propietario', user_uuid);
  
  -- Retornar la app creada
  RETURN QUERY
  SELECT 
    a.id,
    a.nombre,
    a.descripcion,
    true as activa, -- apps no tiene columna activa, asumimos true
    a.propietario_id,
    a.creado_en,
    a.actualizado_en
  FROM apps a
  WHERE a.id = new_app_id;
END;
$$;

-- 4. Verificar que las funciones fueron creadas correctamente
SELECT 
  proname as function_name,
  proargnames as argument_names
FROM pg_proc 
WHERE proname IN ('get_member_apps', 'get_user_apps', 'create_app_and_membership')
ORDER BY proname;

-- 5. Probar la creación de una app de prueba (opcional)
-- SELECT * FROM create_app_and_membership(
--   auth.uid(), 
--   'Mi App de Prueba', 
--   'Descripción de prueba'
-- );

-- =====================================================
-- CAMBIOS PRINCIPALES:
-- =====================================================
-- - Corregido: app_members → app_miembros  
-- - Corregido: usuario_id → user_id
-- - Corregido: invitado_por → anadido_por
-- - Corregido: 'owner' → 'propietario'
-- - Agregado: activa = true (la tabla apps no tiene esta columna)
-- =====================================================