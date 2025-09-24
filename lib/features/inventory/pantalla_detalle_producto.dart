import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers/app_providers.dart';
import '../../domain/entities/producto_entidad.dart';
import '../../core/types/resultado.dart';

class PantallaDetalleProducto extends ConsumerWidget {
  final String productoId;

  const PantallaDetalleProducto({
    super.key,
    required this.productoId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appId = ref.watch(appActualIdProvider);
    if (appId == null) {
      return const Scaffold(
        body: Center(child: Text('No hay aplicación seleccionada')),
      );
    }

    return FutureBuilder<Resultado<ProductoEntidad>>(
      future: ref.watch(inventarioRepositoryProvider).obtenerProducto(productoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final resultado = snapshot.data;
        if (resultado == null) {
          return const Scaffold(
            body: Center(child: Text('Error al cargar producto')),
          );
        }

        return resultado.fold(
          siExito: (producto) => _PantallaProductoContenido(producto: producto),
          siError: (error) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
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
                    onPressed: () => context.go('/apps/current/inventario'),
                    child: const Text('Volver'),
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

class _PantallaProductoContenido extends ConsumerWidget {
  final ProductoEntidad producto;

  const _PantallaProductoContenido({required this.producto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final verificador = ref.watch(verificadorPermisosProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        actions: [
          if (verificador.puedeEditar)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push(
                '/apps/current/productos/${producto.id}/editar',
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información básica
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información General',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _CampoInfo(
                      etiqueta: 'Código',
                      valor: producto.codigo,
                      icono: Icons.qr_code,
                    ),
                    _CampoInfo(
                      etiqueta: 'Nombre',
                      valor: producto.nombre,
                      icono: Icons.inventory_2,
                    ),
                    if (producto.descripcion?.isNotEmpty == true)
                      _CampoInfo(
                        etiqueta: 'Descripción',
                        valor: producto.descripcion!,
                        icono: Icons.description,
                      ),
                    if (producto.ubicacion?.isNotEmpty == true)
                      _CampoInfo(
                        etiqueta: 'Ubicación',
                        valor: producto.ubicacion!,
                        icono: Icons.location_on,
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Stock y unidades
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _TarjetaNumero(
                            titulo: 'Stock Actual',
                            valor: producto.stockActual.toString(),
                            unidad: producto.unidadBase,
                            color: producto.tieneStockBajo
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                            icono: Icons.inventory,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _TarjetaNumero(
                            titulo: 'Stock Mínimo',
                            valor: producto.stockMinimo.toString(),
                            unidad: producto.unidadBase,
                            color: theme.colorScheme.secondary,
                            icono: Icons.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Precio
            if (producto.tienePrecio)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precio',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _TarjetaNumero(
                        titulo: 'Precio Unitario',
                        valor: '\$${producto.precio!.toStringAsFixed(2)}',
                        unidad: 'por ${producto.unidadBase}',
                        color: theme.colorScheme.tertiary,
                        icono: Icons.attach_money,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Estado y fechas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          producto.activo 
                              ? Icons.check_circle 
                              : Icons.cancel,
                          color: producto.activo 
                              ? Colors.green 
                              : theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          producto.activo ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: producto.activo 
                                ? Colors.green 
                                : theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _CampoInfo(
                      etiqueta: 'Creado',
                      valor: _formatearFecha(producto.creadoEn),
                      icono: Icons.calendar_today,
                    ),
                    _CampoInfo(
                      etiqueta: 'Actualizado',
                      valor: _formatearFecha(producto.actualizadoEn),
                      icono: Icons.update,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: verificador.puedeCrear
          ? FloatingActionButton.extended(
              onPressed: () => _mostrarDialogoMovimiento(context, ref),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Registrar Movimiento'),
            )
          : null,
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute}';
  }

  void _mostrarDialogoMovimiento(BuildContext context, WidgetRef ref) {
    // TODO: Implementar diálogo de movimiento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrar movimiento - En construcción')),
    );
  }
}

class _CampoInfo extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final IconData icono;

  const _CampoInfo({
    required this.etiqueta,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(valor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaNumero extends StatelessWidget {
  final String titulo;
  final String valor;
  final String unidad;
  final Color color;
  final IconData icono;

  const _TarjetaNumero({
    required this.titulo,
    required this.valor,
    required this.unidad,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unidad,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}