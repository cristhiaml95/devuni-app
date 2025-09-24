class StockPorAlmacenEntidad {
  final String appId;
  final String productoId;
  final String sku;
  final String nombre;
  final String? almacenId;
  final String? almacenNombre;
  final double stockActual;

  const StockPorAlmacenEntidad({
    required this.appId,
    required this.productoId,
    required this.sku,
    required this.nombre,
    this.almacenId,
    this.almacenNombre,
    required this.stockActual,
  });

  factory StockPorAlmacenEntidad.fromJson(Map<String, dynamic> json) {
    return StockPorAlmacenEntidad(
      appId: json['app_id'] as String,
      productoId: json['producto_id'] as String,
      sku: json['sku'] as String,
      nombre: json['nombre'] as String,
      almacenId: json['almacen_id'] as String?,
      almacenNombre: json['almacen_nombre'] as String?,
      stockActual: (json['stock_actual'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_id': appId,
      'producto_id': productoId,
      'sku': sku,
      'nombre': nombre,
      'almacen_id': almacenId,
      'almacen_nombre': almacenNombre,
      'stock_actual': stockActual,
    };
  }

  bool get tieneStock => stockActual > 0;
  bool get stockBajo => stockActual <= 10; // Configurable
  bool get sinStock => stockActual <= 0;

  String get almacenDisplay => almacenNombre ?? 'Sin almacén';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockPorAlmacenEntidad &&
        other.productoId == productoId &&
        other.almacenId == almacenId;
  }

  @override
  int get hashCode => Object.hash(productoId, almacenId);

  @override
  String toString() {
    return 'StockPorAlmacenEntidad(sku: $sku, almacen: $almacenDisplay, stock: $stockActual)';
  }
}