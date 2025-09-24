# 🚀 DevUni App - Handoff Documentation

> **IMPORTANTE**: Lee este archivo cuando inicies una nueva sesión de desarrollo para entender el estado actual del proyecto.

## 📊 Estado Actual del Proyecto (Actualizado: 2025-09-24)

### ✅ COMPLETADO
1. **OAuth Google + Supabase** - Totalmente funcional
2. **Dashboard post-login** - Usuario ve su información tras autenticación
3. **Arquitectura base** - Flutter Web + Riverpod + Material 3
4. **Sistema de configuración** - .env + AppConfig robusto

### 🔄 EN PROGRESO
- **Sistema Multi-Tenant (Apps)** - Próximo hito principal

### ⏳ PENDIENTE
- Módulo de inventario
- Roles y permisos granulares
- Invitaciones de usuarios

## 🏗️ Arquitectura Técnica

```
DevUni App (Flutter Web)
├── Core Layer
│   ├── Providers (Riverpod) - Estado global
│   ├── Config - Variables de entorno
│   └── Theme - Material 3 + Responsive design
├── Features
│   ├── Auth - Login Google OAuth ✅
│   ├── Dashboard - Info usuario ✅
│   ├── Apps - Multi-tenant (EN DESARROLLO)
│   └── Inventory - CRUD inventario (PENDIENTE)
└── Data Layer
    └── Supabase - Auth + PostgreSQL + RLS
```

## 🔑 Archivos Críticos

### Estado de Autenticación
- `lib/core/providers/supabase_providers.dart` - **CRÍTICO**
  - OAuth provider con `getSessionFromUrl()`
  - Manejo completo de estados auth
  - Logging detallado para debugging

### UI Principal
- `lib/features/dashboard/dashboard_screen.dart` - Dashboard post-login
- `lib/app/auth_wrapper.dart` - Router auth/dashboard
- `lib/features/auth/login_screen.dart` - UI OAuth Google

### Configuración
- `.env` - Variables públicas (en repo)
- `.env.secrets` - Credenciales privadas (local only)
- `lib/core/config/app_config.dart` - Carga config

## 🌐 OAuth Google - Estado Funcional

### Lo que FUNCIONA
- [x] Login con Google OAuth
- [x] Procesamiento automático de tokens desde URL
- [x] Establecimiento de sesión Supabase
- [x] Redirección a dashboard post-login
- [x] Logout funcional
- [x] Estado persistente entre recargas

### Configuración Actual
- **URL**: http://localhost:3000
- **Supabase Project**: lkroyzyqkholdskgspnp.supabase.co
- **OAuth Flow**: Implicit flow con detección automática
- **Credenciales**: En .env.secrets (no en repo)

## 🎯 Próximo Hito: Sistema Multi-Tenant

### Objetivo
Permitir que usuarios creen y gestionen múltiples "Apps" (espacios de trabajo) con:
- Selector de Apps al login
- Navegación entre Apps
- Roles por App
- Base para módulo inventario

### Archivos a Crear/Modificar
1. **Crear**: `lib/features/apps/apps_selector_screen.dart`
2. **Crear**: `lib/features/apps/models/app_model.dart`
3. **Crear**: `lib/features/apps/providers/apps_provider.dart`
4. **Modificar**: `lib/app/auth_wrapper.dart` - Routing post-login
5. **Crear**: Tablas Supabase para Apps multi-tenant

### Base de Datos Supabase
```sql
-- Tabla apps (espacios de trabajo)
CREATE TABLE apps (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  description TEXT,
  owner_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla app_members (usuarios por app)
CREATE TABLE app_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  app_id UUID REFERENCES apps(id),
  user_id UUID REFERENCES auth.users(id),
  role VARCHAR DEFAULT 'member', -- owner, admin, member
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 🚨 Problemas Conocidos y Soluciones

### 1. Flutter Web Crashes (WebSocket)
**Problema**: Flutter beta puede crashear con WebSocket errors
**Solución**: Usar modo release o matar procesos dart.exe

### 2. OAuth Redirect Loop
**Problema**: Usuario regresa a login tras OAuth
**Solución**: Implementado en `oauthInitializerProvider` con `getSessionFromUrl()`

### 3. Secretos en Git
**Problema**: GitHub bloquea push con secretos
**Solución**: Usar placeholders en docs, credenciales en .env.secrets

## 🔧 Comandos de Desarrollo

```bash
# Ejecutar app
flutter run -d chrome --web-port=3000 --web-hostname=localhost --web-renderer=html

# Si hay crashes de WebSocket
taskkill /IM dart.exe /F

# Build release (más estable)
flutter run -d chrome --web-port=3000 --web-hostname=localhost --web-renderer=html --release
```

## 📝 Logs Importantes

El OAuth provider genera logs detallados. Buscar:
- `🔗 Tokens OAuth detectados en URL`
- `✅ Sesión OAuth procesada exitosamente`
- `👤 Usuario autenticado: [email]`

## 🎨 UI/UX Guidelines

- **Tema**: Material 3 con colors personalizados
- **Responsive**: Breakpoints definidos en `app_breakpoints.dart`
- **Colores**: Primary: 0xFF667eea
- **Navegación**: AuthWrapper maneja auth/dashboard routing

## 💡 Para Nuevos Agentes

**Comando inicial sugerido para nueva sesión:**
> "Hola, acabo de hacer git pull de un proyecto Flutter llamado DevUni App. Es una app multi-tenant con OAuth Google ya funcionando. Por favor lee el archivo HANDOFF.md para entender el estado actual, luego ayúdame a continuar con el sistema multi-tenant de Apps. El OAuth ya funciona perfectamente."

---

**✨ Última actualización**: 2025-09-24 - OAuth Google completamente funcional
**🎯 Próximo objetivo**: Sistema Multi-Tenant (Apps)
**👨‍💻 Estado**: Listo para continuar desarrollo