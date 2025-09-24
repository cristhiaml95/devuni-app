class CategoriaInventarioEntidad {
  final String id;
  final String appId;
  final String nombre;
  final String? descripcion;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  const CategoriaInventarioEntidad({
    required this.id,
    required this.appId,
    required this.nombre,
    this.descripcion,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  factory CategoriaInventarioEntidad.fromJson(Map<String, dynamic> json) {
    return CategoriaInventarioEntidad(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      actualizadoEn: DateTime.parse(json['actualizado_en'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'nombre': nombre,
      'descripcion': descripcion,
      'creado_en': creadoEn.toIso8601String(),
      'actualizado_en': actualizadoEn.toIso8601String(),
    };
  }

  CategoriaInventarioEntidad copyWith({
    String? id,
    String? appId,
    String? nombre,
    String? descripcion,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return CategoriaInventarioEntidad(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoriaInventarioEntidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoriaInventarioEntidad(id: $id, nombre: $nombre)';
  }
}