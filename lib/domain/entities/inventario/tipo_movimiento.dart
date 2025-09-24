enum TipoMovimientoInventario {
  entrada,
  salida,
  ajustePositivo,
  ajusteNegativo;

  String get nombre {
    switch (this) {
      case TipoMovimientoInventario.entrada:
        return 'Entrada';
      case TipoMovimientoInventario.salida:
        return 'Salida';
      case TipoMovimientoInventario.ajustePositivo:
        return 'Ajuste Positivo';
      case TipoMovimientoInventario.ajusteNegativo:
        return 'Ajuste Negativo';
    }
  }

  String get descripcion {
    switch (this) {
      case TipoMovimientoInventario.entrada:
        return 'Incrementa el stock del producto';
      case TipoMovimientoInventario.salida:
        return 'Reduce el stock del producto';
      case TipoMovimientoInventario.ajustePositivo:
        return 'Ajuste que incrementa el stock';
      case TipoMovimientoInventario.ajusteNegativo:
        return 'Ajuste que reduce el stock';
    }
  }

  bool get incrementaStock {
    return this == TipoMovimientoInventario.entrada ||
        this == TipoMovimientoInventario.ajustePositivo;
  }

  bool get reduceStock {
    return this == TipoMovimientoInventario.salida ||
        this == TipoMovimientoInventario.ajusteNegativo;
  }

  static TipoMovimientoInventario fromString(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'entrada':
        return TipoMovimientoInventario.entrada;
      case 'salida':
        return TipoMovimientoInventario.salida;
      case 'ajuste_positivo':
        return TipoMovimientoInventario.ajustePositivo;
      case 'ajuste_negativo':
        return TipoMovimientoInventario.ajusteNegativo;
      default:
        return TipoMovimientoInventario.entrada;
    }
  }

  String toSupabaseString() {
    switch (this) {
      case TipoMovimientoInventario.entrada:
        return 'entrada';
      case TipoMovimientoInventario.salida:
        return 'salida';
      case TipoMovimientoInventario.ajustePositivo:
        return 'ajuste_positivo';
      case TipoMovimientoInventario.ajusteNegativo:
        return 'ajuste_negativo';
    }
  }

  @override
  String toString() {
    return toSupabaseString();
  }
}