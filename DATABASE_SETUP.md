# Configuración Base de Datos - Sistema Multi-Tenant

## Resumen

Este documento explica cómo configurar las tablas de Supabase para el sistema multi-tenant de Apps (espacios de trabajo).

## 📋 Arquitectura

### Tablas Principales

1. **`apps`** - Espacios de trabajo (organizaciones/proyectos)
2. **`app_members`** - Miembros y roles por App

### Roles Disponibles

- `owner` - Propietario (control total)
- `admin` - Administrador (gestión de miembros, configuración)
- `editor` - Editor (crear/editar/eliminar contenido)
- `viewer` - Visualizador (solo lectura)

## 🚀 Pasos de Configuración

### 1. Ejecutar SQL en Supabase

1. Ve a tu proyecto Supabase → **SQL Editor**
2. Crea una nueva query
3. Copia y pega el contenido completo de `database/apps_schema.sql`
4. Ejecuta el script

### 2. Verificar Creación

Después de ejecutar el script, deberías ver:

**Tablas creadas:**
- `apps`
- `app_members`

**Funciones RPC creadas:**
- `get_user_apps()` - Apps donde el usuario es owner
- `get_member_apps()` - Apps donde el usuario es miembro
- `create_app(name, description)` - Crear nueva App

**Índices y triggers configurados automáticamente**

### 3. Probar Funcionalidad

Una vez ejecutado, puedes probar desde la app Flutter:

1. **Login** - Inicia sesión con Google OAuth
2. **Apps Selector** - Verás la pantalla de selección de Apps
3. **Crear App** - Usa el botón "Crear Nueva App"
4. **Navegación** - Selecciona una App para continuar

## 🔐 Seguridad (RLS)

El script configura automáticamente Row Level Security:

- **Apps**: Solo visibles para owners y miembros activos
- **Members**: Solo visibles para miembros de la misma App
- **Creación**: Solo owners pueden crear/modificar sus Apps
- **Gestión**: Solo owners/admins pueden gestionar miembros

## 📊 Estructura de Datos

### Tabla `apps`
```sql
id          UUID        -- ID único
name        VARCHAR     -- Nombre del espacio
slug        VARCHAR     -- URL-friendly identifier
description TEXT        -- Descripción opcional
owner_id    UUID        -- Usuario propietario
created_at  TIMESTAMPTZ -- Fecha creación
updated_at  TIMESTAMPTZ -- Fecha actualización
settings    JSONB       -- Configuración personalizada
is_active   BOOLEAN     -- Estado activo/inactivo
```

### Tabla `app_members`
```sql
id          UUID              -- ID único
app_id      UUID              -- Referencia a apps
user_id     UUID              -- Usuario miembro
role        app_member_role   -- Rol del usuario
invited_by  UUID              -- Quien lo invitó
invited_at  TIMESTAMPTZ       -- Fecha invitación
joined_at   TIMESTAMPTZ       -- Fecha que se unió
is_active   BOOLEAN           -- Estado activo/inactivo
```

## 🔧 Funciones RPC

### `get_user_apps()`
Obtiene las Apps donde el usuario actual es owner.

**Retorna:** Lista de Apps con metadata y conteo de miembros

### `get_member_apps()`
Obtiene las Apps donde el usuario actual es miembro (no owner).

**Retorna:** Lista de Apps con rol del usuario y metadata

### `create_app(name, description)`
Crea una nueva App y añade automáticamente al usuario como owner.

**Parámetros:**
- `name` (VARCHAR) - Nombre de la App (mínimo 3 caracteres)
- `description` (TEXT, opcional) - Descripción

**Retorna:** App creada con todos los campos

## 🧪 Testing

Para probar manualmente desde Supabase SQL Editor:

```sql
-- Ver mis Apps (como owner)
SELECT * FROM get_user_apps();

-- Ver Apps donde soy miembro
SELECT * FROM get_member_apps();

-- Crear nueva App
SELECT * FROM create_app('Mi Inventario Test', 'App de prueba');
```

## 🚨 Troubleshooting

### Error: "function get_user_apps() does not exist"
- **Causa:** El script SQL no se ejecutó correctamente
- **Solución:** Re-ejecutar `database/apps_schema.sql` completo

### Error: "permission denied for table apps"
- **Causa:** RLS bloqueando acceso
- **Solución:** Verificar que el usuario esté autenticado en Supabase

### Error: "duplicate key value violates unique constraint"
- **Causa:** Intentando crear App con slug duplicado
- **Solución:** El sistema genera slugs únicos automáticamente, reportar bug

### Apps no aparecen en la UI
- **Causa:** Usuario no tiene Apps creadas
- **Solución:** Usar "Crear Nueva App" para crear la primera

## 📁 Archivos Relacionados

- `database/apps_schema.sql` - Script SQL completo
- `lib/features/apps/models/app_model.dart` - Modelos Dart
- `lib/features/apps/providers/apps_provider.dart` - Providers Riverpod
- `lib/features/apps/screens/apps_selector_screen.dart` - UI selector

## 🔄 Siguientes Pasos

1. **Configurar tablas inventario** - Relacionar con `app_id`
2. **Sistema invitaciones** - Para añadir miembros por email
3. **Gestión roles** - UI para cambiar permisos de miembros
4. **Analytics** - Tracking de uso por App

---

**¿Necesitas ayuda?** Revisa los logs de la app Flutter para errores específicos de Supabase.