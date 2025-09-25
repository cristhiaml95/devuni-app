# 🛣️ **HOJA DE RUTA COMPLETA - DEVUNI APP**
## *Frontend Flutter basado en Backend Auditado*

**Fecha:** 25 de Septiembre, 2025  
**Estado Backend:** ✅ 100% Auditado y Listo para Producción  
**Arquitectura:** Multi-Tenant con RLS + Roles Jerárquicos  

---

## 🎯 **ESTRATEGIA DE DESARROLLO**

### **🏗️ Arquitectura Base (Ya Implementada)**
✅ **Supabase Client** - Configurado con PKCE para web  
✅ **Riverpod State Management** - Providers básicos implementados  
✅ **Go Router** - Navegación con auth state  
✅ **Material 3** - Tema responsive y componentes  
✅ **Apps Selector** - Multi-tenant funcionando  

### **📊 Backend Knowledge Base**
✅ **9 Tablas** mapeadas con relaciones completas  
✅ **2 Enums** jerárquicos bien definidos  
✅ **5 Vistas** optimizadas para consultas frecuentes  
✅ **7 RPCs** para lógica de negocio segura  
✅ **29 Políticas RLS** con permisos granulares  

---

## 📋 **FASES DE DESARROLLO**

### **🏛️ FASE 1: FUNDACIONES (2-3 días)**
#### **1.1 Modelos de Datos**
```dart
// Prioridad: CRÍTICA
// Mapear exactamente las tablas del backend
```
- **AppModel** con validación de ownership
- **RolUsuarioApp** enum con jerarquía numérica
- **ProductoInventario** con SKU único y referencias
- **MovimientoInventario** con tipos y validaciones
- **Modelos de catálogos:** UnidadMedida, CategoriaInventario, Almacen
- **Sistema de membresías:** AppMiembro, AppInvitacion

#### **1.2 Providers Especializados**
```dart
// Usar las vistas optimizadas del backend
```
- **appsAccesiblesProvider** → vista_apps_accesibles
- **rolEnAppProvider** → RPC mi_rol_en_app
- **stockActualProvider** → vista_stock_actual_por_producto
- **productosActivosProvider** → productos filtrados activos
- **miembrosAppProvider** → gestión de usuarios

---

### **🏠 FASE 2: DASHBOARD CENTRAL (2-3 días)**
#### **2.1 Dashboard Principal por App**
```dart
// Pantalla post-selección de app
```
- **Métricas clave:** Total productos, stock valorizado, movimientos del mes
- **Navegación rápida:** Productos, Stock, Movimientos, Reportes
- **Context awareness:** Mostrar datos según rol del usuario
- **Indicadores visuales:** Stock bajo, productos sin movimiento

#### **2.2 Navegación Contextual**
```dart
// Sistema de navegación consciente del contexto
```
- **App Context Provider** - Mantener app seleccionada
- **Role Context Provider** - Permisos según rol actual
- **Drawer/BottomNav** - Opciones según rol
- **Breadcrumbs** - Navegación clara en contexto

---

### **📦 FASE 3: GESTIÓN DE INVENTARIO (4-5 días)**
#### **3.1 CRUD de Productos**
```dart
// Funcionalidad core del sistema
```
- **Lista de productos** con paginación y búsqueda
- **Crear/Editar producto** con validación de SKU único
- **Categorías y unidades** dropdown con lazy loading
- **Estados:** Activo/Inactivo con soft delete
- **Validación de roles:** Editor+ para CUD

#### **3.2 Sistema de Movimientos**
```dart
// Usar RPC registrar_movimiento_inventario
```
- **Registro de entradas** con proveedor y costo
- **Registro de salidas** con destino y motivo  
- **Ajustes de inventario** positivos/negativos
- **Validaciones:** Cantidades positivas, productos existentes
- **Historial:** Movimientos por producto con filtros

#### **3.3 Catálogos Base**
```dart
// Soporte para clasificación
```
- **Unidades de Medida:** CRUD con código único por app
- **Categorías:** CRUD con nombre único por app
- **Almacenes:** CRUD con ubicaciones y notas

---

### **📊 FASE 4: REPORTES Y ANALYTICS (2-3 días)**
#### **4.1 Vista de Stock**
```dart
// Usar vistas optimizadas del backend
```
- **Stock consolidado** por producto (todos los almacenes)
- **Stock detallado** por producto y almacén
- **Filtros avanzados:** Categoría, almacén, stock bajo
- **Exportación:** Excel/CSV con datos filtrados

#### **4.2 Reportes de Movimientos**
```dart
// Analytics de operaciones
```
- **Movimientos por período** con gráficos
- **Productos más movidos** ranking
- **Análisis de costos** entrada vs salida
- **Tendencias de stock** alertas automáticas

---

### **👥 FASE 5: GESTIÓN DE USUARIOS (3-4 días)**
#### **5.1 Panel de Miembros (Solo Admin+)**
```dart
// Usar RPCs de invitación y membresía
```
- **Lista de miembros** con roles actuales
- **Cambiar roles** con validación jerárquica
- **Invitar usuarios** por email con RPC invitar_a_app
- **Gestionar invitaciones** pendientes/aceptadas/canceladas

#### **5.2 Sistema de Invitaciones**
```dart
// Flujo completo de invitaciones
```
- **Envío de invitaciones** con email validation
- **Pantalla de aceptación** con RPC aceptar_invitacion
- **Notificaciones** de invitaciones recibidas
- **Historial** de invitaciones por app

---

### **🔧 FASE 6: OPTIMIZACIONES (2-3 días)**
#### **6.1 Performance y UX**
```dart
// Mejoras de experiencia
```
- **Caché inteligente** con Riverpod
- **Offline support** para lectura básica
- **Loading states** consistentes
- **Error handling** robusto

#### **6.2 Funcionalidades Avanzadas**
```dart
// Features adicionales
```
- **Búsqueda global** en productos
- **Códigos de barras** scanning
- **Importación masiva** de productos
- **Backup/Restore** de datos

---

## ⏱️ **CRONOGRAMA REALISTA**

| Fase | Duración | Acumulado | Entregables |
|------|----------|-----------|-------------|
| **Fase 1** | 2-3 días | 3 días | Modelos + Providers |
| **Fase 2** | 2-3 días | 6 días | Dashboard funcional |
| **Fase 3** | 4-5 días | 11 días | CRUD completo inventario |
| **Fase 4** | 2-3 días | 14 días | Reportes y analytics |
| **Fase 5** | 3-4 días | 18 días | Gestión de usuarios |
| **Fase 6** | 2-3 días | 21 días | App completa y optimizada |

**🎯 TOTAL: 3 semanas de desarrollo enfocado**

---

## 🏆 **CRITERIOS DE ÉXITO**

### **📱 Funcionalidad Core**
- ✅ Multi-tenant con cambio fluido entre apps
- ✅ CRUD completo de productos con validaciones
- ✅ Registro de movimientos con cálculo automático de stock
- ✅ Reportes de stock en tiempo real
- ✅ Gestión de usuarios con roles jerárquicos

### **🔒 Seguridad y Validación**
- ✅ Respeto total a políticas RLS del backend
- ✅ Validación de roles en UI (editor+, admin+)
- ✅ Manejo seguro de sesiones multi-tenant
- ✅ Validaciones de negocio (SKU único, cantidades positivas)

### **⚡ Performance y UX**
- ✅ Uso de vistas optimizadas del backend
- ✅ Carga rápida de listas con paginación
- ✅ Estados de carga consistentes
- ✅ Navegación intuitiva con contexto claro

---

## 🚀 **PLAN DE ACCIÓN INMEDIATO**

### **🎯 PRIMER SPRINT (Hoy)**
1. **Crear modelos Dart** que reflejen exactamente las tablas del backend
2. **Actualizar providers** para usar vistas optimizadas
3. **Implementar Dashboard** con métricas básicas

### **📋 PRÓXIMOS PASOS**
- **Definir prioridades** según necesidades del negocio
- **Iterar rápidamente** con feedback continuo
- **Mantener calidad** con testing incremental

**¿Empezamos con los modelos de datos y providers actualizados?** El backend auditado nos da la base perfecta para implementar todo con precisión.