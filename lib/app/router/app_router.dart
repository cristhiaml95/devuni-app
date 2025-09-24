import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/app_providers.dart';
import '../../features/apps/pantalla_selector_apps.dart';
import '../../features/apps/pantalla_detalle_app.dart';
import '../../features/inventory/pantalla_inventario.dart';
import '../../features/inventory/pantalla_detalle_producto.dart';
import '../../features/members/pantalla_miembros.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final appActualId = ref.watch(appActualIdProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Solo manejar redirección entre apps/home ya que la auth se maneja en main.dart
      final tieneAppSeleccionada = appActualId != null;
      final location = state.fullPath ?? '/';

      // Si no tiene app seleccionada y no está en selector, ir a selector
      if (!tieneAppSeleccionada && location != '/apps') {
        return '/apps';
      }

      // Si tiene app y está en apps, ir a home
      if (tieneAppSeleccionada && location == '/apps') {
        return '/';
      }

      return null; // No redirigir
    },
    routes: [
      // Selector de apps
      GoRoute(
        path: '/apps',
        builder: (context, state) => const PantallaSelectorApps(),
      ),

      // App principal (dashboard)
      GoRoute(
        path: '/',
        builder: (context, state) => const PantallaDetalleApp(),
        routes: [
          // Inventario
          GoRoute(
            path: 'inventario',
            builder: (context, state) => const PantallaInventario(),
          ),
          
          // Productos
          GoRoute(
            path: 'productos/:id',
            builder: (context, state) {
              final productoId = state.pathParameters['id']!;
              return PantallaDetalleProducto(productoId: productoId);
            },
          ),

          // Miembros y configuración
          GoRoute(
            path: 'miembros',
            builder: (context, state) => const PantallaMiembros(),
          ),
        ],
      ),
    ],
  );
});

// Extensiones para navegación fácil
extension AppRouterExtension on GoRouter {
  void irALogin() => go('/login');
  void irASelectorApps() => go('/apps');
  void irAHome() => go('/');
  void irAInventario() => go('/inventario');
  void irAUnidades() => go('/inventario/unidades');
  void irACategorias() => go('/inventario/categorias');
  void irAAlmacenes() => go('/inventario/almacenes');
  void irAProductos() => go('/inventario/productos');
  void irAMovimientos() => go('/inventario/movimientos');
  void irAStock() => go('/inventario/stock');
  void irAMiembros() => go('/miembros');
}