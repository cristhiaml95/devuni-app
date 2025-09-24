# 🔐 Configuración de Google OAuth para Supabase

Esta guía te ayudará a configurar Google OAuth en tu proyecto Supabase para que funcione con la aplicación Flutter Web.

## 📋 Pasos de Configuración

### 1. Configurar Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crear o seleccionar un proyecto
3. Habilitar la **Google+ API** y **Google OAuth2 API**
4. Ir a **APIs & Services** → **Credentials**
5. Crear **OAuth 2.0 Client IDs**:
   
   **Para Web:**
   - Tipo: Web application
   - Nombre: `DevUni App Web`
   - Authorized JavaScript origins:
     - `http://localhost:50505` (para desarrollo)
     - `https://lkroyzyqkholdskgspnp.supabase.co` (tu URL de Supabase)
   - Authorized redirect URIs:
     - `https://lkroyzyqkholdskgspnp.supabase.co/auth/v1/callback`

### 2. Configurar Supabase Dashboard

1. Ve a [Supabase Dashboard](https://app.supabase.com/)
2. Selecciona tu proyecto
3. Ir a **Authentication** → **Providers** → **Google**
4. Habilitar Google provider
5. Configurar:
   - **Client ID**: Pegar el Client ID de Google Cloud Console
   - **Client Secret**: Pegar el Client Secret de Google Cloud Console
   - **Redirect URL**: `https://lkroyzyqkholdskgspnp.supabase.co/auth/v1/callback`

### 3. Configurar URLs en Supabase

En **Authentication** → **URL Configuration**:
- **Site URL**: `http://localhost:50505` (desarrollo) o tu dominio de producción
- **Redirect URLs**: 
  - `http://localhost:50505/**`
  - `https://tu-dominio.com/**`

### 4. Verificar Configuración en Flutter

El código ya está configurado para manejar OAuth en web:

```dart
// En supabase_providers.dart
authOptions: const AuthClientOptions(
  autoRefreshToken: true,
  pkceAsyncStorage: null, // ✅ Configurado para web
),

// En login_screen.dart
await client.auth.signInWithOAuth(
  OAuthProvider.google,
  redirectTo: redirectUrl, // ✅ URL dinámica
  authScreenLaunchMode: LaunchMode.externalApplication,
);
```

## 🧪 Pruebas

### Desarrollo Local
1. Ejecutar: `flutter run -d chrome --web-renderer html`
2. Ir a `http://localhost:50505`
3. Click en "Iniciar sesión con Google"
4. Completar flujo OAuth
5. Verificar redirección exitosa

### Logs de Debug
La aplicación incluye logging detallado:
- ✅ Inicialización OAuth
- 🔐 Cambios de estado de autenticación  
- 👤 Información del usuario
- 🌐 Detección de tokens OAuth en URL

## ⚠️ Problemas Comunes

### Error: "OAuth flow failed"
- ✅ Verificar que el Client ID esté correctamente configurado
- ✅ Confirmar que las URLs de redirect estén bien configuradas
- ✅ Asegurar que la Google+ API esté habilitada

### Error: "PKCE failed"
- ✅ Ya configurado con `pkceAsyncStorage: null` para web
- ✅ Verificar que el navegador soporte localStorage

### Error: "Redirect mismatch"
- ✅ Verificar que la URL de redirect en Google Console coincida exactamente
- ✅ Incluir protocolo (http/https) y puerto si es necesario

## 📱 URLs de Configuración

### Desarrollo
- **App URL**: `http://localhost:50505`
- **OAuth Redirect**: `https://lkroyzyqkholdskgspnp.supabase.co/auth/v1/callback`

### Producción
- **App URL**: Tu dominio personalizado
- **OAuth Redirect**: `https://lkroyzyqkholdskgspnp.supabase.co/auth/v1/callback`

## 🔍 Debug

Para ver logs en desarrollo:
1. Abrir DevTools (F12)
2. Ir a Console
3. Buscar logs con emojis: 🔐, 👤, ✅, ❌

El logging incluye:
- Estado de inicialización OAuth
- Eventos de autenticación
- Información de sesión y usuario
- Errores detallados

---

💡 **Tip**: Una vez configurado correctamente, el flujo OAuth será transparente para el usuario y funcionará tanto en desarrollo como en producción.