import '../../core/types/resultado.dart';
import '../../domain/entities/unidad_medida_entidad.dart';
import '../../domain/entities/categoria_entidad.dart';
import '../../domain/entities/producto_entidad.dart';
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

  Future<Resultado<UnidadMedidaEntidad>> crearUnidadMedida({
    required String appId,
    required String nombre,
    required String simbolo,
    required bool esDecimal,
    String? descripcion,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('unidades_medida')
          .insert({
            'app_id': appId,
            'nombre': nombre,
            'simbolo': simbolo,
            'es_decimal': esDecimal,
            'descripcion': descripcion,
          })
          .select()
          .single();

      return UnidadMedidaEntidad.fromJson(response);
    });
  }

  // ===== CATEGORÍAS =====
  Future<Resultado<List<CategoriaEntidad>>> obtenerCategorias(
    String appId,
  ) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('categorias')
          .select()
          .eq('app_id', appId)
          .order('nombre');

      return (response as List)
          .map((json) => CategoriaEntidad.fromJson(json))
          .toList();
    });
  }

  Future<Resultado<CategoriaEntidad>> crearCategoria({
    required String appId,
    required String nombre,
    String? descripcion,
    String? color,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('categorias')
          .insert({
            'app_id': appId,
            'nombre': nombre,
            'descripcion': descripcion,
            'color': color,
          })
          .select()
          .single();

      return CategoriaEntidad.fromJson(response);
    });
  }

  // ===== PRODUCTOS =====
  Future<Resultado<List<ProductoEntidad>>> obtenerProductos(
    String appId, {
    String? busqueda,
    int? limite,
    int? offset,
  }) async {
    return _client.ejecutarQuery(() async {
      var query = _client.client
          .from('productos')
          .select()
          .eq('app_id', appId);

      if (busqueda != null && busqueda.isNotEmpty) {
        query = query.or('nombre.ilike.%$busqueda%,codigo.ilike.%$busqueda%');
      }

      final response = await query.order('nombre');

      return (response as List)
          .map((json) => ProductoEntidad.fromJson(json))
          .toList();
    });
  }

  Future<Resultado<ProductoEntidad>> obtenerProducto(String productoId) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('productos')
          .select()
          .eq('id', productoId)
          .single();

      return ProductoEntidad.fromJson(response);
    });
  }

  Future<Resultado<ProductoEntidad>> crearProducto({
    required String appId,
    required String codigo,
    required String nombre,
    String? descripcion,
    required String categoriaId,
    required String unidadBase,
    required double stockMinimo,
    double? precio,
    String? ubicacion,
    Map<String, dynamic>? metadatos,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('productos')
          .insert({
            'app_id': appId,
            'codigo': codigo,
            'nombre': nombre,
            'descripcion': descripcion,
            'categoria_id': categoriaId,
            'unidad_base': unidadBase,
            'stock_actual': 0.0,
            'stock_minimo': stockMinimo,
            'precio': precio,
            'ubicacion': ubicacion,
            'activo': true,
            'metadatos': metadatos,
          })
          .select()
          .single();

      return ProductoEntidad.fromJson(response);
    });
  }

  Future<Resultado<ProductoEntidad>> actualizarProducto({
    required String productoId,
    String? codigo,
    String? nombre,
    String? descripcion,
    String? categoriaId,
    String? unidadBase,
    double? stockMinimo,
    double? precio,
    String? ubicacion,
    bool? activo,
    Map<String, dynamic>? metadatos,
  }) async {
    return _client.ejecutarQuery(() async {
      final updateData = <String, dynamic>{};
      
      if (codigo != null) updateData['codigo'] = codigo;
      if (nombre != null) updateData['nombre'] = nombre;
      if (descripcion != null) updateData['descripcion'] = descripcion;
      if (categoriaId != null) updateData['categoria_id'] = categoriaId;
      if (unidadBase != null) updateData['unidad_base'] = unidadBase;
      if (stockMinimo != null) updateData['stock_minimo'] = stockMinimo;
      if (precio != null) updateData['precio'] = precio;
      if (ubicacion != null) updateData['ubicacion'] = ubicacion;
      if (activo != null) updateData['activo'] = activo;
      if (metadatos != null) updateData['metadatos'] = metadatos;

      final response = await _client.client
          .from('productos')
          .update(updateData)
          .eq('id', productoId)
          .select()
          .single();

      return ProductoEntidad.fromJson(response);
    });
  }

  Future<Resultado<void>> eliminarProducto(String productoId) async {
    return _client.ejecutarQuery(() async {
      await _client.client
          .from('productos')
          .delete()
          .eq('id', productoId);
    });
  }
}