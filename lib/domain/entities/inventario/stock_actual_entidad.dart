class StockActualEntidad {
  final String appId;
  final String productoId;
  final String sku;
  final String nombre;
  final double stockActual;

  const StockActualEntidad({
    required this.appId,
    required this.productoId,
    required this.sku,
    required this.nombre,
    required this.stockActual,
  });

  factory StockActualEntidad.fromJson(Map<String, dynamic> json) {
    return StockActualEntidad(
      appId: json['app_id'] as String,
      productoId: json['producto_id'] as String,
      sku: json['sku'] as String,
      nombre: json['nombre'] as String,
      stockActual: (json['stock_actual'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_id': appId,
      'producto_id': productoId,
      'sku': sku,
      'nombre': nombre,
      'stock_actual': stockActual,
    };
  }

  bool get tieneStock => stockActual > 0;
  bool get stockBajo => stockActual <= 10; // Configurable
  bool get sinStock => stockActual <= 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockActualEntidad && other.productoId == productoId;
  }

  @override
  int get hashCode => productoId.hashCode;

  @override
  String toString() {
    return 'StockActualEntidad(sku: $sku, nombre: $nombre, stock: $stockActual)';
  }
}