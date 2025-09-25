// ============================================
// MOVIMIENTOS INVENTARIO PROVIDER - DEVUNI APP
// ============================================
// Provider Riverpod para la gestión completa de movimientos de inventario
// Integra con Supabase usando RLS y RPCs del backend auditado

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/supabase_providers.dart';
import '../../domain/models.dart';
import 'productos_inventario_provider.dart';

/// Proveedor de lista de movimientos de inventario para la app seleccionada
/// Con paginación y filtros opcionales
final movimientosInventarioProvider = StreamNotifierProvider.autoDispose.family<
    MovimientosInventarioNotifier,
    List<MovimientoInventario>,
    MovimientosFiltros>(
  MovimientosInventarioNotifier.new,
);

/// Notifier para la gestión de movimientos de inventario
class MovimientosInventarioNotifier extends AutoDisposeFamilyStreamNotifier<
    List<MovimientoInventario>, MovimientosFiltros> {
  @override
  Stream<List<MovimientoInventario>> build(MovimientosFiltros filtros) async* {
    // Validar que tengamos una app seleccionada
    if (filtros.appId.isEmpty) {
      yield [];
      return;
    }

    final supabase = ref.read(supabaseClientProvider);

    try {
      // Construir query con filtros
      var query = supabase.from('movimientos_inventario').select('''
            *,
            productos_inventario:producto_id(codigo, nombre),
            almacenes:almacen_id(codigo, nombre)
          ''').eq('app_id', filtros.appId);

      // Aplicar filtros opcionales
      if (filtros.tipoMovimiento != null) {
        query =
            query.eq('tipo_movimiento', filtros.tipoMovimiento!.toDbString());
      }

      if (filtros.productoId != null && filtros.productoId!.isNotEmpty) {
        query = query.eq('producto_id', filtros.productoId!);
      }

      if (filtros.almacenId != null && filtros.almacenId!.isNotEmpty) {
        query = query.eq('almacen_id', filtros.almacenId!);
      }

      if (filtros.fechaDesde != null) {
        query = query.gte(
            'fecha_movimiento', filtros.fechaDesde!.toIso8601String());
      }

      if (filtros.fechaHasta != null) {
        query = query.lte(
            'fecha_movimiento', filtros.fechaHasta!.toIso8601String());
      }

      // Ordenar por fecha descendente y limitar resultados
      final stream = query
          .order('fecha_movimiento', ascending: false)
          .limit(filtros.limite)
          .asStream();

      await for (final data in stream) {
        final movimientos = data
            .map((json) => MovimientoInventario.fromSupabase(json))
            .toList();
        yield movimientos;
      }
    } catch (error) {
      print('Error en movimientosInventarioProvider: $error');
      yield [];
    }
  }

  /// Crear un nuevo movimiento de inventario
  /// Usa RPC del backend que maneja el stock automáticamente
  Future<MovimientoInventario?> crearMovimiento(
      MovimientoInventario movimiento) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      // Usar RPC que actualiza stock automáticamente
      final response =
          await supabase.rpc('crear_movimiento_inventario', params: {
        'p_app_id': movimiento.appId,
        'p_producto_id': movimiento.productoId,
        'p_almacen_id': movimiento.almacenId,
        'p_tipo_movimiento': movimiento.tipo.toDbString(),
        'p_cantidad': movimiento.cantidad,
        'p_costo_unitario': movimiento.costoUnitario,
        'p_referencia': movimiento.referencia,
        'p_fecha_movimiento': movimiento.fechaMovimiento.toIso8601String(),
      });

      final nuevoMovimiento = MovimientoInventario.fromSupabase(response);

      // Invalidar cache de productos para actualizar stock
      ref.invalidate(productosInventarioProvider);

      return nuevoMovimiento;
    } catch (error) {
      print('Error al crear movimiento: $error');
      throw Exception('No se pudo crear el movimiento: $error');
    }
  }

  /// Actualizar un movimiento existente
  /// NOTA: Muy restrictivo por reglas de negocio
  Future<MovimientoInventario?> actualizarMovimiento(
      MovimientoInventario movimiento) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      // Usar RPC que valida y actualiza con recálculo de stock
      final response =
          await supabase.rpc('actualizar_movimiento_inventario', params: {
        'p_movimiento_id': movimiento.id,
        'p_referencia': movimiento.referencia,
      });

      final movimientoActualizado = MovimientoInventario.fromSupabase(response);

      return movimientoActualizado;
    } catch (error) {
      print('Error al actualizar movimiento: $error');
      throw Exception('No se pudo actualizar el movimiento: $error');
    }
  }

  /// Cancelar un movimiento (marca como cancelado y revierte stock)
  Future<bool> cancelarMovimiento(String movimientoId, String motivo) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      await supabase.rpc('cancelar_movimiento_inventario', params: {
        'p_movimiento_id': movimientoId,
        'p_motivo_cancelacion': motivo,
      });

      // Invalidar cache de productos para actualizar stock
      ref.invalidate(productosInventarioProvider);

      return true;
    } catch (error) {
      print('Error al cancelar movimiento: $error');
      throw Exception('No se pudo cancelar el movimiento: $error');
    }
  }

  /// Obtener resumen de movimientos por período
  Future<ResumenMovimientos> obtenerResumenPorPeriodo(
      String appId, DateTime fechaInicio, DateTime fechaFin) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      final response =
          await supabase.rpc('obtener_resumen_movimientos', params: {
        'p_app_id': appId,
        'p_fecha_inicio': fechaInicio.toIso8601String(),
        'p_fecha_fin': fechaFin.toIso8601String(),
      });

      return ResumenMovimientos.fromJson(response);
    } catch (error) {
      print('Error al obtener resumen de movimientos: $error');
      return ResumenMovimientos.vacio();
    }
  }
}

/// Provider para un movimiento específico por ID
final movimientoInventarioPorIdProvider = StreamProvider.autoDispose
    .family<MovimientoInventario?, String>((ref, movimientoId) {
  if (movimientoId.isEmpty) return Stream.value(null);

  final supabase = ref.read(supabaseClientProvider);

  return supabase
      .from('movimientos_inventario')
      .stream(primaryKey: ['id'])
      .eq('id', movimientoId)
      .map((data) {
        if (data.isEmpty) return null;
        return MovimientoInventario.fromSupabase(data.first);
      });
});

/// Provider para estadísticas de movimientos
final estadisticasMovimientosProvider = FutureProvider.autoDispose
    .family<EstadisticasMovimientos, String>((ref, appId) async {
  if (appId.isEmpty) {
    return EstadisticasMovimientos.vacio();
  }

  try {
    final supabase = ref.read(supabaseClientProvider);

    final response =
        await supabase.rpc('obtener_estadisticas_movimientos', params: {
      'p_app_id': appId,
    });

    return EstadisticasMovimientos.fromJson(response);
  } catch (error) {
    print('Error al obtener estadísticas de movimientos: $error');
    return EstadisticasMovimientos.vacio();
  }
});

/// Clase para filtros de movimientos
class MovimientosFiltros {
  final String appId;
  final TipoMovimientoInventario? tipoMovimiento;
  final String? productoId;
  final String? almacenId;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final int limite;

  const MovimientosFiltros({
    required this.appId,
    this.tipoMovimiento,
    this.productoId,
    this.almacenId,
    this.fechaDesde,
    this.fechaHasta,
    this.limite = 100,
  });

  MovimientosFiltros copyWith({
    String? appId,
    TipoMovimientoInventario? tipoMovimiento,
    String? productoId,
    String? almacenId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int? limite,
  }) {
    return MovimientosFiltros(
      appId: appId ?? this.appId,
      tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
      productoId: productoId ?? this.productoId,
      almacenId: almacenId ?? this.almacenId,
      fechaDesde: fechaDesde ?? this.fechaDesde,
      fechaHasta: fechaHasta ?? this.fechaHasta,
      limite: limite ?? this.limite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovimientosFiltros &&
          runtimeType == other.runtimeType &&
          appId == other.appId &&
          tipoMovimiento == other.tipoMovimiento &&
          productoId == other.productoId &&
          almacenId == other.almacenId &&
          fechaDesde == other.fechaDesde &&
          fechaHasta == other.fechaHasta &&
          limite == other.limite;

  @override
  int get hashCode => Object.hash(
        appId,
        tipoMovimiento,
        productoId,
        almacenId,
        fechaDesde,
        fechaHasta,
        limite,
      );
}

/// Modelo para resumen de movimientos
class ResumenMovimientos {
  final int totalMovimientos;
  final int totalEntradas;
  final int totalSalidas;
  final int totalAjustes;
  final double valorTotalEntradas;
  final double valorTotalSalidas;
  final double valorNetoCambios;

  const ResumenMovimientos({
    required this.totalMovimientos,
    required this.totalEntradas,
    required this.totalSalidas,
    required this.totalAjustes,
    required this.valorTotalEntradas,
    required this.valorTotalSalidas,
    required this.valorNetoCambios,
  });

  factory ResumenMovimientos.fromJson(Map<String, dynamic> json) {
    return ResumenMovimientos(
      totalMovimientos: json['total_movimientos'] as int? ?? 0,
      totalEntradas: json['total_entradas'] as int? ?? 0,
      totalSalidas: json['total_salidas'] as int? ?? 0,
      totalAjustes: json['total_ajustes'] as int? ?? 0,
      valorTotalEntradas:
          (json['valor_total_entradas'] as num?)?.toDouble() ?? 0.0,
      valorTotalSalidas:
          (json['valor_total_salidas'] as num?)?.toDouble() ?? 0.0,
      valorNetoCambios: (json['valor_neto_cambios'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory ResumenMovimientos.vacio() {
    return const ResumenMovimientos(
      totalMovimientos: 0,
      totalEntradas: 0,
      totalSalidas: 0,
      totalAjustes: 0,
      valorTotalEntradas: 0.0,
      valorTotalSalidas: 0.0,
      valorNetoCambios: 0.0,
    );
  }
}

/// Modelo para estadísticas de movimientos
class EstadisticasMovimientos {
  final int movimientosHoy;
  final int movimientosSemana;
  final int movimientosMes;
  final double promedioMovimientosDiarios;
  final Map<String, int> movimientosPorTipo;

  const EstadisticasMovimientos({
    required this.movimientosHoy,
    required this.movimientosSemana,
    required this.movimientosMes,
    required this.promedioMovimientosDiarios,
    required this.movimientosPorTipo,
  });

  factory EstadisticasMovimientos.fromJson(Map<String, dynamic> json) {
    return EstadisticasMovimientos(
      movimientosHoy: json['movimientos_hoy'] as int? ?? 0,
      movimientosSemana: json['movimientos_semana'] as int? ?? 0,
      movimientosMes: json['movimientos_mes'] as int? ?? 0,
      promedioMovimientosDiarios:
          (json['promedio_movimientos_diarios'] as num?)?.toDouble() ?? 0.0,
      movimientosPorTipo:
          Map<String, int>.from(json['movimientos_por_tipo'] as Map? ?? {}),
    );
  }

  factory EstadisticasMovimientos.vacio() {
    return const EstadisticasMovimientos(
      movimientosHoy: 0,
      movimientosSemana: 0,
      movimientosMes: 0,
      promedioMovimientosDiarios: 0.0,
      movimientosPorTipo: {},
    );
  }
}
