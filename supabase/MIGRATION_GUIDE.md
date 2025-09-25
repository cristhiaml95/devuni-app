# 🚀 Guía de Migration Multi-Tenant para Supabase

## 📋 Resumen

Hemos creado un sistema completo para verificar e implementar el schema multi-tenant de manera incremental y segura. El sistema incluye verificaciones automáticas para evitar duplicar estructuras existentes.

## 📁 Archivos Creados

### 1. `verify_current_schema.sql`
Script para inspeccionar el schema actual de tu base de datos antes de aplicar cambios.

### 2. `incremental_migration.sql` 
Script principal de migration que:
- ✅ Verifica existencia antes de crear
- ✅ Crea tablas `apps` y `app_members`
- ✅ Implementa RLS con políticas completas
- ✅ Crea funciones helper y triggers
- ✅ Es completamente idempotente (se puede ejecutar múltiples veces)

### 3. `test_migration.sql`
Script de verificación post-migration para validar que todo funciona correctamente.

## 🔧 Pasos para Ejecutar la Migration

### Paso 1: Verificar Schema Actual
1. Ve al **SQL Editor** en tu Dashboard de Supabase
2. Ejecuta el contenido de `verify_current_schema.sql`
3. Revisa los resultados para entender qué existe actualmente

### Paso 2: Aplicar Migration Incremental
1. En el **SQL Editor**, ejecuta el contenido de `incremental_migration.sql`
2. El script mostrará mensajes informativos sobre qué se crea o se omite
3. Revisa los mensajes para confirmar que todo se ejecutó correctamente

### Paso 3: Verificar la Migration
1. Ejecuta el contenido de `test_migration.sql`
2. Verifica que todos los tests pasen (✅)
3. Si hay errores (❌), revisa los mensajes para entender qué falló

## 🏗️ Estructura Creada

### Tabla `apps`
```sql
- id (UUID, PK)
- name (TEXT, NOT NULL)
- description (TEXT)
- owner_id (UUID, FK to auth.users)
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
```

### Tabla `app_members`
```sql
- id (UUID, PK)
- app_id (UUID, FK to apps)
- user_id (UUID, FK to auth.users)
- role (TEXT: 'owner', 'admin', 'member')
- permissions (JSONB)
- invited_by (UUID, FK to auth.users)
- invited_at (TIMESTAMPTZ)
- joined_at (TIMESTAMPTZ)
```

### Funciones Helper
- `handle_updated_at()`: Trigger para actualizar timestamp
- `get_user_apps()`: Función para obtener apps del usuario con roles

### Políticas RLS
- **Apps**: Los usuarios pueden ver/editar apps que poseen o donde son miembros
- **App Members**: Control granular sobre membresías basado en roles

## 🔒 Seguridad RLS

El sistema implementa Row Level Security completo:

### Para `apps`:
- **SELECT**: Ver apps propias o donde eres miembro
- **INSERT**: Crear apps propias únicamente
- **UPDATE**: Actualizar solo apps propias
- **DELETE**: Eliminar solo apps propias

### Para `app_members`:
- **SELECT**: Ver membresías donde participas o administras
- **INSERT**: Agregar miembros (solo owners/admins)
- **UPDATE**: Modificar membresías (solo owners/admins)
- **DELETE**: Remover miembros (owners/admins) o salirse (self)

## 🎯 Funcionalidad en Flutter

Después de la migration, tu app Flutter podrá:

1. **Listar Apps del Usuario**:
   ```dart
   final apps = await supabase.rpc('get_user_apps').execute();
   ```

2. **Crear Nueva App**:
   ```dart
   await supabase.from('apps').insert({
     'name': 'Mi Nueva App',
     'description': 'Descripción de la app'
   });
   ```

3. **Gestionar Miembros**:
   ```dart
   await supabase.from('app_members').insert({
     'app_id': appId,
     'user_id': memberId,
     'role': 'member'
   });
   ```

## 🚨 Notas Importantes

1. **Idempotencia**: Los scripts se pueden ejecutar múltiples veces sin problemas
2. **Seguridad**: RLS está habilitado por defecto en todas las tablas
3. **Performance**: Índices optimizados para consultas frecuentes
4. **Escalabilidad**: Diseño preparado para crecer con tu aplicación

## 🔍 Troubleshooting

### Si algo falla:
1. Revisa los mensajes de error en el SQL Editor
2. Ejecuta `verify_current_schema.sql` para ver el estado actual
3. Ejecuta `test_migration.sql` para diagnosticar problemas específicos

### MCP (Opcional):
- MCP está configurado pero puede requerir reiniciar VS Code
- Como backup, todos los scripts SQL están listos para uso manual

## 🎉 Próximos Pasos

Una vez completada la migration:
1. Testa la funcionalidad desde tu app Flutter
2. Implementa la UI para gestión de apps y miembros
3. Considera agregar más campos/funcionalidades según necesites

---

**¡El sistema multi-tenant está listo para producción! 🚀**