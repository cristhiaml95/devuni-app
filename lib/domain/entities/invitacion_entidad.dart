import 'rol_usuario.dart';

class InvitacionEntidad {
  final String id;
  final String appId;
  final String email;
  final RolUsuarioApp rol;
  final String estado;
  final String invitadoPor;
  final DateTime creadoEn;
  final DateTime? aceptadoEn;

  const InvitacionEntidad({
    required this.id,
    required this.appId,
    required this.email,
    required this.rol,
    required this.estado,
    required this.invitadoPor,
    required this.creadoEn,
    this.aceptadoEn,
  });

  factory InvitacionEntidad.fromJson(Map<String, dynamic> json) {
    return InvitacionEntidad(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      email: json['email'] as String,
      rol: RolUsuarioApp.fromString(json['rol'] as String),
      estado: json['estado'] as String,
      invitadoPor: json['invitado_por'] as String,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      aceptadoEn: json['aceptado_en'] != null
          ? DateTime.parse(json['aceptado_en'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'email': email,
      'rol': rol.toString(),
      'estado': estado,
      'invitado_por': invitadoPor,
      'creado_en': creadoEn.toIso8601String(),
      'aceptado_en': aceptadoEn?.toIso8601String(),
    };
  }

  bool get esPendiente => estado == 'pendiente';
  bool get esAceptada => estado == 'aceptada';
  bool get esCancelada => estado == 'cancelada';

  InvitacionEntidad copyWith({
    String? id,
    String? appId,
    String? email,
    RolUsuarioApp? rol,
    String? estado,
    String? invitadoPor,
    DateTime? creadoEn,
    DateTime? aceptadoEn,
  }) {
    return InvitacionEntidad(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
      invitadoPor: invitadoPor ?? this.invitadoPor,
      creadoEn: creadoEn ?? this.creadoEn,
      aceptadoEn: aceptadoEn ?? this.aceptadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvitacionEntidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'InvitacionEntidad(id: $id, email: $email, rol: $rol, estado: $estado)';
  }
}