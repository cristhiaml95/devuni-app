import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/providers/supabase_providers.dart';
import '../features/auth/login_screen.dart';
import '../features/apps/screens/apps_selector_screen.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _forceShowLogin = false;
  bool _hasShownLogin = false;

  @override
  void initState() {
    super.initState();

    // Timeout automático después de 5 segundos (aumentado para mejor UX)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_forceShowLogin && !_hasShownLogin) {
        print('⏰ Timeout de 5 segundos alcanzado, mostrando login');
        setState(() {
          _forceShowLogin = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar OAuth para web (no bloquea la UI)
    ref.watch(oauthInitializerProvider);

    // Si se forza mostrar login, ir directo al login
    if (_forceShowLogin) {
      return const LoginScreen();
    }

    // Escuchar el estado de autenticación
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return authState.when(
      // Cargando
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Conectando a Supabase...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Esto puede tomar unos segundos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  print('🔄 Usuario solicitó skip de loading');
                  setState(() {
                    _forceShowLogin = true;
                  });
                },
                child: const Text('Ir a login'),
              ),
            ],
          ),
        ),
      ),

      // Error
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error de conexión',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  print('🔄 Usuario solicitó reintentar conexión');
                  // Refrescar de manera más gentil sin invalidar todo el provider
                  final _ = ref.refresh(oauthInitializerProvider);
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),

      // Estado cargado correctamente
      data: (authData) {
        print(
            '🔐 AUTH_WRAPPER: Procesando estado auth - Event: ${authData.event}');
        print('🔐 AUTH_WRAPPER: Usuario autenticado: $isAuthenticated');

        if (isAuthenticated) {
          print('✅ AUTH_WRAPPER: Navegando a AppsSelectorScreen');

          // Marcar que ya se mostró contenido autenticado
          if (!_hasShownLogin) {
            _hasShownLogin = true;
          }

          // Usuario autenticado - mostrar selector de Apps multi-tenant
          return const AppsSelectorScreen();
        } else {
          // Solo mostrar login si no estamos en medio de un proceso de auth
          // o si es la primera vez
          if (!_hasShownLogin || authData.event == AuthChangeEvent.signedOut) {
            print('🚪 AUTH_WRAPPER: Navegando a LoginScreen');
            _hasShownLogin = true;
            return const LoginScreen();
          } else {
            // Mantener la pantalla actual mientras se resuelve el estado
            print(
                '⏳ AUTH_WRAPPER: Manteniendo estado mientras se resuelve auth');
            return const AppsSelectorScreen();
          }
        }
      },
    );
  }
}
