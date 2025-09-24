import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers/app_providers.dart';
import '../../domain/entities/app_entidad.dart';
import '../../core/types/resultado.dart';

class PantallaDetalleApp extends ConsumerWidget {
  const PantallaDetalleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appId = ref.watch(appActualIdProvider);
    final usuario = ref.watch(usuarioActualProvider);
    final verificador = ref.watch(verificadorPermisosProvider);

    if (appId == null) {
      // Esto no debería pasar por las guardias de ruta, pero por seguridad
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/apps');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<Resultado<AppEntidad?>>(
      future: ref.watch(appsRepositoryProvider).obtenerAppPorId(appId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final resultado = snapshot.data;
        if (resultado == null) {
          return const Scaffold(
            body: Center(child: Text('Error al cargar la aplicación')),
          );
        }

        return resultado.fold(
          siExito: (app) {
            if (app == null) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64),
                      const SizedBox(height: 16),
                      const Text('Aplicación no encontrada'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/apps'),
                        child: const Text('Volver a Apps'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return _AppDashboard(app: app);
          },
          siError: (error) => Scaffold(
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
                  Text('Error: ${error.mensajeUsuario}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/apps'),
                    child: const Text('Volver a Apps'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AppDashboard extends ConsumerWidget {
  final AppEntidad app;

  const _AppDashboard({required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final usuario = ref.watch(usuarioActualProvider);
    final verificador = ref.watch(verificadorPermisosProvider);
    final rolActual = ref.watch(rolUsuarioActualProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(app.nombre),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(appActualIdProvider.notifier).state = null;
            context.go('/apps');
          },
        ),
        actions: [
          // Indicador de rol
          if (rolActual.hasValue && rolActual.value != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rolActual.value!.nombre,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          // Avatar del usuario
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: usuario?.userMetadata?['avatar_url'] != null
                  ? NetworkImage(usuario!.userMetadata!['avatar_url'] as String)
                  : null,
              child: usuario?.userMetadata?['avatar_url'] == null
                  ? Text(
                      usuario?.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la app
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.nombre,
                                style: theme.textTheme.headlineSmall,
                              ),
                              if (app.descripcion != null)
                                Text(
                                  app.descripcion!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Módulos principales
            Text(
              'Módulos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid de módulos
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _ModuloCard(
                  titulo: 'Inventario',
                  descripcion: 'Gestión de productos y stock',
                  icono: Icons.inventory,
                  color: Colors.blue,
                  onTap: () => context.go('/inventario'),
                  habilitado: verificador.puedeVer,
                ),
                if (verificador.puedeAdministrar)
                  _ModuloCard(
                    titulo: 'Miembros',
                    descripcion: 'Gestión de usuarios y roles',
                    icono: Icons.group,
                    color: Colors.green,
                    onTap: () => context.go('/miembros'),
                    habilitado: true,
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Accesos rápidos
            Text(
              'Accesos Rápidos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (verificador.puedeEditar)
                  ActionChip(
                    avatar: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Nuevo Movimiento'),
                    onPressed: () => context.go('/inventario/movimientos'),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.assessment, size: 18),
                  label: const Text('Ver Stock'),
                  onPressed: () => context.go('/inventario/stock'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.history, size: 18),
                  label: const Text('Historial'),
                  onPressed: () => context.go('/inventario/movimientos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuloCard extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color color;
  final VoidCallback? onTap;
  final bool habilitado;

  const _ModuloCard({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.color,
    this.onTap,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: habilitado ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habilitado ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icono,
                  color: habilitado ? color : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: habilitado ? null : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                descripcion,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: habilitado 
                      ? theme.colorScheme.onSurfaceVariant 
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}