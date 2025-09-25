# 🧪 GUÍA DE TESTING - DevUni App

## 📋 Estado Actual de la Aplicación

✅ **Completado:**
- ✅ Modelos Dart del backend (todos)
- ✅ Providers Riverpod para entidades
- ✅ PantallaInventario reescrita con providers correctos
- ✅ Script SQL para datos de prueba

🔄 **En Progreso:**
- 🔧 Testing con datos reales
- 🔧 Completar pantallas de inventario

## 🚀 Pasos para Probar la App

### 1. Crear Datos de Prueba
```sql
-- Ejecutar en la consola SQL de Supabase:
-- Ve a: https://supabase.com/dashboard/project/[tu-proyecto]/sql
-- Copia y pega el contenido de: sql/datos_prueba.sql
```

### 2. Ejecutar la Aplicación
```bash
flutter run -d chrome --web-port 3000
```

### 3. Probar Funcionalidades

#### 🔐 Autenticación
- [x] Login con Google OAuth funcionando
- [x] Manejo de sesiones
- [x] Navegación basada en auth state

#### 📱 Multi-tenant (Apps)
- [x] Selector de Apps
- [x] Creación simulada de Apps
- ⚠️ RPC functions no implementadas (error esperado)

#### 📦 Inventario
- [x] Tab de Productos
- [x] Tab de Categorías  
- [x] Tab de Unidades de Medida
- [x] Providers reactivos con Supabase streams
- [x] Estados de loading/error/empty

## 🐛 Errores Conocidos y Esperados

### ❌ RPCs No Implementadas
```
PostgrestException: Could not find the function public.get_user_apps
PostgrestException: Could not find the function public.create_app
```
**Solución:** Las funciones RPC deben crearse en Supabase según el backend audit.

### ❌ GoRouter Context Issues
```
Assertion failed: "No GoRouter found in context"
```
**Solución:** Navegación mejorada en próximas iteraciones.

### ⚠️ WebSocket Crashes
```
WebSocketChannelException: Instance of 'WebSocketException'
```
**Nota:** Error de desarrollo de Flutter, no afecta funcionalidad.

## 📊 Testing Checklist

### Pantalla de Inventario
- [ ] **Productos Tab:**
  - [ ] Muestra lista de productos
  - [ ] Estados empty/loading/error
  - [ ] Card design responsive
  - [ ] Navigation a detalle producto

- [ ] **Categorías Tab:**
  - [ ] Muestra lista de categorías
  - [ ] Estados empty/loading/error
  - [ ] Card design limpio

- [ ] **Unidades Tab:**
  - [ ] Muestra lista de unidades
  - [ ] Estados empty/loading/error
  - [ ] Información de código y descripción

### Funcionalidad General
- [ ] **App funciona sin crashes**
- [ ] **OAuth login exitoso**
- [ ] **Navegación a inventario**
- [ ] **Datos se cargan desde Supabase**
- [ ] **UI responsive y moderna**

## 🎯 Próximos Pasos

1. **Ejecutar sql/datos_prueba.sql** en Supabase
2. **Probar la app** en http://localhost:3000
3. **Verificar que los datos aparecen** en las tabs
4. **Reportar cualquier issue** encontrado
5. **Continuar con formularios de creación**

## 📝 Notas Técnicas

### Arquitectura Actual
```
lib/
├── features/inventory/
│   └── pantalla_inventario.dart ✅ (Reescrita)
├── data/providers/
│   ├── productos_inventario_provider.dart ✅
│   ├── catalogos_provider.dart ✅
│   └── providers.dart ✅
├── domain/models/
│   └── *.dart ✅ (Todos los modelos)
```

### Providers en Uso
- `productosInventarioProvider(appId)` - Stream de productos
- `categoriasInventarioProvider(appId)` - Stream de categorías  
- `unidadesMedidaProvider(appId)` - Stream de unidades
- `selectedAppProvider` - App seleccionada actual

### Estado de Testing
🟢 **Funcional:** Arquitectura, providers, UI
🟡 **Parcial:** Navigation, RPCs, datos de prueba
🔴 **Pendiente:** Formularios, dashboard, reportes

---
*Última actualización: Iteración de testing actual*