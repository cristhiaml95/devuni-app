import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/providers/app_providers.dart';

class PantallaLogin extends ConsumerWidget {
  const PantallaLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo y título
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'DevUni',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Gestión de Inventarios Multi-App',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Descripción
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.security,
                        color: theme.colorScheme.secondary,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Iniciar Sesión',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Accede a tus aplicaciones compartidas y gestiona inventarios de forma colaborativa.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botón de login con Google
              ElevatedButton.icon(
                onPressed: () => _iniciarSesionConGoogle(context, ref),
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  height: 20,
                  width: 20,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.login,
                    size: 20,
                  ),
                ),
                label: const Text('Continuar con Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Información adicional
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Al iniciar sesión, aceptas nuestros términos de uso y política de privacidad.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _iniciarSesionConGoogle(BuildContext context, WidgetRef ref) async {
    try {
      final client = ref.read(supabaseClientProvider);
      
      // Mostrar indicador de carga
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Iniciando sesión...'),
              ],
            ),
          ),
        );
      }
      
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.devuni://login-callback/',
      );
      
      // El cambio de estado se maneja automáticamente por el stream provider
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar dialog de carga
      }
      
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar dialog de carga
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}