class ProductoInventarioEntidad {
  final String id;
  final String appId;
  final String sku;
  final String nombre;
  final String? descripcion;
  final String? categoriaId;
  final String? unidadId;
  final double? precioUnitario;
  final bool activo;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  const ProductoInventarioEntidad({
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

  factory ProductoInventarioEntidad.fromJson(Map<String, dynamic> json) {
    return ProductoInventarioEntidad(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      sku: json['sku'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      categoriaId: json['categoria_id'] as String?,
      unidadId: json['unidad_id'] as String?,
      precioUnitario: json['precio_unitario'] != null
          ? (json['precio_unitario'] as num).toDouble()
          : null,
      activo: json['activo'] as bool? ?? true,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      actualizadoEn: DateTime.parse(json['actualizado_en'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'sku': sku,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'unidad_id': unidadId,
      'precio_unitario': precioUnitario,
      'activo': activo,
      'creado_en': creadoEn.toIso8601String(),
      'actualizado_en': actualizadoEn.toIso8601String(),
    };
  }

  ProductoInventarioEntidad copyWith({
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
    return ProductoInventarioEntidad(
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductoInventarioEntidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductoInventarioEntidad(id: $id, sku: $sku, nombre: $nombre)';
  }
}