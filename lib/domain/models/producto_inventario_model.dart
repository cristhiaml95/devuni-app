// ============================================
// PRODUCTO INVENTARIO MODEL - DEVUNI APP
// ============================================
// Mapeo exacto de la tabla 'productos_inventario' del backend
// Fuente: Auditoría completa del 25 Sep 2025

/// Modelo de Producto de Inventario
/// Fuente DB: tabla public.productos_inventario
class ProductoInventario {
  /// ID único del producto (UUID)
  /// DB: productos_inventario.id (PRIMARY KEY)
  final String id;

  /// ID de la app a la que pertenece (UUID)
  /// DB: productos_inventario.app_id (FK → apps.id)
  final String appId;

  /// SKU único del producto por app
  /// DB: productos_inventario.sku (NOT NULL, UNIQUE con app_id)
  final String sku;

  /// Nombre del producto
  /// DB: productos_inventario.nombre (NOT NULL)
  final String nombre;

  /// Descripción opcional del producto
  /// DB: productos_inventario.descripcion (NULLABLE)
  final String? descripcion;

  /// ID de la categoría (opcional)
  /// DB: productos_inventario.categoria_id (FK → categorias_inventario.id SET NULL)
  final String? categoriaId;

  /// ID de la unidad de medida (opcional)
  /// DB: productos_inventario.unidad_id (FK → unidades_medida.id SET NULL)
  final String? unidadId;

  /// Precio unitario (opcional)
  /// DB: productos_inventario.precio_unitario (numeric(18,6))
  final double? precioUnitario;

  /// Estado activo/inactivo (soft delete)
  /// DB: productos_inventario.activo (DEFAULT true)
  final bool activo;

  /// Fecha de creación
  /// DB: productos_inventario.creado_en (DEFAULT now())
  final DateTime creadoEn;

  /// Fecha de última actualización (auto-actualizada por trigger)
  /// DB: productos_inventario.actualizado_en (DEFAULT now(), trigger: touch_actualizado_en)
  final DateTime actualizadoEn;

  const ProductoInventario({
    required this.id,
    required this.appId,
    required this.sku,
    required this.nombre,
    this.descripcion,
    this.categoriaId,
    this.unidadId,
    this.precioUnitario,
    this.activo = true,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  /// Constructor desde Map de Supabase (nombres de DB)
  factory ProductoInventario.fromSupabase(Map<String, dynamic> data) {
    return ProductoInventario(
      id: data['id'] as String,
      appId: data['app_id'] as String,
      sku: data['sku'] as String,
      nombre: data['nombre'] as String,
      descripcion: data['descripcion'] as String?,
      categoriaId: data['categoria_id'] as String?,
      unidadId: data['unidad_id'] as String?,
      precioUnitario: data['precio_unitario'] != null
          ? (data['precio_unitario'] as num).toDouble()
          : null,
      activo: data['activo'] as bool? ?? true,
      creadoEn: DateTime.parse(data['creado_en'] as String),
      actualizadoEn: DateTime.parse(data['actualizado_en'] as String),
    );
  }

  /// Constructor desde JSON
  factory ProductoInventario.fromJson(Map<String, dynamic> json) {
    return ProductoInventario.fromSupabase(json);
  }

  /// Convierte a Map para inserción en Supabase
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'app_id': appId,
      'sku': sku,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'unidad_id': unidadId,
      'precio_unitario': precioUnitario,
      'activo': activo,
    };
  }

  /// Convierte a Map para actualización en Supabase
  Map<String, dynamic> toSupabaseUpdate() {
    return {
      'sku': sku,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'unidad_id': unidadId,
      'precio_unitario': precioUnitario,
      'activo': activo,
    };
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() => toSupabaseInsert();

  /// Crea una copia con campos modificados
  ProductoInventario copyWith({
    String? id,
    String? appId,
    String? sku,
    String? nombre,
    String? descripcion,
    String? categoriaId,
    String? unidadId,
    double? precioUnitario,
    bool? activo,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return ProductoInventario(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      sku: sku ?? this.sku,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoriaId: categoriaId ?? this.categoriaId,
      unidadId: unidadId ?? this.unidadId,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductoInventario &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductoInventario{id: $id, sku: $sku, nombre: $nombre, activo: $activo}';
  }
}

/// Extensiones para funcionalidad adicional
extension ProductoInventarioExtensions on ProductoInventario {
  /// Validaciones de negocio
  List<String> validar() {
    final errores = <String>[];

    if (sku.trim().isEmpty) {
      errores.add('El SKU es requerido');
    }

    if (sku.trim().length < 2) {
      errores.add('El SKU debe tener al menos 2 caracteres');
    }

    if (sku.trim().length > 50) {
      errores.add('El SKU no puede exceder 50 caracteres');
    }

    if (nombre.trim().isEmpty) {
      errores.add('El nombre es requerido');
    }

    if (nombre.trim().length < 2) {
      errores.add('El nombre debe tener al menos 2 caracteres');
    }

    if (nombre.trim().length > 200) {
      errores.add('El nombre no puede exceder 200 caracteres');
    }

    if (descripcion != null && descripcion!.length > 500) {
      errores.add('La descripción no puede exceder 500 caracteres');
    }

    if (precioUnitario != null && precioUnitario! < 0) {
      errores.add('El precio unitario no puede ser negativo');
    }

    return errores;
  }

  /// Verifica si el producto es válido
  bool get esValido => validar().isEmpty;

  /// Precio formateado como string
  String get precioFormateado {
    if (precioUnitario == null) return 'Sin precio';
    return '\$${precioUnitario!.toStringAsFixed(2)}';
  }

  /// Estado como string para UI
  String get estadoTexto => activo ? 'Activo' : 'Inactivo';

  /// Color del estado para UI
  String get estadoColor => activo ? 'green' : 'red';

  /// Resumen del producto para listas
  String get resumen {
    final partes = <String>[sku];
    if (descripcion != null && descripcion!.isNotEmpty) {
      final desc = descripcion!.length > 50
          ? '${descripcion!.substring(0, 47)}...'
          : descripcion!;
      partes.add(desc);
    }
    return partes.join(' - ');
  }

  /// Indica si tiene precio definido
  bool get tienePrecio => precioUnitario != null && precioUnitario! > 0;

  /// Indica si tiene categoría asignada
  bool get tieneCategoria => categoriaId != null;

  /// Indica si tiene unidad de medida asignada
  bool get tieneUnidad => unidadId != null;

  /// Verifica si está completamente configurado
  bool get estaCompleto => tieneCategoria && tieneUnidad && tienePrecio;
}
