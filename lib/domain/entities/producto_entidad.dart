class ProductoEntidad {
  final String id;
  final String appId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String categoriaId;
  final String unidadBase;
  final double stockActual;
  final double stockMinimo;
  final double? precio;
  final String? ubicacion;
  final bool activo;
  final Map<String, dynamic>? metadatos;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  const ProductoEntidad({
    required this.id,
    required this.appId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.categoriaId,
    required this.unidadBase,
    required this.stockActual,
    required this.stockMinimo,
    this.precio,
    this.ubicacion,
    required this.activo,
    this.metadatos,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  factory ProductoEntidad.fromJson(Map<String, dynamic> json) {
    return ProductoEntidad(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      categoriaId: json['categoria_id'] as String,
      unidadBase: json['unidad_base'] as String,
      stockActual: (json['stock_actual'] as num).toDouble(),
      stockMinimo: (json['stock_minimo'] as num).toDouble(),
      precio: (json['precio'] as num?)?.toDouble(),
      ubicacion: json['ubicacion'] as String?,
      activo: json['activo'] as bool,
      metadatos: json['metadatos'] as Map<String, dynamic>?,
      creadoEn: DateTime.parse(json['created_at'] as String),
      actualizadoEn: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'unidad_base': unidadBase,
      'stock_actual': stockActual,
      'stock_minimo': stockMinimo,
      'precio': precio,
      'ubicacion': ubicacion,
      'activo': activo,
      'metadatos': metadatos,
      'created_at': creadoEn.toIso8601String(),
      'updated_at': actualizadoEn.toIso8601String(),
    };
  }

  ProductoEntidad copyWith({
    String? id,
    String? appId,
    String? codigo,
    String? nombre,
    String? descripcion,
    String? categoriaId,
    String? unidadBase,
    double? stockActual,
    double? stockMinimo,
    double? precio,
    String? ubicacion,
    bool? activo,
    Map<String, dynamic>? metadatos,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return ProductoEntidad(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoriaId: categoriaId ?? this.categoriaId,
      unidadBase: unidadBase ?? this.unidadBase,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      precio: precio ?? this.precio,
      ubicacion: ubicacion ?? this.ubicacion,
      activo: activo ?? this.activo,
      metadatos: metadatos ?? this.metadatos,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  // Métodos útiles
  bool get tieneStockBajo => stockActual <= stockMinimo;
  bool get tienePrecio => precio != null && precio! > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductoEntidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductoEntidad(id: $id, codigo: $codigo, nombre: $nombre, stock: $stockActual)';
  }
}