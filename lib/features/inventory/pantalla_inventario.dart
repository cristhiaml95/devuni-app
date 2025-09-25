import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/supabase_providers.dart';
import '../../features/apps/providers/apps_provider.dart';
import '../../data/providers.dart';
import '../../domain/models.dart';
import '../../core/theme/app_colors.dart';

class PantallaInventario extends ConsumerStatefulWidget {
  const PantallaInventario({super.key});

  @override
  ConsumerState<PantallaInventario> createState() => _PantallaInventarioState();
}

class _PantallaInventarioState extends ConsumerState<PantallaInventario>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Productos', icon: Icon(Icons.inventory)),
            Tab(text: 'Categorías', icon: Icon(Icons.category)),
            Tab(text: 'Unidades', icon: Icon(Icons.straighten)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/apps/current/movimientos'),
            tooltip: 'Ver movimientos',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TabProductos(),
          _TabCategorias(),
          _TabUnidadesMedida(),
        ],
      ),
      floatingActionButton: _getFabPorTab(),
    );
  }

  Widget? _getFabPorTab() {
    switch (_tabController.index) {
      case 0: // Productos
        return FloatingActionButton.extended(
          onPressed: () => context.push('/apps/current/productos/crear'),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Producto'),
        );
      case 1: // Categorías
        return FloatingActionButton.extended(
          onPressed: () => _mostrarDialogoCrearCategoria(),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Categoría'),
        );
      case 2: // Unidades
        return FloatingActionButton.extended(
          onPressed: () => _mostrarDialogoCrearUnidad(),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Unidad'),
        );
      default:
        return null;
    }
  }

  void _mostrarDialogoCrearCategoria() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crear categoría - En construcción')),
    );
  }

  void _mostrarDialogoCrearUnidad() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crear unidad - En construcción')),
    );
  }
}

class _TabProductos extends ConsumerWidget {
  const _TabProductos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedApp = ref.watch(selectedAppProvider);

    if (selectedApp == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay una app seleccionada'),
          ],
        ),
      );
    }

    final productosAsync =
        ref.watch(productosInventarioProvider(selectedApp.id));

    return productosAsync.when(
      data: (productos) {
        if (productos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay productos'),
                SizedBox(height: 8),
                Text('Crea tu primer producto para comenzar'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final producto = productos[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(producto.nombre),
                subtitle: Text('SKU: ${producto.sku}'),
                trailing: producto.activo
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
                onTap: () => context.push(
                  '/apps/current/productos/${producto.id}',
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.invalidate(productosInventarioProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabCategorias extends ConsumerWidget {
  const _TabCategorias();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedApp = ref.watch(selectedAppProvider);

    if (selectedApp == null) {
      return const Center(child: Text('No hay una app seleccionada'));
    }

    final categoriasAsync =
        ref.watch(categoriasInventarioProvider(selectedApp.id));

    return categoriasAsync.when(
      data: (categorias) {
        if (categorias.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay categorías'),
                SizedBox(height: 8),
                Text('Crea tu primera categoría para organizar productos'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categorias.length,
          itemBuilder: (context, index) {
            final categoria = categorias[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.category),
                title: Text(categoria.nombre),
                subtitle: categoria.descripcion != null
                    ? Text(categoria.descripcion!)
                    : null,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }
}

class _TabUnidadesMedida extends ConsumerWidget {
  const _TabUnidadesMedida();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedApp = ref.watch(selectedAppProvider);

    if (selectedApp == null) {
      return const Center(child: Text('No hay una app seleccionada'));
    }

    final unidadesAsync = ref.watch(unidadesMedidaProvider(selectedApp.id));

    return unidadesAsync.when(
      data: (unidades) {
        if (unidades.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.straighten_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay unidades de medida'),
                SizedBox(height: 8),
                Text('Crea unidades para cuantificar productos'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: unidades.length,
          itemBuilder: (context, index) {
            final unidad = unidades[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.straighten),
                title: Text(unidad.nombre),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Código: ${unidad.codigo}'),
                    if (unidad.descripcion != null) Text(unidad.descripcion!),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }
}
