# 🔥 Configuración para Firebase Deployment
# ========================================

## Variables de Entorno para Firebase Functions

Para deployar de manera segura, necesitarás configurar estas variables como secretos en Firebase:

### 1. Configurar Firebase Secrets

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login a Firebase
firebase login

# Configurar secretos (ejecutar desde la raíz del proyecto)
firebase functions:secrets:set SUPABASE_URL
firebase functions:secrets:set SUPABASE_ANON_KEY
firebase functions:secrets:set SUPABASE_SERVICE_ROLE
firebase functions:secrets:set GOOGLE_CLIENT_ID
firebase functions:secrets:set GOOGLE_CLIENT_SECRET
```

### 2. Variables para Firebase Hosting

En `firebase.json`, configurar rewrites para Flutter Web:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

### 3. Scripts de Deployment

```bash
# Build Flutter Web
flutter build web --release

# Deploy a Firebase
firebase deploy --only hosting
```

### 4. Variables de Entorno en Producción

Crear archivo `.env.production`:

```env
APP_ENVIRONMENT=production
SUPABASE_URL=https://lkroyzyqkholdskgspnp.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
DEBUG_MODE=false
ENABLE_LOGGING=false
```

### 5. Seguridad

- ✅ **Client ID** y **Client Secret** están configurados como secretos
- ✅ **Service Role** no se expone en el frontend
- ✅ **URLs de redirect** están configuradas correctamente
- ✅ **.env.secrets** está en .gitignore

### 6. URLs de Producción

Cuando tengas tu dominio de producción, actualizar:

1. **Google Cloud Console** → Authorized JavaScript origins
2. **Supabase Dashboard** → Site URL y Redirect URLs
3. **Código de la app** → URL de redirect en login_screen.dart

## 🚀 Deployment Checklist

- [ ] Firebase project configurado
- [ ] Secretos configurados en Firebase
- [ ] URLs de producción actualizadas
- [ ] Flutter build web ejecutado
- [ ] Firebase deploy ejecutado
- [ ] OAuth probado en producción