class PerfilEntidad {
  final String id;
  final String email;
  final String? nombre;
  final String? avatarUrl;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  const PerfilEntidad({
    required this.id,
    required this.email,
    this.nombre,
    this.avatarUrl,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  factory PerfilEntidad.fromJson(Map<String, dynamic> json) {
    return PerfilEntidad(
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      actualizadoEn: DateTime.parse(json['actualizado_en'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'avatar_url': avatarUrl,
      'creado_en': creadoEn.toIso8601String(),
      'actualizado_en': actualizadoEn.toIso8601String(),
    };
  }

  PerfilEntidad copyWith({
    String? id,
    String? email,
    String? nombre,
    String? avatarUrl,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return PerfilEntidad(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerfilEntidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PerfilEntidad(id: $id, email: $email, nombre: $nombre)';
  }
}