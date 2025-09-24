import 'tipo_movimiento.dart';

class MovimientoInventarioEntidad {
  final String id;
  final String appId;
  final String productoId;
  final String? almacenId;
  final TipoMovimientoInventario tipo;
  final double cantidad;
  final double? costoUnitario;
  final String? referencia;
  final DateTime fechaMovimiento;
  final DateTime creadoEn;

  const MovimientoInventarioEntidad({
    required this.id,
    required this.appId,
    required this.productoId,
    this.almacenId,
    required this.tipo,
    required this.cantidad,
    this.costoUnitario,
    this.referencia,
    required this.fechaMovimiento,
    required this.creadoEn,
  });

  factory MovimientoInventarioEntidad.fromJson(Map<String, dynamic> json) {
    return MovimientoInventarioEntidad(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      productoId: json['producto_id'] as String,
      almacenId: json['almacen_id'] as String?,
      tipo: TipoMovimientoInventario.fromString(json['tipo'] as String),
      cantidad: (json['cantidad'] as num).toDouble(),
      costoUnitario: json['costo_unitario'] != null
          ? (json['costo_unitario'] as num).toDouble()
          : null,
      referencia: json['referencia'] as String?,
      fechaMovimiento: DateTime.parse(json['fecha_movimiento'] as String),
      creadoEn: DateTime.parse(json['creado_en'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'producto_id': productoId,
      'almacen_id': almacenId,
      'tipo': tipo.toSupabaseString(),
      'cantidad': cantidad,
      'costo_unitario': costoUnitario,
      'referencia': referencia,
      'fecha_movimiento': fechaMovimiento.toIso8601String(),
      'creado_en': creadoEn.toIso8601String(),
    };
  }

  double get cantidadConSigno {
    return tipo.incrementaStock ? cantidad : -cantidad;
  }

  MovimientoInventarioEntidad copyWith({
    String? id,
    String? appId,
    String? productoId,
    String? almacenId,
    TipoMovimientoInventario? tipo,
    double? cantidad,
    double? costoUnitario,
    String? referencia,
    DateTime? fechaMovimiento,
    DateTime? creadoEn,
  }) {
    return MovimientoInventarioEntidad(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      productoId: productoId ?? this.productoId,
      almacenId: almacenId ?? this.almacenId,
      tipo: tipo ?? this.tipo,
      cantidad: cantidad ?? this.cantidad,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      referencia: referencia ?? this.referencia,
      fechaMovimiento: fechaMovimiento ?? this.fechaMovimiento,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MovimientoInventarioEntidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MovimientoInventarioEntidad(id: $id, tipo: $tipo, cantidad: $cantidad)';
  }
}