// ============================================
// PRODUCTO INVENTARIO PROVIDER - DEVUNI APP
// ============================================
// Provider Riverpod para la gestión completa de productos de inventario
// Integra con Supabase usando RLS y RPCs del backend auditado

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/supabase_providers.dart';
import '../../domain/models.dart';

/// Proveedor de lista de productos de inventario para la app seleccionada
/// Manejo automático de cache y actualizaciones en tiempo real
final productosInventarioProvider = StreamNotifierProvider.autoDispose
    .family<ProductosInventarioNotifier, List<ProductoInventario>, String>(
  ProductosInventarioNotifier.new,
);

/// Notifier para la gestión de productos de inventario
class ProductosInventarioNotifier
    extends AutoDisposeFamilyStreamNotifier<List<ProductoInventario>, String> {
  @override
  Stream<List<ProductoInventario>> build(String appId) async* {
    // Validar que tengamos una app seleccionada
    if (appId.isEmpty) {
      yield [];
      return;
    }

    final supabase = ref.read(supabaseClientProvider);

    try {
      // Stream con RLS automático - solo productos de la app actual
      final stream = supabase
          .from('productos_inventario')
          .stream(primaryKey: ['id'])
          .eq('app_id', appId)
          .order('nombre');

      await for (final data in stream) {
        final productos =
            data.map((json) => ProductoInventario.fromSupabase(json)).toList();
        yield productos;
      }
    } catch (error) {
      // En caso de error, devolver lista vacía y loguear
      print('Error en productosInventarioProvider: $error');
      yield [];
    }
  }

  /// Crear un nuevo producto de inventario
  Future<ProductoInventario?> crearProducto(ProductoInventario producto) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase
          .from('productos_inventario')
          .insert(producto.toSupabaseInsert())
          .select()
          .single();

      final nuevoProducto = ProductoInventario.fromSupabase(response);

      // El stream se actualizará automáticamente
      return nuevoProducto;
    } catch (error) {
      print('Error al crear producto: $error');
      throw Exception('No se pudo crear el producto: $error');
    }
  }

  /// Actualizar un producto existente
  Future<ProductoInventario?> actualizarProducto(
      ProductoInventario producto) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase
          .from('productos_inventario')
          .update(producto.toSupabaseUpdate())
          .eq('id', producto.id)
          .select()
          .single();

      final productoActualizado = ProductoInventario.fromSupabase(response);

      // El stream se actualizará automáticamente
      return productoActualizado;
    } catch (error) {
      print('Error al actualizar producto: $error');
      throw Exception('No se pudo actualizar el producto: $error');
    }
  }

  /// Eliminar un producto (soft delete)
  Future<bool> eliminarProducto(String productoId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      // Verificar si el producto tiene movimientos
      final movimientos = await supabase
          .from('movimientos_inventario')
          .select('id')
          .eq('producto_id', productoId)
          .limit(1);

      if (movimientos.isNotEmpty) {
        throw Exception(
            'No se puede eliminar el producto porque tiene movimientos de inventario');
      }

      await supabase.from('productos_inventario').delete().eq('id', productoId);

      // El stream se actualizará automáticamente
      return true;
    } catch (error) {
      print('Error al eliminar producto: $error');
      throw Exception('No se pudo eliminar el producto: $error');
    }
  }

  /// Buscar productos por término de búsqueda
  Future<List<ProductoInventario>> buscarProductos(String termino) async {
    if (termino.trim().isEmpty) {
      return state.value ?? [];
    }

    try {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase
          .from('productos_inventario')
          .select()
          .eq('app_id', arg)
          .or('nombre.ilike.%$termino%,codigo.ilike.%$termino%,descripcion.ilike.%$termino%')
          .order('nombre');

      return response
          .map((json) => ProductoInventario.fromSupabase(json))
          .toList();
    } catch (error) {
      print('Error al buscar productos: $error');
      return [];
    }
  }

  /// Obtener productos con stock bajo
  Future<List<ProductoInventario>> obtenerProductosStockBajo() async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      // Usar query directo para obtener productos con stock bajo
      final response = await supabase
          .from('productos_inventario')
          .select()
          .eq('app_id', arg)
          .or('stock_actual.lt.stock_minimo,stock_actual.eq.0')
          .order('stock_actual');

      return response
          .map((json) => ProductoInventario.fromSupabase(json))
          .toList();
    } catch (error) {
      print('Error al obtener productos con stock bajo: $error');
      return [];
    }
  }
}

/// Provider para un producto específico por ID
final productoInventarioPorIdProvider = StreamProvider.autoDispose
    .family<ProductoInventario?, String>((ref, productoId) {
  if (productoId.isEmpty) return Stream.value(null);

  final supabase = ref.read(supabaseClientProvider);

  return supabase
      .from('productos_inventario')
      .stream(primaryKey: ['id'])
      .eq('id', productoId)
      .map((data) {
        if (data.isEmpty) return null;
        return ProductoInventario.fromSupabase(data.first);
      });
});

/// Provider para estadísticas de productos
final estadisticasProductosProvider = FutureProvider.autoDispose
    .family<EstadisticasProductos, String>((ref, appId) async {
  if (appId.isEmpty) {
    return EstadisticasProductos.vacio();
  }

  try {
    final supabase = ref.read(supabaseClientProvider);

    // Obtener estadísticas con queries directos
    final productos = await supabase
        .from('productos_inventario')
        .select('stock_actual, stock_minimo, precio_venta')
        .eq('app_id', appId);

    int totalProductos = productos.length;
    int productosActivos = productos.where((p) => p['stock_actual'] > 0).length;
    int productosSinStock =
        productos.where((p) => p['stock_actual'] == 0).length;
    int productosStockBajo = productos.where((p) {
      final stockActual = p['stock_actual'] as double;
      final stockMinimo = p['stock_minimo'] as double?;
      return stockMinimo != null &&
          stockActual > 0 &&
          stockActual <= stockMinimo;
    }).length;

    double valorTotalInventario = productos.fold(0.0, (sum, p) {
      final stock = p['stock_actual'] as double;
      final precio = p['precio_venta'] as double?;
      return sum + (stock * (precio ?? 0.0));
    });

    return EstadisticasProductos(
      totalProductos: totalProductos,
      productosActivos: productosActivos,
      productosStockBajo: productosStockBajo,
      productosSinStock: productosSinStock,
      valorTotalInventario: valorTotalInventario,
    );
  } catch (error) {
    print('Error al obtener estadísticas de productos: $error');
    return EstadisticasProductos.vacio();
  }
});

/// Modelo para estadísticas de productos
class EstadisticasProductos {
  final int totalProductos;
  final int productosActivos;
  final int productosStockBajo;
  final int productosSinStock;
  final double valorTotalInventario;

  const EstadisticasProductos({
    required this.totalProductos,
    required this.productosActivos,
    required this.productosStockBajo,
    required this.productosSinStock,
    required this.valorTotalInventario,
  });

  factory EstadisticasProductos.fromJson(Map<String, dynamic> json) {
    return EstadisticasProductos(
      totalProductos: json['total_productos'] as int? ?? 0,
      productosActivos: json['productos_activos'] as int? ?? 0,
      productosStockBajo: json['productos_stock_bajo'] as int? ?? 0,
      productosSinStock: json['productos_sin_stock'] as int? ?? 0,
      valorTotalInventario:
          (json['valor_total_inventario'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory EstadisticasProductos.vacio() {
    return const EstadisticasProductos(
      totalProductos: 0,
      productosActivos: 0,
      productosStockBajo: 0,
      productosSinStock: 0,
      valorTotalInventario: 0.0,
    );
  }

  /// Porcentaje de productos con stock bajo
  double get porcentajeStockBajo {
    if (totalProductos == 0) return 0.0;
    return (productosStockBajo / totalProductos) * 100;
  }

  /// Porcentaje de productos sin stock
  double get porcentajeSinStock {
    if (totalProductos == 0) return 0.0;
    return (productosSinStock / totalProductos) * 100;
  }

  /// Valor promedio por producto
  double get valorPromedioPorProducto {
    if (productosActivos == 0) return 0.0;
    return valorTotalInventario / productosActivos;
  }
}
