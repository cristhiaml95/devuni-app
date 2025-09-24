import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers/app_providers.dart';
import '../../domain/entities/unidad_medida_entidad.dart';
import '../../domain/entities/categoria_entidad.dart';
import '../../domain/entities/producto_entidad.dart';
import '../../core/types/resultado.dart';

class PantallaInventario extends ConsumerStatefulWidget {
  const PantallaInventario({super.key});

  @override
  ConsumerState<PantallaInventario> createState() =>
      _PantallaInventarioState();
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
    final verificador = ref.watch(verificadorPermisosProvider);

    // Solo colaboradores y superiores pueden ver esta pantalla
    if (!verificador.puedeCrear) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inventario')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64),
              SizedBox(height: 16),
              Text('No tienes permisos para ver esta sección'),
              SizedBox(height: 8),
              Text('Se requiere rol de Colaborador o superior'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        bottom: TabBar(
          controller: _tabController,
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
        children: [
          _TabProductos(),
          _TabCategorias(),
          _TabUnidadesMedida(),
        ],
      ),
      floatingActionButton: _getFabPorTab(),
    );
  }

  Widget? _getFabPorTab() {
    final verificador = ref.watch(verificadorPermisosProvider);
    if (!verificador.puedeCrear) return null;

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
    // TODO: Implementar diálogo para crear categoría
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crear categoría - En construcción')),
    );
  }

  void _mostrarDialogoCrearUnidad() {
    // TODO: Implementar diálogo para crear unidad de medida
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crear unidad - En construcción')),
    );
  }
}

class _TabProductos extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appId = ref.watch(appActualIdProvider);
    if (appId == null) return const SizedBox();

    return FutureBuilder<Resultado<List<ProductoEntidad>>>(
      future: ref.watch(inventarioRepositoryProvider).obtenerProductos(appId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final resultado = snapshot.data;
        if (resultado == null) {
          return const Center(child: Text('Error al cargar productos'));
        }

        return resultado.fold(
          siExito: (productos) {
            if (productos.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_outlined, size: 64),
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
                return TarjetaProducto(
                  producto: productos[index],
                  onTap: () => context.push(
                    '/apps/current/productos/${productos[index].id}',
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
}

class _TabCategorias extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appId = ref.watch(appActualIdProvider);
    if (appId == null) return const SizedBox();

    return FutureBuilder<Resultado<List<CategoriaEntidad>>>(
      future: ref.watch(inventarioRepositoryProvider).obtenerCategorias(appId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final resultado = snapshot.data;
        if (resultado == null) {
          return const Center(child: Text('Error al cargar categorías'));
        }

        return resultado.fold(
          siExito: (categorias) {
            if (categorias.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 64),
                    SizedBox(height: 16),
                    Text('No hay categorías'),
                    SizedBox(height: 8),
                    Text('Las categorías ayudan a organizar tus productos'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                return TarjetaCategoria(categoria: categorias[index]);
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
}

class _TabUnidadesMedida extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appId = ref.watch(appActualIdProvider);
    if (appId == null) return const SizedBox();

    return FutureBuilder<Resultado<List<UnidadMedidaEntidad>>>(
      future: ref.watch(inventarioRepositoryProvider).obtenerUnidadesMedida(appId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final resultado = snapshot.data;
        if (resultado == null) {
          return const Center(child: Text('Error al cargar unidades'));
        }

        return resultado.fold(
          siExito: (unidades) {
            if (unidades.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.straighten_outlined, size: 64),
                    SizedBox(height: 16),
                    Text('No hay unidades de medida'),
                    SizedBox(height: 8),
                    Text('Define unidades para medir tus productos'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: unidades.length,
              itemBuilder: (context, index) {
                return TarjetaUnidadMedida(unidad: unidades[index]);
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
}

class TarjetaProducto extends StatelessWidget {
  final ProductoEntidad producto;
  final VoidCallback onTap;

  const TarjetaProducto({
    super.key,
    required this.producto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.inventory_2,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(producto.nombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (producto.descripcion?.isNotEmpty == true)
              Text(producto.descripcion!),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Stock: ${producto.stockActual} ${producto.unidadBase}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: producto.stockActual <= producto.stockMinimo
            ? Icon(
                Icons.warning,
                color: theme.colorScheme.error,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class TarjetaCategoria extends StatelessWidget {
  final CategoriaEntidad categoria;

  const TarjetaCategoria({
    super.key,
    required this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            Icons.category,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(categoria.nombre),
        subtitle: categoria.descripcion?.isNotEmpty == true
            ? Text(categoria.descripcion!)
            : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class TarjetaUnidadMedida extends StatelessWidget {
  final UnidadMedidaEntidad unidad;

  const TarjetaUnidadMedida({
    super.key,
    required this.unidad,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.tertiaryContainer,
          child: Icon(
            Icons.straighten,
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
        title: Text(unidad.nombre),
        subtitle: Text('Símbolo: ${unidad.simbolo}'),
        trailing: unidad.esDecimal
            ? const Chip(
                label: Text('Decimal'),
                backgroundColor: Colors.green,
              )
            : null,
      ),
    );
  }
}