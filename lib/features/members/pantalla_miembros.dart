import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers/app_providers.dart';
import '../../domain/entities/miembro_entidad.dart';
import '../../domain/entities/invitacion_entidad.dart';
import '../../domain/entities/rol_usuario.dart';
import '../../core/types/resultado.dart';
import 'widgets/dialogo_invitar_usuario.dart';

class PantallaMiembros extends ConsumerStatefulWidget {
  const PantallaMiembros({super.key});

  @override
  ConsumerState<PantallaMiembros> createState() => _PantallaMiembrosState();
}

class _PantallaMiembrosState extends ConsumerState<PantallaMiembros>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verificador = ref.watch(verificadorPermisosProvider);

    // Solo admins pueden ver esta pantalla
    if (!verificador.puedeAdministrar) {
      return Scaffold(
        appBar: AppBar(title: const Text('Miembros')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64),
              SizedBox(height: 16),
              Text('No tienes permisos para ver esta sección'),
              SizedBox(height: 8),
              Text('Se requiere rol de Administrador o superior'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Miembros'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Miembros', icon: Icon(Icons.group)),
            Tab(text: 'Invitaciones', icon: Icon(Icons.mail_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TabMiembros(),
          _TabInvitaciones(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoInvitar(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Invitar Usuario'),
      ),
    );
  }

  void _mostrarDialogoInvitar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DialogoInvitarUsuario(),
    );
  }
}

class _TabMiembros extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appId = ref.watch(appActualIdProvider);
    if (appId == null) return const SizedBox();

    return FutureBuilder<Resultado<List<MiembroEntidad>>>(
      future: ref.watch(miembrosRepositoryProvider).obtenerMiembros(appId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final resultado = snapshot.data;
        if (resultado == null) {
          return const Center(child: Text('Error al cargar miembros'));
        }

        return resultado.fold(
          siExito: (miembros) {
            if (miembros.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_outlined, size: 64),
                    SizedBox(height: 16),
                    Text('No hay miembros'),
                    SizedBox(height: 8),
                    Text('Los miembros de la aplicación aparecerán aquí'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: miembros.length,
              itemBuilder: (context, index) {
                return TarjetaMiembro(
                  miembro: miembros[index],
                  onCambiarRol: (nuevoRol) => _cambiarRol(
                    context,
                    ref,
                    miembros[index],
                    nuevoRol,
                  ),
                  onEliminar: () => _eliminarMiembro(
                    context,
                    ref,
                    miembros[index],
                  ),
                );
              },
            );
          },
          siError: (error) => Center(
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
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _cambiarRol(
    BuildContext context,
    WidgetRef ref,
    MiembroEntidad miembro,
    RolUsuarioApp nuevoRol,
  ) async {
    final appId = ref.read(appActualIdProvider);
    if (appId == null) return;

    try {
      final miembrosRepo = ref.read(miembrosRepositoryProvider);
      final resultado = await miembrosRepo.actualizarRolMiembro(
        appId: appId,
        userId: miembro.userId,
        nuevoRol: nuevoRol,
      );

      if (context.mounted) {
        resultado.fold(
          siExito: (miembroActualizado) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Rol actualizado a ${nuevoRol.nombre}'),
              ),
            );
            // TODO: Refrescar lista
          },
          siError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.mensajeUsuario}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _eliminarMiembro(
    BuildContext context,
    WidgetRef ref,
    MiembroEntidad miembro,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este miembro? '
          'Perderá acceso a la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    final appId = ref.read(appActualIdProvider);
    if (appId == null) return;

    try {
      final miembrosRepo = ref.read(miembrosRepositoryProvider);
      final resultado = await miembrosRepo.eliminarMiembro(
        appId: appId,
        userId: miembro.userId,
      );

      if (context.mounted) {
        resultado.fold(
          siExito: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Miembro eliminado')),
            );
            // TODO: Refrescar lista
          },
          siError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.mensajeUsuario}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _TabInvitaciones extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appId = ref.watch(appActualIdProvider);
    if (appId == null) return const SizedBox();

    return FutureBuilder<Resultado<List<InvitacionEntidad>>>(
      future: ref.watch(miembrosRepositoryProvider).obtenerInvitacionesApp(appId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final resultado = snapshot.data;
        if (resultado == null) {
          return const Center(child: Text('Error al cargar invitaciones'));
        }

        return resultado.fold(
          siExito: (invitaciones) {
            if (invitaciones.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline, size: 64),
                    SizedBox(height: 16),
                    Text('No hay invitaciones'),
                    SizedBox(height: 8),
                    Text('Las invitaciones enviadas aparecerán aquí'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: invitaciones.length,
              itemBuilder: (context, index) {
                return TarjetaInvitacionAdmin(
                  invitacion: invitaciones[index],
                  onCancelar: () => _cancelarInvitacion(
                    context,
                    ref,
                    invitaciones[index],
                  ),
                );
              },
            );
          },
          siError: (error) => Center(
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
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _cancelarInvitacion(
    BuildContext context,
    WidgetRef ref,
    InvitacionEntidad invitacion,
  ) async {
    try {
      final miembrosRepo = ref.read(miembrosRepositoryProvider);
      final resultado = await miembrosRepo.cancelarInvitacion(invitacion.id);

      if (context.mounted) {
        resultado.fold(
          siExito: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invitación cancelada')),
            );
            // TODO: Refrescar lista
          },
          siError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.mensajeUsuario}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class TarjetaMiembro extends StatelessWidget {
  final MiembroEntidad miembro;
  final Function(RolUsuarioApp) onCambiarRol;
  final VoidCallback onEliminar;

  const TarjetaMiembro({
    super.key,
    required this.miembro,
    required this.onCambiarRol,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            miembro.userId.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(miembro.userId), // TODO: Obtener nombre real del usuario
        subtitle: Text('Rol: ${miembro.rol.nombre}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<RolUsuarioApp>(
              icon: const Icon(Icons.more_vert),
              onSelected: onCambiarRol,
              itemBuilder: (context) => RolUsuarioApp.values
                  .where((rol) => rol != miembro.rol)
                  .map((rol) => PopupMenuItem(
                        value: rol,
                        child: Text('Cambiar a ${rol.nombre}'),
                      ))
                  .toList(),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              onPressed: onEliminar,
            ),
          ],
        ),
      ),
    );
  }
}

class TarjetaInvitacionAdmin extends StatelessWidget {
  final InvitacionEntidad invitacion;
  final VoidCallback onCancelar;

  const TarjetaInvitacionAdmin({
    super.key,
    required this.invitacion,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          _getIconoEstado(),
          color: _getColorEstado(theme),
        ),
        title: Text(invitacion.email),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rol: ${invitacion.rol.nombre}'),
            Text('Estado: ${invitacion.estado.toUpperCase()}'),
          ],
        ),
        trailing: invitacion.esPendiente
            ? IconButton(
                icon: Icon(
                  Icons.cancel_outlined,
                  color: theme.colorScheme.error,
                ),
                onPressed: onCancelar,
              )
            : null,
      ),
    );
  }

  IconData _getIconoEstado() {
    switch (invitacion.estado) {
      case 'pendiente':
        return Icons.schedule;
      case 'aceptada':
        return Icons.check_circle;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorEstado(ThemeData theme) {
    switch (invitacion.estado) {
      case 'pendiente':
        return theme.colorScheme.primary;
      case 'aceptada':
        return Colors.green;
      case 'cancelada':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}