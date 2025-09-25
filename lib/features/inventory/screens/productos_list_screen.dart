import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/responsive_widgets.dart';
import '../../apps/providers/apps_provider.dart';
import '../../../data/providers.dart';
import '../../../domain/models.dart';

class ProductosListScreen extends ConsumerStatefulWidget {
  const ProductosListScreen({super.key});

  @override
  ConsumerState<ProductosListScreen> createState() =>
      _ProductosListScreenState();
}

class _ProductosListScreenState extends ConsumerState<ProductosListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedApp = ref.watch(selectedAppProvider);

    if (selectedApp == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Productos'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apps, size: 64, color: AppColors.onSurfaceVariant),
              SizedBox(height: 16),
              Text(
                'Selecciona una app para ver los productos',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final productosAsync =
        ref.watch(productosInventarioProvider(selectedApp.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos de Inventario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/dashboard/inventario/agregar');
            },
            tooltip: 'Agregar Producto',
          ),
        ],
      ),
      body: productosAsync.when(
        data: (productos) => _buildProductosList(productos),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando productos...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al cargar productos',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(productosInventarioProvider);
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductosList(List<ProductoInventario> productos) {
    // Filtrar productos por búsqueda
    final filteredProducts = productos.where((producto) {
      if (_searchTerm.isEmpty) return true;
      return producto.nombre.toLowerCase().contains(_searchTerm) ||
          (producto.sku.toLowerCase().contains(_searchTerm)) ||
          (producto.descripcion?.toLowerCase().contains(_searchTerm) ?? false);
    }).toList();

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              productos.isEmpty ? Icons.inventory_2_outlined : Icons.search_off,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              productos.isEmpty
                  ? 'No hay productos registrados'
                  : 'No se encontraron productos',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productos.isEmpty
                  ? 'Agrega tu primer producto presionando el botón +'
                  : 'Intenta con otros términos de búsqueda',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            if (productos.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/dashboard/inventario/agregar'),
                icon: const Icon(Icons.add),
                label: const Text('Agregar Producto'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        // Barra de búsqueda
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchTerm.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchTerm = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchTerm = value.toLowerCase();
              });
            },
          ),
        ),

        // Lista de productos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final producto = filteredProducts[index];
              return _buildProductoCard(producto);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductoCard(ProductoInventario producto) {
    return ResponsiveCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _onProductoTap(producto),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y estado
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: AppTypography.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${producto.sku}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Estado activo/inactivo
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: producto.activo
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    producto.activo ? 'Activo' : 'Inactivo',
                    style: AppTypography.labelSmall.copyWith(
                      color:
                          producto.activo ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),

            // Descripción si existe
            if (producto.descripcion?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                producto.descripcion!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Footer con precio y fechas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (producto.precioUnitario != null)
                  Text(
                    '\$${producto.precioUnitario!.toStringAsFixed(2)}',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    'Sin precio',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                Text(
                  'Creado: ${_formatDate(producto.creadoEn)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onProductoTap(ProductoInventario producto) {
    // TODO: Navegar a detalle o mostrar opciones
    context.go('/dashboard/inventario/editar/${producto.id}');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
