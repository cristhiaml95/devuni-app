// ============================================
// MOVIMIENTO INVENTARIO MODEL - DEVUNI APP
// ============================================
// Mapeo exacto de la tabla 'movimientos_inventario' del backend
// Fuente: Auditoría completa del 25 Sep 2025

import '../enums/app_enums.dart';

/// Modelo de Movimiento de Inventario
/// Fuente DB: tabla public.movimientos_inventario
class MovimientoInventario {
  /// ID único del movimiento (UUID)
  /// DB: movimientos_inventario.id (PRIMARY KEY)
  final String id;

  /// ID de la app a la que pertenece (UUID)
  /// DB: movimientos_inventario.app_id (FK → apps.id)
  final String appId;

  /// ID del producto (UUID)
  /// DB: movimientos_inventario.producto_id (FK → productos_inventario.id)
  final String productoId;

  /// ID del almacén (opcional, UUID)
  /// DB: movimientos_inventario.almacen_id (FK → almacenes.id SET NULL)
  final String? almacenId;

  /// Tipo de movimiento
  /// DB: movimientos_inventario.tipo (enum tipo_movimiento_inventario)
  final TipoMovimientoInventario tipo;

  /// Cantidad del movimiento (siempre positiva)
  /// DB: movimientos_inventario.cantidad (numeric(18,6), CHECK > 0)
  final double cantidad;

  /// Costo unitario (opcional)
  /// DB: movimientos_inventario.costo_unitario (numeric(18,6))
  final double? costoUnitario;

  /// Referencia o nota del movimiento (opcional)
  /// DB: movimientos_inventario.referencia (text)
  final String? referencia;

  /// Fecha del movimiento
  /// DB: movimientos_inventario.fecha_movimiento (DEFAULT now())
  final DateTime fechaMovimiento;

  /// Fecha de creación del registro
  /// DB: movimientos_inventario.creado_en (DEFAULT now())
  final DateTime creadoEn;

  const MovimientoInventario({
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

  /// Constructor desde Map de Supabase (nombres de DB)
  factory MovimientoInventario.fromSupabase(Map<String, dynamic> data) {
    return MovimientoInventario(
      id: data['id'] as String,
      appId: data['app_id'] as String,
      productoId: data['producto_id'] as String,
      almacenId: data['almacen_id'] as String?,
      tipo: TipoMovimientoInventario.fromString(data['tipo'] as String),
      cantidad: (data['cantidad'] as num).toDouble(),
      costoUnitario: data['costo_unitario'] != null
          ? (data['costo_unitario'] as num).toDouble()
          : null,
      referencia: data['referencia'] as String?,
      fechaMovimiento: DateTime.parse(data['fecha_movimiento'] as String),
      creadoEn: DateTime.parse(data['creado_en'] as String),
    );
  }

  /// Constructor desde JSON
  factory MovimientoInventario.fromJson(Map<String, dynamic> json) {
    return MovimientoInventario.fromSupabase(json);
  }

  /// Convierte a Map para inserción en Supabase (usando RPC)
  Map<String, dynamic> toSupabaseRpcParams() {
    return {
      'p_app_id': appId,
      'p_producto_id': productoId,
      'p_tipo': tipo.toDbString(),
      'p_cantidad': cantidad,
      'p_almacen_id': almacenId,
      'p_costo_unitario': costoUnitario,
      'p_referencia': referencia,
    };
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'producto_id': productoId,
      'almacen_id': almacenId,
      'tipo': tipo.toDbString(),
      'cantidad': cantidad,
      'costo_unitario': costoUnitario,
      'referencia': referencia,
      'fecha_movimiento': fechaMovimiento.toIso8601String(),
      'creado_en': creadoEn.toIso8601String(),
    };
  }

  /// Crea una copia con campos modificados
  MovimientoInventario copyWith({
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
    return MovimientoInventario(
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovimientoInventario &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MovimientoInventario{id: $id, tipo: $tipo, cantidad: $cantidad}';
  }
}

/// Extensiones para funcionalidad adicional
extension MovimientoInventarioExtensions on MovimientoInventario {
  /// Validaciones de negocio
  List<String> validar() {
    final errores = <String>[];

    if (cantidad <= 0) {
      errores.add('La cantidad debe ser mayor a 0');
    }

    if (cantidad > 999999.999999) {
      errores.add('La cantidad no puede exceder 999,999.999999');
    }

    if (costoUnitario != null && costoUnitario! < 0) {
      errores.add('El costo unitario no puede ser negativo');
    }

    if (costoUnitario != null && costoUnitario! > 999999.999999) {
      errores.add('El costo unitario no puede exceder 999,999.999999');
    }

    if (referencia != null && referencia!.length > 200) {
      errores.add('La referencia no puede exceder 200 caracteres');
    }

    return errores;
  }

  /// Verifica si el movimiento es válido
  bool get esValido => validar().isEmpty;

  /// Calcula el impacto en el stock (positivo o negativo)
  double get impactoStock => cantidad * tipo.factorStock;

  /// Cantidad formateada como string
  String get cantidadFormateada => cantidad.toStringAsFixed(3);

  /// Costo formateado como string
  String get costoFormateado {
    if (costoUnitario == null) return 'Sin costo';
    return '\$${costoUnitario!.toStringAsFixed(2)}';
  }

  /// Costo total del movimiento
  double? get costoTotal {
    if (costoUnitario == null) return null;
    return cantidad * costoUnitario!;
  }

  /// Costo total formateado
  String get costoTotalFormateado {
    final total = costoTotal;
    if (total == null) return 'Sin costo';
    return '\$${total.toStringAsFixed(2)}';
  }

  /// Fecha formateada para mostrar
  String get fechaFormateada {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaMovimiento);

    if (diferencia.inDays > 7) {
      return '${fechaMovimiento.day}/${fechaMovimiento.month}/${fechaMovimiento.year}';
    } else if (diferencia.inDays > 0) {
      return 'Hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return 'Hace ${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else {
      return 'Hace ${diferencia.inMinutes} minuto${diferencia.inMinutes > 1 ? 's' : ''}';
    }
  }

  /// Resumen del movimiento para listas
  String get resumen {
    final partes = <String>[
      tipo.displayName,
      cantidadFormateada,
    ];

    if (referencia != null && referencia!.isNotEmpty) {
      partes.add(referencia!);
    }

    return partes.join(' - ');
  }

  /// Color del tipo de movimiento para UI
  String get colorTipo {
    switch (tipo) {
      case TipoMovimientoInventario.entrada:
      case TipoMovimientoInventario.ajustePositivo:
        return 'green';
      case TipoMovimientoInventario.salida:
      case TipoMovimientoInventario.ajusteNegativo:
        return 'red';
    }
  }

  /// Icono del tipo de movimiento para UI
  String get iconoTipo {
    switch (tipo) {
      case TipoMovimientoInventario.entrada:
        return 'arrow_downward';
      case TipoMovimientoInventario.salida:
        return 'arrow_upward';
      case TipoMovimientoInventario.ajustePositivo:
        return 'add';
      case TipoMovimientoInventario.ajusteNegativo:
        return 'remove';
    }
  }

  /// Indica si es un movimiento que incrementa stock
  bool get incrementaStock => tipo.incrementaStock;

  /// Indica si es un movimiento que decrementa stock
  bool get decrementaStock => !tipo.incrementaStock;

  /// Indica si tiene costo definido
  bool get tieneCosto => costoUnitario != null && costoUnitario! > 0;

  /// Indica si tiene almacén asignado
  bool get tieneAlmacen => almacenId != null;

  /// Indica si tiene referencia
  bool get tieneReferencia => referencia != null && referencia!.isNotEmpty;
}
