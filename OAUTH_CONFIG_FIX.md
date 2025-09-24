# ⚠️ CONFIGURACIÓN OAUTH - PASOS CRÍTICOS

## 🔧 1. Configurar Supabase Dashboard (URGENTE)

**Accede a:** https://supabase.com/dashboard/project/lkroyzyqkholdskgspnp/auth/url-configuration

### Redirect URLs (debe incluir EXACTAMENTE):
```
http://localhost:3000/
```

### Site URL:
```
http://localhost:3000
```

### Configuración adicional OAuth Providers:
1. Ve a **Authentication → Providers → Google**
2. **Enable Google provider**: ✅ Activado
3. **Client ID**: `your-google-client-id.googleusercontent.com`
4. **Client Secret**: `your-google-client-secret`
5. **Redirect URL**: `https://lkroyzyqkholdskgspnp.supabase.co/auth/v1/callback`

## 🔧 2. Verificar archivo .env.secrets

Asegúrate de que tengas:
```env
# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Supabase Service Role (para admin)
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## 🔧 3. Verificar Google OAuth Console

**Accede a:** https://console.developers.google.com/

### Authorized redirect URIs debe incluir:
```
https://lkroyzyqkholdskgspnp.supabase.co/auth/v1/callback
```

### Authorized JavaScript origins:
```
http://localhost:3000
https://lkroyzyqkholdskgspnp.supabase.co
```

## ✅ 4. Después de configurar todo:

1. Guarda los cambios en Supabase Dashboard
2. Espera 1-2 minutos para que se propaguen
3. Prueba nuevamente el botón "Continuar con Google"

## 🐛 Si sigue fallando:

Revisa la consola del browser (F12) y busca errores específicos de:
- `redirect_uri_mismatch`
- `invalid_client`
- `unauthorized_client`

## 📞 Estado actual:
- ✅ Código corregido (AuthFlowType.implicit)
- ⏳ Dashboard config pendiente
- ⏳ Prueba OAuth pendiente