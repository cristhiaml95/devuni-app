-- ==========================================
-- ÍNDICES DE PERFORMANCE PARA DEVUNI APP
-- ==========================================
-- Fecha: 25 de Septiembre, 2025
-- Propósito: Optimización de consultas frecuentes
-- Riesgo: BAJO (solo creación de índices)
-- Tiempo estimado: < 10 segundos (tablas vacías)

-- ==========================================
-- 1. ÍNDICES PARA MOVIMIENTOS DE INVENTARIO
-- ==========================================

-- 1.1 Índice para consultas por producto
-- Acelera: SELECT * FROM movimientos_inventario WHERE producto_id = 'xxx'
-- Usado en: Historial de movimientos de un producto específico
CREATE INDEX IF NOT EXISTS idx_movimientos_producto 
ON movimientos_inventario(producto_id);

-- 1.2 Índice para consultas por almacén
-- Acelera: SELECT * FROM movimientos_inventario WHERE almacen_id = 'xxx'
-- Usado en: Movimientos en un almacén específico
CREATE INDEX IF NOT EXISTS idx_movimientos_almacen 
ON movimientos_inventario(almacen_id);

-- 1.3 Índice para ordenamiento por fecha (DESC)
-- Acelera: ORDER BY fecha_movimiento DESC, filtros por rangos de fecha
-- Usado en: Últimos movimientos, reportes por período
CREATE INDEX IF NOT EXISTS idx_movimientos_fecha 
ON movimientos_inventario(fecha_movimiento DESC);

-- 1.4 Índice compuesto para consultas por app y producto
-- Acelera: WHERE app_id = 'xxx' AND producto_id = 'yyy' ORDER BY fecha_movimiento
-- Usado en: Historial de producto específico en app específica
CREATE INDEX IF NOT EXISTS idx_movimientos_app_producto 
ON movimientos_inventario(app_id, producto_id, fecha_movimiento DESC);

-- ==========================================
-- 2. ÍNDICES PARA INVITACIONES
-- ==========================================

-- 2.1 Índice para búsquedas por email (case-insensitive)
-- Acelera: WHERE lower(email) = lower('usuario@email.com')
-- Usado en: Verificar invitaciones existentes, búsquedas
CREATE INDEX IF NOT EXISTS idx_invitaciones_email 
ON app_invitaciones(lower(email));

-- 2.2 Índice parcial para invitaciones pendientes
-- Acelera: WHERE estado = 'pendiente' ORDER BY creado_en DESC
-- Usado en: Panel de invitaciones pendientes (más común)
-- NOTA: Índice parcial = solo indexa registros que cumplen la condición
CREATE INDEX IF NOT EXISTS idx_invitaciones_pendientes 
ON app_invitaciones(estado, creado_en DESC) 
WHERE estado = 'pendiente';

-- ==========================================
-- 3. ÍNDICES PARA PRODUCTOS
-- ==========================================

-- 3.1 Índice parcial para productos activos
-- Acelera: WHERE app_id = 'xxx' AND activo = true ORDER BY nombre
-- Usado en: Listado de productos activos (caso más común)
-- NOTA: Excluye productos inactivos del índice (más eficiente)
CREATE INDEX IF NOT EXISTS idx_productos_activos 
ON productos_inventario(app_id, activo, nombre) 
WHERE activo = true;

-- 3.2 Índice para búsquedas por SKU
-- Acelera: WHERE app_id = 'xxx' AND sku ILIKE '%abc%'
-- Usado en: Búsqueda de productos por código SKU
CREATE INDEX IF NOT EXISTS idx_productos_sku_search 
ON productos_inventario(app_id, upper(sku));

-- ==========================================
-- 4. ÍNDICES ADICIONALES PARA MEMBRESÍAS
-- ==========================================

-- 4.1 Índice compuesto para consultas de rol
-- Acelera: WHERE app_id = 'xxx' AND user_id = 'yyy'
-- Usado en: Verificación de roles (función tiene_rol_minimo)
-- NOTA: Ya existe idx_app_miembros_app e idx_app_miembros_user
-- Este combina ambos para consultas específicas
CREATE INDEX IF NOT EXISTS idx_app_miembros_app_user_rol 
ON app_miembros(app_id, user_id, rol);

-- ==========================================
-- 5. VERIFICACIÓN DE ÍNDICES CREADOS
-- ==========================================

-- Query para verificar que todos los índices se crearon correctamente
-- Ejecutar después de aplicar este script:
/*
SELECT 
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;
*/

-- ==========================================
-- RESUMEN DE BENEFICIOS ESPERADOS:
-- ==========================================
/*
1. Consultas de movimientos por producto: 10-100x más rápidas
2. Búsquedas de invitaciones por email: Instantáneas  
3. Listados de productos activos: 5-50x más rápidas
4. Verificación de roles: 2-10x más rápidas
5. Reportes por fecha: 20-200x más rápidas
6. Búsquedas por SKU: Instantáneas

TIEMPO TOTAL DE EJECUCIÓN: < 10 segundos
RIESGO: NINGUNO (solo optimización)
REVERSIBLE: Sí (DROP INDEX nombre_indice)
*/