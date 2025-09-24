class AppEntidad {
  final String id;
  final String propietarioId;
  final String nombre;
  final String? descripcion;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  const AppEntidad({
    required this.id,
    required this.propietarioId,
    required this.nombre,
    this.descripcion,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  factory AppEntidad.fromJson(Map<String, dynamic> json) {
    return AppEntidad(
      id: json['id'] as String,
      propietarioId: json['propietario_id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      actualizadoEn: DateTime.parse(json['actualizado_en'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propietario_id': propietarioId,
      'nombre': nombre,
      'descripcion': descripcion,
      'creado_en': creadoEn.toIso8601String(),
      'actualizado_en': actualizadoEn.toIso8601String(),
    };
  }

  AppEntidad copyWith({
    String? id,
    String? propietarioId,
    String? nombre,
    String? descripcion,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return AppEntidad(
      id: id ?? this.id,
      propietarioId: propietarioId ?? this.propietarioId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppEntidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppEntidad(id: $id, nombre: $nombre)';
  }
}