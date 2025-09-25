// ============================================
// ENUMS DEL SISTEMA - DEVUNI APP
// ============================================
// Mapeo exacto de los enums del backend PostgreSQL
// Fuente: Auditoría completa del 25 Sep 2025

/// Roles jerárquicos de usuarios en apps multi-tenant
/// Orden: visor < editor < admin < propietario
/// Fuente DB: enum tipo_rol_app
enum TipoRolApp {
  visor(1, 'Visor', 'Solo lectura', '👁️', '#2196F3'),
  editor(2, 'Editor', 'Crear y editar inventario', '✏️', '#4CAF50'),
  admin(3, 'Admin', 'Gestionar usuarios', '⚙️', '#FF9800'),
  propietario(4, 'Propietario', 'Control total', '👑', '#F44336');

  const TipoRolApp(
      this.prioridad, this.nombre, this.descripcion, this.icono, this.color);

  /// Prioridad numérica para comparaciones y ordenamiento
  final int prioridad;

  /// Nombre para mostrar en UI
  final String nombre;

  /// Descripción de permisos
  final String descripcion;

  /// Icono para UI
  final String icono;

  /// Color para UI (hex)
  final String color;

  /// Convierte string de DB a enum
  static TipoRolApp fromString(String value) {
    switch (value.toLowerCase()) {
      case 'visor':
        return TipoRolApp.visor;
      case 'editor':
        return TipoRolApp.editor;
      case 'admin':
        return TipoRolApp.admin;
      case 'propietario':
        return TipoRolApp.propietario;
      default:
        throw ArgumentError('Rol desconocido: $value');
    }
  }

  /// Convierte enum a string para DB
  String toDb() {
    return name;
  }

  /// Verifica si este rol tiene al menos la prioridad mínima requerida
  bool tienePrioridadMinima(TipoRolApp rolMinimo) {
    return prioridad >= rolMinimo.prioridad;
  }

  /// Verifica permisos específicos
  bool get puedeVer => prioridad >= TipoRolApp.visor.prioridad;
  bool get puedeEditar => prioridad >= TipoRolApp.editor.prioridad;
  bool get puedeGestionarUsuarios => prioridad >= TipoRolApp.admin.prioridad;
  bool get esProprietario => this == TipoRolApp.propietario;

  /// Lista de roles que puede asignar este rol
  List<TipoRolApp> rolesQueCanAsignar() {
    if (this == TipoRolApp.propietario) {
      return TipoRolApp.values;
    } else if (this == TipoRolApp.admin) {
      return [TipoRolApp.visor, TipoRolApp.editor, TipoRolApp.admin];
    } else {
      return [];
    }
  }
}

/// Tipos de movimientos de inventario
/// Fuente DB: enum tipo_movimiento_inventario
enum TipoMovimientoInventario {
  entrada('Entrada', true, 'Ingreso de mercancía'),
  salida('Salida', false, 'Salida de mercancía'),
  ajustePositivo('Ajuste +', true, 'Corrección al alza'),
  ajusteNegativo('Ajuste -', false, 'Corrección a la baja');

  const TipoMovimientoInventario(
      this.displayName, this.incrementaStock, this.descripcion);

  /// Nombre para mostrar en UI
  final String displayName;

  /// Si incrementa (true) o decrementa (false) el stock
  final bool incrementaStock;

  /// Descripción del tipo de movimiento
  final String descripcion;

  /// Convierte string de DB a enum
  static TipoMovimientoInventario fromString(String value) {
    switch (value.toLowerCase()) {
      case 'entrada':
        return TipoMovimientoInventario.entrada;
      case 'salida':
        return TipoMovimientoInventario.salida;
      case 'ajuste_positivo':
        return TipoMovimientoInventario.ajustePositivo;
      case 'ajuste_negativo':
        return TipoMovimientoInventario.ajusteNegativo;
      default:
        throw ArgumentError('Tipo de movimiento desconocido: $value');
    }
  }

  /// Convierte enum a string para DB
  String toDbString() {
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

  /// Obtiene el factor para cálculo de stock (+1 o -1)
  int get factorStock => incrementaStock ? 1 : -1;

  /// Lista de tipos que incrementan stock
  static List<TipoMovimientoInventario> get tiposPositivos =>
      values.where((t) => t.incrementaStock).toList();

  /// Lista de tipos que decrementan stock
  static List<TipoMovimientoInventario> get tiposNegativos =>
      values.where((t) => !t.incrementaStock).toList();
}

/// Estados de invitaciones
/// Fuente DB: check constraint en app_invitaciones.estado
enum EstadoInvitacion {
  pendiente('Pendiente', 'Esperando respuesta'),
  aceptada('Aceptada', 'Invitación aceptada'),
  cancelada('Cancelada', 'Invitación cancelada');

  const EstadoInvitacion(this.displayName, this.descripcion);

  /// Nombre para mostrar en UI
  final String displayName;

  /// Descripción del estado
  final String descripcion;

  /// Convierte string de DB a enum
  static EstadoInvitacion fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pendiente':
        return EstadoInvitacion.pendiente;
      case 'aceptada':
        return EstadoInvitacion.aceptada;
      case 'cancelada':
        return EstadoInvitacion.cancelada;
      default:
        throw ArgumentError('Estado de invitación desconocido: $value');
    }
  }

  /// Convierte enum a string para DB
  String toDbString() {
    return name;
  }

  /// Estados que permiten aceptar/cancelar
  bool get esModificable => this == EstadoInvitacion.pendiente;
}
