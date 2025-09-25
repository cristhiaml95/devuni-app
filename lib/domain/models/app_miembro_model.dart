// ============================================
// APP MIEMBRO MODEL - DEVUNI APP
// ============================================
// Mapeo exacto de la tabla 'app_miembros' del backend
// Fuente: Auditoría completa del 25 Sep 2025

import '../enums/app_enums.dart';

/// Modelo de Miembro de App
/// Fuente DB: tabla public.app_miembros
class AppMiembro {
  /// ID único del miembro (UUID)
  /// DB: app_miembros.id (PRIMARY KEY)
  final String id;

  /// ID de la app (UUID)
  /// DB: app_miembros.app_id (FK → apps.id)
  final String appId;

  /// ID del usuario (UUID de auth.users)
  /// DB: app_miembros.usuario_id (FK → auth.users.id)
  final String usuarioId;

  /// Rol del usuario en la app
  /// DB: app_miembros.rol (tipo_rol_app ENUM)
  final TipoRolApp rol;

  /// Fecha en que se unió a la app
  /// DB: app_miembros.unido_en (DEFAULT now())
  final DateTime unidoEn;

  /// Indica si el miembro está activo
  /// DB: app_miembros.activo (DEFAULT true)
  final bool activo;

  /// Fecha de creación
  /// DB: app_miembros.creado_en (DEFAULT now())
  final DateTime creadoEn;

  /// Fecha de última actualización (auto-actualizada por trigger)
  /// DB: app_miembros.actualizado_en (DEFAULT now(), trigger: touch_actualizado_en)
  final DateTime actualizadoEn;

  const AppMiembro({
    required this.id,
    required this.appId,
    required this.usuarioId,
    required this.rol,
    required this.unidoEn,
    required this.activo,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  /// Constructor desde Map de Supabase (nombres de DB)
  factory AppMiembro.fromSupabase(Map<String, dynamic> data) {
    return AppMiembro(
      id: data['id'] as String,
      appId: data['app_id'] as String,
      usuarioId: data['usuario_id'] as String,
      rol: TipoRolApp.fromString(data['rol'] as String),
      unidoEn: DateTime.parse(data['unido_en'] as String),
      activo: data['activo'] as bool? ?? true,
      creadoEn: DateTime.parse(data['creado_en'] as String),
      actualizadoEn: DateTime.parse(data['actualizado_en'] as String),
    );
  }

  /// Constructor desde JSON
  factory AppMiembro.fromJson(Map<String, dynamic> json) {
    return AppMiembro.fromSupabase(json);
  }

  /// Convierte a Map para inserción en Supabase
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'app_id': appId,
      'usuario_id': usuarioId,
      'rol': rol.toDb(),
      'unido_en': unidoEn.toIso8601String(),
      'activo': activo,
    };
  }

  /// Convierte a Map para actualización en Supabase
  Map<String, dynamic> toSupabaseUpdate() {
    return {
      'rol': rol.toDb(),
      'activo': activo,
    };
  }

  /// Crea una copia con campos modificados
  AppMiembro copyWith({
    String? id,
    String? appId,
    String? usuarioId,
    TipoRolApp? rol,
    DateTime? unidoEn,
    bool? activo,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return AppMiembro(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      usuarioId: usuarioId ?? this.usuarioId,
      rol: rol ?? this.rol,
      unidoEn: unidoEn ?? this.unidoEn,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppMiembro && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AppMiembro{usuarioId: $usuarioId, rol: $rol, activo: $activo}';
}

/// Extensiones para funcionalidad adicional
extension AppMiembroExtensions on AppMiembro {
  /// Validaciones de negocio
  List<String> validar() {
    final errores = <String>[];

    if (appId.trim().isEmpty) {
      errores.add('El ID de la app es requerido');
    }

    if (usuarioId.trim().isEmpty) {
      errores.add('El ID del usuario es requerido');
    }

    return errores;
  }

  /// Verifica si el miembro es válido
  bool get esValido => validar().isEmpty;

  /// Verifica si es propietario
  bool get esPropietario => rol == TipoRolApp.propietario;

  /// Verifica si es administrador (propietario o admin)
  bool get esAdministrador =>
      rol == TipoRolApp.propietario || rol == TipoRolApp.admin;

  /// Verifica si puede editar (propietario, admin o editor)
  bool get puedeEditar =>
      rol == TipoRolApp.propietario ||
      rol == TipoRolApp.admin ||
      rol == TipoRolApp.editor;

  /// Verifica si es solo de lectura
  bool get esSoloLectura => rol == TipoRolApp.visor;

  /// Descripción del rol con icono
  String get rolConIcono => '${rol.icono} ${rol.nombre}';

  /// Información completa del miembro
  String get resumen {
    final partes = <String>[];

    partes.add(rolConIcono);

    if (!activo) {
      partes.add('❌ Inactivo');
    }

    // Calcular tiempo como miembro
    final diasComoMiembro = DateTime.now().difference(unidoEn).inDays;
    if (diasComoMiembro == 0) {
      partes.add('🆕 Nuevo hoy');
    } else if (diasComoMiembro < 30) {
      partes.add('📅 $diasComoMiembro días');
    } else {
      final meses = (diasComoMiembro / 30).floor();
      partes.add('📅 ${meses}m');
    }

    return partes.join(' | ');
  }

  /// Color para UI según el rol
  String get colorRol => rol.color;

  /// Prioridad numérica del rol (para ordenamiento)
  int get prioridadRol => rol.prioridad;
}

/// Modelo extendido de miembro con información del usuario
/// Para uso en vistas que incluyen datos del perfil
class AppMiembroConUsuario extends AppMiembro {
  /// Email del usuario (de auth.users)
  final String? email;

  /// Nombre completo del usuario (de perfiles)
  final String? nombreCompleto;

  /// Avatar del usuario (de perfiles)
  final String? avatar;

  const AppMiembroConUsuario({
    required super.id,
    required super.appId,
    required super.usuarioId,
    required super.rol,
    required super.unidoEn,
    required super.activo,
    required super.creadoEn,
    required super.actualizadoEn,
    this.email,
    this.nombreCompleto,
    this.avatar,
  });

  /// Constructor desde Map de vista/join
  factory AppMiembroConUsuario.fromSupabase(Map<String, dynamic> data) {
    return AppMiembroConUsuario(
      id: data['id'] as String,
      appId: data['app_id'] as String,
      usuarioId: data['usuario_id'] as String,
      rol: TipoRolApp.fromString(data['rol'] as String),
      unidoEn: DateTime.parse(data['unido_en'] as String),
      activo: data['activo'] as bool? ?? true,
      creadoEn: DateTime.parse(data['creado_en'] as String),
      actualizadoEn: DateTime.parse(data['actualizado_en'] as String),
      email: data['email'] as String?,
      nombreCompleto: data['nombre_completo'] as String?,
      avatar: data['avatar'] as String?,
    );
  }

  /// Nombre para mostrar (prioriza nombre completo, luego email)
  String get nombreParaMostrar {
    if (nombreCompleto != null && nombreCompleto!.isNotEmpty) {
      return nombreCompleto!;
    }
    if (email != null && email!.isNotEmpty) {
      return email!;
    }
    return 'Usuario $usuarioId';
  }

  /// Iniciales para avatar
  String get iniciales {
    if (nombreCompleto != null && nombreCompleto!.isNotEmpty) {
      final partes = nombreCompleto!.trim().split(' ');
      if (partes.length >= 2) {
        return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
      }
      return nombreCompleto![0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return 'U';
  }

  @override
  String toString() =>
      'AppMiembroConUsuario{nombre: $nombreParaMostrar, rol: $rol}';
}
