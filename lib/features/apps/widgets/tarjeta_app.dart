import 'package:flutter/material.dart';
import '../../../domain/entities/app_entidad.dart';

class TarjetaApp extends StatelessWidget {
  final AppEntidad app;
  final bool esPropietario;
  final VoidCallback onTap;

  const TarjetaApp({
    super.key,
    required this.app,
    required this.esPropietario,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono de la app
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Información de la app
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.nombre,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (app.descripcion != null && app.descripcion!.isNotEmpty)
                          Text(
                            app.descripcion!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  
                  // Badge de propietario
                  if (esPropietario)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PROPIETARIO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  
                  // Icono de flecha
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
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
                    'Creada ${_formatearFecha(app.creadoEn)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.launch, size: 16),
                    label: const Text('Abrir'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
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

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays > 365) {
      return 'hace ${(diferencia.inDays / 365).floor()} año${diferencia.inDays > 730 ? 's' : ''}';
    } else if (diferencia.inDays > 30) {
      return 'hace ${(diferencia.inDays / 30).floor()} mes${diferencia.inDays > 60 ? 'es' : ''}';
    } else if (diferencia.inDays > 0) {
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