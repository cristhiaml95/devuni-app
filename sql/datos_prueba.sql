-- ============================================
-- DATOS DE PRUEBA PARA DEVUNI APP
-- ============================================
-- Script para crear datos de prueba en Supabase
-- Ejecutar en la consola SQL de Supabase

-- 1. Crear una app de prueba
INSERT INTO apps (id, nombre, descripcion, propietario_id) 
VALUES (
  'demo-app-123',
  'Mi Inventario Demo', 
  'App de demostración para inventario',
  auth.uid()
) ON CONFLICT (id) DO NOTHING;

-- 2. Agregar el usuario actual como propietario de la app
INSERT INTO app_miembros (app_id, user_id, rol, anadido_por) 
VALUES (
  'demo-app-123',
  auth.uid(),
  'propietario',
  auth.uid()
) ON CONFLICT (app_id, user_id) DO NOTHING;

-- 3. Crear unidades de medida básicas
INSERT INTO unidades_medida (id, app_id, codigo, nombre, descripcion) VALUES
  ('unidad-piezas-123', 'demo-app-123', 'PZA', 'Piezas', 'Unidades individuales'),
  ('unidad-kg-123', 'demo-app-123', 'KG', 'Kilogramos', 'Peso en kilogramos'),
  ('unidad-litros-123', 'demo-app-123', 'LT', 'Litros', 'Volumen en litros'),
  ('unidad-metros-123', 'demo-app-123', 'M', 'Metros', 'Longitud en metros')
ON CONFLICT (id) DO NOTHING;

-- 4. Crear categorías de inventario
INSERT INTO categorias_inventario (id, app_id, nombre, descripcion) VALUES
  ('cat-electronica-123', 'demo-app-123', 'Electrónicos', 'productos electrónicos y tecnológicos'),
  ('cat-hogar-123', 'demo-app-123', 'Hogar', 'Artículos para el hogar y oficina'),
  ('cat-herramientas-123', 'demo-app-123', 'Herramientas', 'Herramientas y equipos de trabajo'),
  ('cat-alimentos-123', 'demo-app-123', 'Alimentos', 'Productos alimenticios y bebidas')
ON CONFLICT (id) DO NOTHING;

-- 5. Crear almacén principal
INSERT INTO almacenes (id, app_id, nombre, direccion, notas) VALUES
  ('almacen-principal-123', 'demo-app-123', 'Almacén Principal', 'Av. Principal 123, Lima', 'Almacén central de distribución')
ON CONFLICT (id) DO NOTHING;

-- 6. Crear productos de inventario de prueba
INSERT INTO productos_inventario (id, app_id, sku, nombre, descripcion, categoria_id, unidad_id, precio_unitario, activo) VALUES
  ('prod-laptop-123', 'demo-app-123', 'LAPTOP-001', 'Laptop HP Pavilion', 'Laptop para uso empresarial', 'cat-electronica-123', 'unidad-piezas-123', 2500.00, true),
  ('prod-mouse-123', 'demo-app-123', 'MOUSE-001', 'Mouse Inalámbrico', 'Mouse ergonómico inalámbrico', 'cat-electronica-123', 'unidad-piezas-123', 45.00, true),
  ('prod-silla-123', 'demo-app-123', 'SILLA-001', 'Silla de Oficina', 'Silla ergonómica para oficina', 'cat-hogar-123', 'unidad-piezas-123', 350.00, true),
  ('prod-taladro-123', 'demo-app-123', 'TAL-001', 'Taladro Eléctrico', 'Taladro percutor 13mm', 'cat-herramientas-123', 'unidad-piezas-123', 180.00, true),
  ('prod-cafe-123', 'demo-app-123', 'CAFE-001', 'Café Premium', 'Café tostado artesanal', 'cat-alimentos-123', 'unidad-kg-123', 25.00, true)
ON CONFLICT (id) DO NOTHING;

-- 7. Crear movimientos de inventario iniciales (entradas)
INSERT INTO movimientos_inventario (id, app_id, producto_id, almacen_id, tipo, cantidad, costo_unitario, referencia, fecha_movimiento) VALUES
  ('mov-001-123', 'demo-app-123', 'prod-laptop-123', 'almacen-principal-123', 'entrada', 10, 2200.00, 'Compra inicial', '2024-01-15 10:00:00+00'),
  ('mov-002-123', 'demo-app-123', 'prod-mouse-123', 'almacen-principal-123', 'entrada', 50, 35.00, 'Compra inicial', '2024-01-15 10:30:00+00'),
  ('mov-003-123', 'demo-app-123', 'prod-silla-123', 'almacen-principal-123', 'entrada', 25, 280.00, 'Compra inicial', '2024-01-15 11:00:00+00'),
  ('mov-004-123', 'demo-app-123', 'prod-taladro-123', 'almacen-principal-123', 'entrada', 15, 150.00, 'Compra inicial', '2024-01-15 11:30:00+00'),
  ('mov-005-123', 'demo-app-123', 'prod-cafe-123', 'almacen-principal-123', 'entrada', 100, 18.00, 'Compra inicial', '2024-01-15 12:00:00+00')
ON CONFLICT (id) DO NOTHING;

-- 8. Crear algunas salidas para mostrar movimiento
INSERT INTO movimientos_inventario (id, app_id, producto_id, almacen_id, tipo, cantidad, costo_unitario, referencia, fecha_movimiento) VALUES
  ('mov-006-123', 'demo-app-123', 'prod-laptop-123', 'almacen-principal-123', 'salida', 2, 2200.00, 'Venta cliente A', '2024-01-20 14:00:00+00'),
  ('mov-007-123', 'demo-app-123', 'prod-mouse-123', 'almacen-principal-123', 'salida', 10, 35.00, 'Venta cliente A', '2024-01-20 14:15:00+00'),
  ('mov-008-123', 'demo-app-123', 'prod-silla-123', 'almacen-principal-123', 'salida', 5, 280.00, 'Venta oficina', '2024-01-22 09:00:00+00'),
  ('mov-009-123', 'demo-app-123', 'prod-cafe-123', 'almacen-principal-123', 'salida', 20, 18.00, 'Consumo interno', '2024-01-25 16:00:00+00')
ON CONFLICT (id) DO NOTHING;

-- Verificar datos creados
SELECT 'Apps creadas:' as info, count(*) as cantidad FROM apps WHERE id = 'demo-app-123'
UNION ALL
SELECT 'Productos creados:', count(*) FROM productos_inventario WHERE app_id = 'demo-app-123'
UNION ALL
SELECT 'Categorías creadas:', count(*) FROM categorias_inventario WHERE app_id = 'demo-app-123'
UNION ALL
SELECT 'Unidades creadas:', count(*) FROM unidades_medida WHERE app_id = 'demo-app-123'
UNION ALL
SELECT 'Movimientos creados:', count(*) FROM movimientos_inventario WHERE app_id = 'demo-app-123';