class AlmacenEntidad {
  final String id;
  final String appId;
  final String nombre;
  final String? direccion;
  final String? notas;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  const AlmacenEntidad({
    required this.id,
    required this.appId,
    required this.nombre,
    this.direccion,
    this.notas,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  factory AlmacenEntidad.fromJson(Map<String, dynamic> json) {
    return AlmacenEntidad(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String?,
      notas: json['notas'] as String?,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      actualizadoEn: DateTime.parse(json['actualizado_en'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'nombre': nombre,
      'direccion': direccion,
      'notas': notas,
      'creado_en': creadoEn.toIso8601String(),
      'actualizado_en': actualizadoEn.toIso8601String(),
    };
  }

  AlmacenEntidad copyWith({
    String? id,
    String? appId,
    String? nombre,
    String? direccion,
    String? notas,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return AlmacenEntidad(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      notas: notas ?? this.notas,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlmacenEntidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AlmacenEntidad(id: $id, nombre: $nombre)';
  }
}