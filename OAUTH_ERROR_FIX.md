# 🚨 ERROR 400: redirect_uri_mismatch - SOLUCIÓN

## ❌ PROBLEMA IDENTIFICADO:
- **Error**: "Acceso bloqueado: La solicitud de devuni-app no es válida"
- **Código**: Error 400: redirect_uri_mismatch
- **Causa**: URLs de redirección no configuradas en Google OAuth Console

## ✅ SOLUCIÓN PASO A PASO:

### 1. 🔧 Google Cloud Console
**URL**: https://console.cloud.google.com/apis/credentials

1. Busca tu proyecto OAuth 2.0 Client ID
2. Haz clic para editarlo
3. En **"Authorized redirect URIs"** agrega:
   ```
   https://lkroyzyqkholdskgspnp.supabase.co/auth/v1/callback
   ```
4. En **"Authorized JavaScript origins"** agrega:
   ```
   http://localhost:3000
   https://lkroyzyqkholdskgspnp.supabase.co
   ```
5. **GUARDA LOS CAMBIOS**

### 2. 🔧 Supabase Dashboard
**URL**: https://supabase.com/dashboard/project/lkroyzyqkholdskgspnp/auth/url-configuration

1. En **"Redirect URLs"** agrega:
   ```
   http://localhost:3000/
   ```
2. En **"Site URL"** pon:
   ```
   http://localhost:3000
   ```
3. Ve a **"Providers → Google"** y verifica que esté habilitado
4. **GUARDA LOS CAMBIOS**

### 3. ⏳ Esperar propagación
- Espera 2-3 minutos para que los cambios se propaguen
- Los cambios de Google OAuth pueden tardar un poco

### 4. 🧪 Probar nuevamente
- Regresa a http://localhost:3000
- Haz clic en "Continuar con Google"
- Debería funcionar sin el error 400

## 📝 URLs CRÍTICAS PARA CONFIGURAR:

### Google OAuth Console:
```
Authorized redirect URIs:
https://lkroyzyqkholdskgspnp.supabase.co/auth/v1/callback

Authorized JavaScript origins:
http://localhost:3000
https://lkroyzyqkholdskgspnp.supabase.co
```

### Supabase Dashboard:
```
Redirect URLs:
http://localhost:3000/

Site URL:
http://localhost:3000
```

## 🎯 DESPUÉS DE CONFIGURAR:
1. Espera 2-3 minutos
2. Recarga http://localhost:3000
3. Prueba "Continuar con Google"
4. ✅ Debería funcionar perfectamente

---
**Estado**: Error identificado, solución clara definida