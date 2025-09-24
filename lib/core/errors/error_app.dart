enum TipoErrorApp {
  red,
  autenticacion,
  autorizacion,
  validacion,
  noEncontrado,
  conflicto,
  servidor,
  desconocido,
}

class ErrorApp implements Exception {
  final TipoErrorApp tipo;
  final String mensaje;
  final String? detalles;
  final int? codigoHttp;
  final dynamic original;

  const ErrorApp({
    required this.tipo,
    required this.mensaje,
    this.detalles,
    this.codigoHttp,
    this.original,
  });

  // Constructores específicos
  factory ErrorApp.red(String mensaje, [dynamic original]) {
    return ErrorApp(
      tipo: TipoErrorApp.red,
      mensaje: mensaje,
      original: original,
    );
  }

  factory ErrorApp.autenticacion([String? mensaje]) {
    return ErrorApp(
      tipo: TipoErrorApp.autenticacion,
      mensaje: mensaje ?? 'No autenticado',
      codigoHttp: 401,
    );
  }

  factory ErrorApp.autorizacion([String? mensaje]) {
    return ErrorApp(
      tipo: TipoErrorApp.autorizacion,
      mensaje: mensaje ?? 'No autorizado',
      codigoHttp: 403,
    );
  }

  factory ErrorApp.validacion(String mensaje, [String? detalles]) {
    return ErrorApp(
      tipo: TipoErrorApp.validacion,
      mensaje: mensaje,
      detalles: detalles,
      codigoHttp: 400,
    );
  }

  factory ErrorApp.noEncontrado(String mensaje) {
    return ErrorApp(
      tipo: TipoErrorApp.noEncontrado,
      mensaje: mensaje,
      codigoHttp: 404,
    );
  }

  factory ErrorApp.conflicto(String mensaje, [String? detalles]) {
    return ErrorApp(
      tipo: TipoErrorApp.conflicto,
      mensaje: mensaje,
      detalles: detalles,
      codigoHttp: 409,
    );
  }

  factory ErrorApp.servidor([String? mensaje]) {
    return ErrorApp(
      tipo: TipoErrorApp.servidor,
      mensaje: mensaje ?? 'Error interno del servidor',
      codigoHttp: 500,
    );
  }

  factory ErrorApp.desconocido(String mensaje, [dynamic original]) {
    return ErrorApp(
      tipo: TipoErrorApp.desconocido,
      mensaje: mensaje,
      original: original,
    );
  }

  // Factory desde PostgREST
  factory ErrorApp.dePostgrest(Map<String, dynamic> error) {
    final mensaje = error['message'] as String? ?? 'Error de base de datos';
    final codigo = error['code'] as String?;
    final detalles = error['details'] as String?;

    // Mapear códigos PostgREST específicos
    if (codigo == '23505') {
      // Violación de unique constraint
      return ErrorApp.conflicto(
        'Ya existe un registro con esos datos',
        detalles,
      );
    }

    if (codigo == '23503') {
      // Violación de foreign key
      return ErrorApp.validacion(
        'Referencia inválida',
        detalles,
      );
    }

    if (codigo == '42501') {
      // Insufficient privilege (RLS)
      return ErrorApp.autorizacion('No tiene permisos para esta operación');
    }

    return ErrorApp.servidor(mensaje);
  }

  String get mensajeUsuario {
    switch (tipo) {
      case TipoErrorApp.red:
        return 'Error de conexión. Verifica tu internet.';
      case TipoErrorApp.autenticacion:
        return 'Sesión expirada. Inicia sesión nuevamente.';
      case TipoErrorApp.autorizacion:
        return 'No tienes permisos para realizar esta acción.';
      case TipoErrorApp.validacion:
        return mensaje;
      case TipoErrorApp.noEncontrado:
        return 'Recurso no encontrado.';
      case TipoErrorApp.conflicto:
        return mensaje;
      case TipoErrorApp.servidor:
        return 'Error del servidor. Intenta más tarde.';
      case TipoErrorApp.desconocido:
        return 'Error inesperado. Intenta nuevamente.';
    }
  }

  @override
  String toString() {
    return 'ErrorApp(tipo: $tipo, mensaje: $mensaje${detalles != null ? ', detalles: $detalles' : ''})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ErrorApp &&
        other.tipo == tipo &&
        other.mensaje == mensaje &&
        other.detalles == detalles;
  }

  @override
  int get hashCode => Object.hash(tipo, mensaje, detalles);
}