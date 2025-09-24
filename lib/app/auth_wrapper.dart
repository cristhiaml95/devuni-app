import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/providers/supabase_providers.dart';
import '../features/auth/login_screen.dart';
import '../features/apps/screens/apps_selector_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializar OAuth para web (no bloquea la UI)
    ref.watch(oauthInitializerProvider);

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
                  ref.invalidate(authStateProvider);
                },
                child: const Text('Saltar si toma mucho tiempo'),
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
                  ref.invalidate(authStateProvider);
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),

      // Estado cargado correctamente
      data: (authData) {
        if (isAuthenticated) {
          // Usuario autenticado - mostrar selector de Apps multi-tenant
          return const AppsSelectorScreen();
        } else {
          // Usuario no autenticado - mostrar login
          return const LoginScreen();
        }
      },
    );
  }
}
