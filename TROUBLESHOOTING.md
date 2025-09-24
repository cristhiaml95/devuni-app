# Guía de Solución de Problemas - DevUni App

## Problema: La aplicación se queda en "Cargando sistema de inventario"

### Síntomas:
- La aplicación muestra el loading del HTML indefinidamente
- No redirige a la pantalla de login para usuarios nuevos
- No responde a interacciones

### Causas identificadas:
1. **Provider de usuario no reactivo**: El `usuarioActualProvider` usaba valor estático en lugar del stream
2. **Loading HTML no se oculta**: El evento `flutter-first-frame` no se dispara correctamente
3. **Router no maneja estados de carga**: No diferencia entre "cargando sesión" y "sin autenticar"

## Problema: Pantalla en blanco después del loading

### Síntomas:
- El loading del HTML se oculta correctamente
- Aparece una pantalla completamente blanca
- No se muestra la pantalla de login

### Causas identificadas:
1. **Router.withConfig mal implementado**: No es la forma correcta de usar GoRouter
2. **MaterialApp.router no configurado**: Falta la estructura correcta de la aplicación
3. **Complejidad innecesaria**: El router maneja autenticación cuando debería ser más simple

## Problema: Usuario sin autenticar no va a login automáticamente

### Síntomas:
- Loading se muestra correctamente
- Después del loading, pantalla en blanco persistente
- No hay redirección automática a pantalla de login

### Causas identificadas:
1. **Router complejo**: Manejo de auth en router + main.dart genera conflictos
2. **Estado de loading confuso**: Router no espera a que se resuelva el estado de sesión

### Soluciones implementadas:

#### 1. Provider de usuario reactivo
```dart
// ❌ ANTES: Valor estático
final usuarioActualProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser; // No se actualiza automáticamente
});

// ✅ DESPUÉS: Basado en stream
final usuarioActualProvider = Provider<User?>((ref) {
  final sesionAsync = ref.watch(sesionUsuarioProvider);
  return sesionAsync.when(
    data: (user) => user,
    loading: () => null,
    error: (error, stack) => null,
  );
});
```

#### 2. AppWrapper para manejar estados de carga
```dart
class AppWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesionAsync = ref.watch(sesionUsuarioProvider);
    
    return sesionAsync.when(
      data: (usuario) {
        // Sesión cargada -> usar router normal
        final router = ref.watch(appRouterProvider);
        return Router.withConfig(config: router);
      },
      loading: () => const PantallaCarga(), // Mostrar loading nativo
      error: (error, stack) => const PantallaLogin(),
    );
  }
}
```

#### 3. Loading HTML mejorado
```javascript
// Múltiples estrategias para ocultar loading
function hideLoading() {
  const loading = document.querySelector('#loading');
  if (loading) {
    loading.remove();
  }
}

// Evento principal
window.addEventListener('flutter-first-frame', hideLoading);

// Fallback con timeout
setTimeout(hideLoading, 10000);

// Fallback cuando DOM está listo
document.addEventListener('DOMContentLoaded', function() {
  setTimeout(function() {
    if (window._flutter && window._flutter.loader) {
      hideLoading();
    }
  }, 5000);
});
```

#### 4. MaterialApp.router correctamente configurado
```dart
// ❌ ANTES: Router.withConfig mal usado
return Router.withConfig(config: router);

// ✅ DESPUÉS: MaterialApp.router en el contexto correcto
return sesionAsync.when(
  data: (usuario) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'DevUni - Inventario Multi-App',
      routerConfig: router,
      // ... configuración completa
    );
  },
  loading: () => MaterialApp(
    home: const PantallaCarga(),
  ),
  error: (error, stack) => MaterialApp(
    home: const PantallaLogin(),
  ),
);
```

#### 5. Login con Google corregido para web
```dart
// ❌ ANTES: redirectTo fijo para móvil
await client.auth.signInWithOAuth(
  OAuthProvider.google,
  redirectTo: 'io.supabase.devuni://login-callback/',
);

// ✅ DESPUÉS: redirectTo condicional
await client.auth.signInWithOAuth(
  OAuthProvider.google,
  redirectTo: kIsWeb ? null : 'io.supabase.devuni://login-callback/',
);
```

#### 6. Flujo de navegación simplificado
```dart
// ❌ ANTES: Router complejo con auth + navegación
return GoRouter(
  redirect: (context, state) {
    final estaAutenticado = usuarioActual != null;
    if (!estaAutenticado && location != '/login') {
      return '/login'; // Esto causaba conflictos
    }
    // ... lógica compleja
  },
);

// ✅ DESPUÉS: Manejo directo en main.dart
return sesionAsync.when(
  data: (usuario) {
    if (usuario == null) {
      return MaterialApp(home: const PantallaLogin()); // Directo
    }
    return MaterialApp.router(routerConfig: router); // Solo apps/nav
  },
  loading: () => MaterialApp(home: const PantallaCarga()),
  error: (error, stack) => MaterialApp(home: const PantallaLogin()),
);
```

## Problema: Errores de compilación en web

### Errores comunes:
- `setState` no definido en `ConsumerWidget`
- Método `fold` no encontrado en `Resultado<T>`
- `state.uri.toString()` no existe en go_router

### Soluciones:
1. **setState en ConsumerWidget**: Usar `ref.refresh()` o cambiar a `ConsumerStatefulWidget`
2. **Método fold**: Mover de extension a la clase base `Resultado<T>`
3. **go_router**: Usar `state.fullPath` en lugar de `state.uri.toString()`

## Flujo de Usuario Esperado

### Para usuario nuevo:
1. **Carga inicial**: `PantallaCarga` mientras se verifica sesión
2. **Sin autenticación**: Redirige a `PantallaLogin`
3. **Login exitoso**: Va a `PantallaSelectorApps`
4. **Selecciona/crea app**: Va al Dashboard principal

### Para usuario existente:
1. **Carga inicial**: `PantallaCarga` mientras se restaura sesión
2. **Sesión válida + app seleccionada**: Va directo al Dashboard
3. **Sesión válida + sin app**: Va a `PantallaSelectorApps`

## Diagnóstico de Problemas

### 1. Verificar estado de autenticación
```dart
// En DevTools, inspeccionar:
ref.read(sesionUsuarioProvider) // Debe mostrar el estado actual
ref.read(usuarioActualProvider) // Debe ser reactivo
```

### 2. Verificar logs de Supabase
- Abrir DevTools → Console
- Buscar errores de Supabase Auth
- Verificar que las credenciales en `.env` sean correctas

### 3. Verificar navegación
```dart
// En DevTools:
ref.read(appActualIdProvider) // App seleccionada actual
```

## Variables de Entorno

Asegúrate de que el archivo `.env` tenga:
```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_clave_anonima_muy_larga
```

## Comandos Útiles

```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run -d web-server --web-port 3000

# Hot restart (cuando hay cambios estructurales)
# En el terminal de Flutter: presionar "R"

# Hot reload (para cambios menores de UI)
# En el terminal de Flutter: presionar "r"
```

## Checklist de Verificación

- [ ] Variables de entorno configuradas correctamente
- [ ] Supabase proyecto configurado con las tablas necesarias
- [ ] Google OAuth configurado en Supabase
- [ ] Flutter dependencies actualizadas (`flutter pub get`)
- [ ] No hay errores de compilación
- [ ] La aplicación carga en localhost:3000
- [ ] Loading se oculta correctamente
- [ ] Redirige a login para usuarios nuevos

Si sigues teniendo problemas, revisa los logs en DevTools Console y compara con el código de referencia en los archivos del proyecto.