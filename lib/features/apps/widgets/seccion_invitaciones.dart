import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../domain/entities/invitacion_entidad.dart';
import '../../../core/types/resultado.dart';

class SeccionInvitaciones extends ConsumerWidget {
  const SeccionInvitaciones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Resultado<List<InvitacionEntidad>>>(
      future: ref.watch(miembrosRepositoryProvider).obtenerMisInvitaciones(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final resultado = snapshot.data;
        if (resultado == null) {
          return const Center(child: Text('No hay datos'));
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
                    Text('No tienes invitaciones pendientes'),
                    SizedBox(height: 8),
                    Text('Las invitaciones a aplicaciones aparecerán aquí'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: invitaciones.length,
              itemBuilder: (context, index) {
                return TarjetaInvitacion(
                  invitacion: invitaciones[index],
                  onAceptar: () => _aceptarInvitacion(
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

  Future<void> _aceptarInvitacion(
    BuildContext context,
    WidgetRef ref,
    InvitacionEntidad invitacion,
  ) async {
    try {
      final miembrosRepo = ref.read(miembrosRepositoryProvider);
      final resultado = await miembrosRepo.aceptarInvitacion(invitacion.appId);

      if (context.mounted) {
        resultado.fold(
          siExito: (miembro) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invitación aceptada exitosamente'),
              ),
            );
            
            // Refrescar la vista
            // TODO: Implementar refresh
            
            // Seleccionar la app automáticamente
            ref.read(appActualIdProvider.notifier).state = invitacion.appId;
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

class TarjetaInvitacion extends StatelessWidget {
  final InvitacionEntidad invitacion;
  final VoidCallback onAceptar;

  const TarjetaInvitacion({
    super.key,
    required this.invitacion,
    required this.onAceptar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mail,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invitación pendiente',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Rol: ${invitacion.rol.nombre}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    invitacion.rol.nombre.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Información adicional
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Invitada ${_formatearFecha(invitacion.creadoEn)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: onAceptar,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Aceptar'),
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays > 0) {
      return 'hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return 'hace ${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else if (diferencia.inMinutes > 0) {
      return 'hace ${diferencia.inMinutes} minuto${diferencia.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }
}