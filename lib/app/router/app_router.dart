import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_wrapper.dart';
import '../../features/apps/screens/apps_selector_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/inventory/screens/productos_list_screen.dart';
import '../../features/inventory/screens/producto_form_screen.dart';

/// Provider del router principal de la aplicación
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    // Manejar errores de ruta desconocida
    errorBuilder: (context, state) {
      print('🚫 ROUTER: Ruta no encontrada: ${state.uri}');
      // Si hay un fragment con access_token, redirigir al AuthWrapper
      if (state.uri.fragment.contains('access_token')) {
        print('🔗 ROUTER: Detectado token OAuth, redirigiendo a AuthWrapper');
        return const AuthWrapper();
      }
      // Para otras rutas desconocidas, mostrar también el AuthWrapper
      return const AuthWrapper();
    },
    routes: [
      // Ruta raíz - AuthWrapper maneja auth
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthWrapper(),
      ),

      // Selector de Apps (después de login)
      GoRoute(
        path: '/apps',
        builder: (context, state) => const AppsSelectorScreen(),
      ),

      // Dashboard principal (después de seleccionar app)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          // Inventario principal
          GoRoute(
            path: 'inventario',
            builder: (context, state) => const ProductosListScreen(),
            routes: [
              // Agregar producto
              GoRoute(
                path: 'agregar',
                builder: (context, state) => const ProductoFormScreen(),
              ),
              // Editar producto
              GoRoute(
                path: 'editar/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProductoFormScreen(productoId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
