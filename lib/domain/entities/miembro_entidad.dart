import 'rol_usuario.dart';

class MiembroEntidad {
  final String appId;
  final String userId;
  final RolUsuarioApp rol;
  final String anadidoPor;
  final DateTime anadidoEn;

  const MiembroEntidad({
    required this.appId,
    required this.userId,
    required this.rol,
    required this.anadidoPor,
    required this.anadidoEn,
  });

  factory MiembroEntidad.fromJson(Map<String, dynamic> json) {
    return MiembroEntidad(
      appId: json['app_id'] as String,
      userId: json['user_id'] as String,
      rol: RolUsuarioApp.fromString(json['rol'] as String),
      anadidoPor: json['anadido_por'] as String,
      anadidoEn: DateTime.parse(json['anadido_en'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_id': appId,
      'user_id': userId,
      'rol': rol.toString(),
      'anadido_por': anadidoPor,
      'anadido_en': anadidoEn.toIso8601String(),
    };
  }

  MiembroEntidad copyWith({
    String? appId,
    String? userId,
    RolUsuarioApp? rol,
    String? anadidoPor,
    DateTime? anadidoEn,
  }) {
    return MiembroEntidad(
      appId: appId ?? this.appId,
      userId: userId ?? this.userId,
      rol: rol ?? this.rol,
      anadidoPor: anadidoPor ?? this.anadidoPor,
      anadidoEn: anadidoEn ?? this.anadidoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MiembroEntidad &&
        other.appId == appId &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(appId, userId);

  @override
  String toString() {
    return 'MiembroEntidad(appId: $appId, userId: $userId, rol: $rol)';
  }
}