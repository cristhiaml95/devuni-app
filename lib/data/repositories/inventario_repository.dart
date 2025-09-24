import '../../core/types/resultado.dart';
import '../../domain/entities/unidad_medida_entidad.dart';
import '../../domain/entities/movimiento_inventario_entidad.dart';
import '../../domain/entities/tipo_movimiento.dart';
import '../clients/supabase_client.dart';

class InventarioRepository {
  final SupabaseClientService _client;

  InventarioRepository(this._client);

  // ===== UNIDADES DE MEDIDA =====
  Future<Resultado<List<UnidadMedidaEntidad>>> obtenerUnidadesMedida(
    String appId,
  ) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('unidades_medida')
          .select()
          .eq('app_id', appId)
          .order('nombre');

      return (response as List)
          .map((json) => UnidadMedidaEntidad.fromJson(json))
          .toList();
    });
  }

  Future<Resultado<UnidadMedidaEntidad>> crearUnidad({
    required String appId,
    required String codigo,
    required String nombre,
    String? descripcion,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('unidades_medida')
          .insert({
            'app_id': appId,
            'codigo': codigo,
            'nombre': nombre,
            'descripcion': descripcion,
          })
          .select()
          .single();

      return UnidadMedidaEntidad.fromJson(response);
    });
  }

  Future<Resultado<UnidadMedidaEntidad>> actualizarUnidad({
    required String id,
    required String codigo,
    required String nombre,
    String? descripcion,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('unidades_medida')
          .update({
            'codigo': codigo,
            'nombre': nombre,
            'descripcion': descripcion,
          })
          .eq('id', id)
          .select()
          .single();

      return UnidadMedidaEntidad.fromJson(response);
    });
  }

  Future<Resultado<void>> eliminarUnidad(String id) async {
    return _client.ejecutarQuery(() async {
      await _client.client.from('unidades_medida').delete().eq('id', id);
    });
  }

  // ===== CATEGORÍAS =====
  Future<Resultado<List<CategoriaInventarioEntidad>>> obtenerCategorias(
    String appId,
  ) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('categorias_inventario')
          .select()
          .eq('app_id', appId)
          .order('nombre');

      return (response as List)
          .map((json) => CategoriaInventarioEntidad.fromJson(json))
          .toList();
    });
  }

  Future<Resultado<CategoriaInventarioEntidad>> crearCategoria({
    required String appId,
    required String nombre,
    String? descripcion,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('categorias_inventario')
          .insert({
            'app_id': appId,
            'nombre': nombre,
            'descripcion': descripcion,
          })
          .select()
          .single();

      return CategoriaInventarioEntidad.fromJson(response);
    });
  }

  Future<Resultado<CategoriaInventarioEntidad>> actualizarCategoria({
    required String id,
    required String nombre,
    String? descripcion,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('categorias_inventario')
          .update({
            'nombre': nombre,
            'descripcion': descripcion,
          })
          .eq('id', id)
          .select()
          .single();

      return CategoriaInventarioEntidad.fromJson(response);
    });
  }

  Future<Resultado<void>> eliminarCategoria(String id) async {
    return _client.ejecutarQuery(() async {
      await _client.client.from('categorias_inventario').delete().eq('id', id);
    });
  }

  // ===== ALMACENES =====
  Future<Resultado<List<AlmacenEntidad>>> obtenerAlmacenes(String appId) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('almacenes')
          .select()
          .eq('app_id', appId)
          .order('nombre');

      return (response as List)
          .map((json) => AlmacenEntidad.fromJson(json))
          .toList();
    });
  }

  Future<Resultado<AlmacenEntidad>> crearAlmacen({
    required String appId,
    required String nombre,
    String? direccion,
    String? notas,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('almacenes')
          .insert({
            'app_id': appId,
            'nombre': nombre,
            'direccion': direccion,
            'notas': notas,
          })
          .select()
          .single();

      return AlmacenEntidad.fromJson(response);
    });
  }

  Future<Resultado<AlmacenEntidad>> actualizarAlmacen({
    required String id,
    required String nombre,
    String? direccion,
    String? notas,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('almacenes')
          .update({
            'nombre': nombre,
            'direccion': direccion,
            'notas': notas,
          })
          .eq('id', id)
          .select()
          .single();

      return AlmacenEntidad.fromJson(response);
    });
  }

  Future<Resultado<void>> eliminarAlmacen(String id) async {
    return _client.ejecutarQuery(() async {
      await _client.client.from('almacenes').delete().eq('id', id);
    });
  }

  // ===== PRODUCTOS =====
  Future<Resultado<List<ProductoInventarioEntidad>>> obtenerProductos(
    String appId, {
    String? busqueda,
    int? limite,
    int? offset,
  }) async {
    return _client.ejecutarQuery(() async {
      var query = _client.client
          .from('productos_inventario')
          .select()
          .eq('app_id', appId)
          .eq('activo', true);

      if (busqueda != null && busqueda.isNotEmpty) {
        query = query.or('sku.ilike.%$busqueda%,nombre.ilike.%$busqueda%');
      }

      if (limite != null) {
        query = query.limit(limite);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limite ?? 50) - 1);
      }

      final response = await query.order('nombre');

      return (response as List)
          .map((json) => ProductoInventarioEntidad.fromJson(json))
          .toList();
    });
  }

  Future<Resultado<ProductoInventarioEntidad>> crearProducto({
    required String appId,
    required String sku,
    required String nombre,
    String? descripcion,
    String? categoriaId,
    String? unidadId,
    double? precioUnitario,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('productos_inventario')
          .insert({
            'app_id': appId,
            'sku': sku,
            'nombre': nombre,
            'descripcion': descripcion,
            'categoria_id': categoriaId,
            'unidad_id': unidadId,
            'precio_unitario': precioUnitario,
          })
          .select()
          .single();

      return ProductoInventarioEntidad.fromJson(response);
    });
  }

  Future<Resultado<ProductoInventarioEntidad>> actualizarProducto({
    required String id,
    required String sku,
    required String nombre,
    String? descripcion,
    String? categoriaId,
    String? unidadId,
    double? precioUnitario,
    bool? activo,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('productos_inventario')
          .update({
            'sku': sku,
            'nombre': nombre,
            'descripcion': descripcion,
            'categoria_id': categoriaId,
            'unidad_id': unidadId,
            'precio_unitario': precioUnitario,
            'activo': activo,
          })
          .eq('id', id)
          .select()
          .single();

      return ProductoInventarioEntidad.fromJson(response);
    });
  }

  Future<Resultado<void>> eliminarProducto(String id) async {
    return _client.ejecutarQuery(() async {
      await _client.client
          .from('productos_inventario')
          .update({'activo': false})
          .eq('id', id);
    });
  }

  // ===== MOVIMIENTOS =====
  Future<Resultado<MovimientoInventarioEntidad>> registrarMovimiento({
    required String appId,
    required String productoId,
    required TipoMovimientoInventario tipo,
    required double cantidad,
    String? almacenId,
    double? costoUnitario,
    String? referencia,
  }) async {
    return _client.ejecutarRpc<MovimientoInventarioEntidad>(
      'registrar_movimiento_inventario',
      {
        'p_app_id': appId,
        'p_producto_id': productoId,
        'p_tipo': tipo.toSupabaseString(),
        'p_cantidad': cantidad,
        'p_almacen_id': almacenId,
        'p_costo_unitario': costoUnitario,
        'p_referencia': referencia,
      },
      (data) => MovimientoInventarioEntidad.fromJson(data[0]),
    );
  }

  Future<Resultado<List<MovimientoInventarioEntidad>>> obtenerMovimientos(
    String appId, {
    String? productoId,
    String? almacenId,
    int? limite,
    int? offset,
  }) async {
    return _client.ejecutarQuery(() async {
      var query = _client.client
          .from('movimientos_inventario')
          .select()
          .eq('app_id', appId);

      if (productoId != null) {
        query = query.eq('producto_id', productoId);
      }

      if (almacenId != null) {
        query = query.eq('almacen_id', almacenId);
      }

      if (limite != null) {
        query = query.limit(limite);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limite ?? 50) - 1);
      }

      final response = await query.order('fecha_movimiento', ascending: false);

      return (response as List)
          .map((json) => MovimientoInventarioEntidad.fromJson(json))
          .toList();
    });
  }

  // ===== STOCK =====
  Future<Resultado<List<StockActualEntidad>>> obtenerStock(String appId) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('vista_stock_actual_por_producto')
          .select()
          .eq('app_id', appId)
          .order('nombre');

      return (response as List)
          .map((json) => StockActualEntidad.fromJson(json))
          .toList();
    });
  }

  Future<Resultado<List<StockPorAlmacenEntidad>>> obtenerStockPorAlmacen(
    String appId,
  ) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('vista_stock_actual_por_producto_y_almacen')
          .select()
          .eq('app_id', appId)
          .order('nombre');

      return (response as List)
          .map((json) => StockPorAlmacenEntidad.fromJson(json))
          .toList();
    });
  }
}