// ============================================
// APP INVITACION MODEL - DEVUNI APP
// ============================================
// Mapeo exacto de la tabla 'app_invitaciones' del backend
// Fuente: Auditoría completa del 25 Sep 2025

import '../enums/app_enums.dart';

/// Modelo de Invitación de App
/// Fuente DB: tabla public.app_invitaciones
class AppInvitacion {
  /// ID único de la invitación (UUID)
  /// DB: app_invitaciones.id (PRIMARY KEY)
  final String id;

  /// ID de la app (UUID)
  /// DB: app_invitaciones.app_id (FK → apps.id)
  final String appId;

  /// Email del usuario invitado
  /// DB: app_invitaciones.email (NOT NULL)
  final String email;

  /// Rol que se asignará al aceptar
  /// DB: app_invitaciones.rol (tipo_rol_app ENUM)
  final TipoRolApp rol;

  /// ID del usuario que invita (UUID de auth.users)
  /// DB: app_invitaciones.invitado_por (FK → auth.users.id)
  final String invitadoPor;

  /// Estado de la invitación
  /// DB: app_invitaciones.estado (CHECK constraint: pendiente, aceptada, cancelada)
  final EstadoInvitacion estado;

  /// Token único para aceptar la invitación
  /// DB: app_invitaciones.token (UNIQUE, NOT NULL)
  final String token;

  /// Fecha de expiración de la invitación
  /// DB: app_invitaciones.expira_en (NOT NULL)
  final DateTime expiraEn;

  /// Fecha de aceptación (si fue aceptada)
  /// DB: app_invitaciones.aceptada_en (NULLABLE)
  final DateTime? aceptadaEn;

  /// Fecha de creación
  /// DB: app_invitaciones.creado_en (DEFAULT now())
  final DateTime creadoEn;

  /// Fecha de última actualización (auto-actualizada por trigger)
  /// DB: app_invitaciones.actualizado_en (DEFAULT now(), trigger: touch_actualizado_en)
  final DateTime actualizadoEn;

  const AppInvitacion({
    required this.id,
    required this.appId,
    required this.email,
    required this.rol,
    required this.invitadoPor,
    required this.estado,
    required this.token,
    required this.expiraEn,
    this.aceptadaEn,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  /// Constructor desde Map de Supabase (nombres de DB)
  factory AppInvitacion.fromSupabase(Map<String, dynamic> data) {
    return AppInvitacion(
      id: data['id'] as String,
      appId: data['app_id'] as String,
      email: data['email'] as String,
      rol: TipoRolApp.fromString(data['rol'] as String),
      invitadoPor: data['invitado_por'] as String,
      estado: EstadoInvitacion.fromString(data['estado'] as String),
      token: data['token'] as String,
      expiraEn: DateTime.parse(data['expira_en'] as String),
      aceptadaEn: data['aceptada_en'] != null
          ? DateTime.parse(data['aceptada_en'] as String)
          : null,
      creadoEn: DateTime.parse(data['creado_en'] as String),
      actualizadoEn: DateTime.parse(data['actualizado_en'] as String),
    );
  }

  /// Constructor desde JSON
  factory AppInvitacion.fromJson(Map<String, dynamic> json) {
    return AppInvitacion.fromSupabase(json);
  }

  /// Convierte a Map para inserción en Supabase
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'app_id': appId,
      'email': email,
      'rol': rol.toDb(),
      'invitado_por': invitadoPor,
      'estado': estado.toDbString(),
      'token': token,
      'expira_en': expiraEn.toIso8601String(),
      'aceptada_en': aceptadaEn?.toIso8601String(),
    };
  }

  /// Convierte a Map para actualización en Supabase
  Map<String, dynamic> toSupabaseUpdate() {
    return {
      'estado': estado.toDbString(),
      'aceptada_en': aceptadaEn?.toIso8601String(),
    };
  }

  /// Crea una copia con campos modificados
  AppInvitacion copyWith({
    String? id,
    String? appId,
    String? email,
    TipoRolApp? rol,
    String? invitadoPor,
    EstadoInvitacion? estado,
    String? token,
    DateTime? expiraEn,
    DateTime? aceptadaEn,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return AppInvitacion(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      invitadoPor: invitadoPor ?? this.invitadoPor,
      estado: estado ?? this.estado,
      token: token ?? this.token,
      expiraEn: expiraEn ?? this.expiraEn,
      aceptadaEn: aceptadaEn ?? this.aceptadaEn,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInvitacion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AppInvitacion{email: $email, rol: $rol, estado: $estado}';
}

/// Extensiones para funcionalidad adicional
extension AppInvitacionExtensions on AppInvitacion {
  /// Validaciones de negocio
  List<String> validar() {
    final errores = <String>[];

    if (appId.trim().isEmpty) {
      errores.add('El ID de la app es requerido');
    }

    if (email.trim().isEmpty) {
      errores.add('El email es requerido');
    }

    // Validación básica de email
    if (!_esEmailValido(email)) {
      errores.add('El formato del email no es válido');
    }

    if (invitadoPor.trim().isEmpty) {
      errores.add('El ID del usuario que invita es requerido');
    }

    if (token.trim().isEmpty) {
      errores.add('El token es requerido');
    }

    return errores;
  }

  /// Verifica si la invitación es válida
  bool get esValida => validar().isEmpty;

  /// Verifica si la invitación está pendiente
  bool get estaPendiente => estado == EstadoInvitacion.pendiente;

  /// Verifica si la invitación fue aceptada
  bool get fueAceptada => estado == EstadoInvitacion.aceptada;

  /// Verifica si la invitación fue cancelada
  bool get fueCancelada => estado == EstadoInvitacion.cancelada;

  /// Verifica si la invitación ha expirado
  bool get haExpirado => DateTime.now().isAfter(expiraEn);

  /// Verifica si la invitación puede ser aceptada
  bool get puedeSerAceptada => estaPendiente && !haExpirado;

  /// Verifica si la invitación puede ser cancelada
  bool get puedeSerCancelada => estaPendiente;

  /// Días restantes para que expire (negativo si ya expiró)
  int get diasRestantes => expiraEn.difference(DateTime.now()).inDays;

  /// Horas restantes para que expire (negativo si ya expiró)
  int get horasRestantes => expiraEn.difference(DateTime.now()).inHours;

  /// Descripción del estado con icono
  String get estadoConIcono {
    switch (estado) {
      case EstadoInvitacion.pendiente:
        return haExpirado ? '⏰ Expirada' : '⏳ ${estado.displayName}';
      case EstadoInvitacion.aceptada:
        return '✅ ${estado.displayName}';
      case EstadoInvitacion.cancelada:
        return '❌ ${estado.displayName}';
    }
  }

  /// Rol con icono
  String get rolConIcono => '${rol.icono} ${rol.nombre}';

  /// Resumen completo de la invitación
  String get resumen {
    final partes = <String>[];

    partes.add(email);
    partes.add(rolConIcono);
    partes.add(estadoConIcono);

    if (estaPendiente && !haExpirado) {
      if (diasRestantes > 0) {
        partes.add('📅 ${diasRestantes}d restantes');
      } else if (horasRestantes > 0) {
        partes.add('📅 ${horasRestantes}h restantes');
      } else {
        partes.add('📅 Expira pronto');
      }
    }

    return partes.join(' | ');
  }

  /// Color para UI según el estado
  String get colorEstado {
    if (haExpirado) return '#F44336'; // Rojo

    switch (estado) {
      case EstadoInvitacion.pendiente:
        return '#FF9800'; // Naranja
      case EstadoInvitacion.aceptada:
        return '#4CAF50'; // Verde
      case EstadoInvitacion.cancelada:
        return '#9E9E9E'; // Gris
    }
  }

  /// Validador privado para email
  bool _esEmailValido(String email) {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}

/// Modelo extendido de invitación con información del invitador
/// Para uso en vistas que incluyen datos del usuario que invita
class AppInvitacionConInvitador extends AppInvitacion {
  /// Email del usuario que invita (de auth.users)
  final String? emailInvitador;

  /// Nombre completo del invitador (de perfiles)
  final String? nombreInvitador;

  /// Avatar del invitador (de perfiles)
  final String? avatarInvitador;

  const AppInvitacionConInvitador({
    required super.id,
    required super.appId,
    required super.email,
    required super.rol,
    required super.invitadoPor,
    required super.estado,
    required super.token,
    required super.expiraEn,
    super.aceptadaEn,
    required super.creadoEn,
    required super.actualizadoEn,
    this.emailInvitador,
    this.nombreInvitador,
    this.avatarInvitador,
  });

  /// Constructor desde Map de vista/join
  factory AppInvitacionConInvitador.fromSupabase(Map<String, dynamic> data) {
    return AppInvitacionConInvitador(
      id: data['id'] as String,
      appId: data['app_id'] as String,
      email: data['email'] as String,
      rol: TipoRolApp.fromString(data['rol'] as String),
      invitadoPor: data['invitado_por'] as String,
      estado: EstadoInvitacion.fromString(data['estado'] as String),
      token: data['token'] as String,
      expiraEn: DateTime.parse(data['expira_en'] as String),
      aceptadaEn: data['aceptada_en'] != null
          ? DateTime.parse(data['aceptada_en'] as String)
          : null,
      creadoEn: DateTime.parse(data['creado_en'] as String),
      actualizadoEn: DateTime.parse(data['actualizado_en'] as String),
      emailInvitador: data['email_invitador'] as String?,
      nombreInvitador: data['nombre_invitador'] as String?,
      avatarInvitador: data['avatar_invitador'] as String?,
    );
  }

  /// Nombre del invitador para mostrar
  String get nombreInvitadorParaMostrar {
    if (nombreInvitador != null && nombreInvitador!.isNotEmpty) {
      return nombreInvitador!;
    }
    if (emailInvitador != null && emailInvitador!.isNotEmpty) {
      return emailInvitador!;
    }
    return 'Usuario desconocido';
  }

  @override
  String toString() =>
      'AppInvitacionConInvitador{email: $email, invitadoPor: $nombreInvitadorParaMostrar}';
}
