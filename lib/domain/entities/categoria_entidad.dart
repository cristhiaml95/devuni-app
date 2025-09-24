class CategoriaEntidad {
  final String id;
  final String appId;
  final String nombre;
  final String? descripcion;
  final String? color;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  const CategoriaEntidad({
    required this.id,
    required this.appId,
    required this.nombre,
    this.descripcion,
    this.color,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  factory CategoriaEntidad.fromJson(Map<String, dynamic> json) {
    return CategoriaEntidad(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      color: json['color'] as String?,
      creadoEn: DateTime.parse(json['created_at'] as String),
      actualizadoEn: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'nombre': nombre,
      'descripcion': descripcion,
      'color': color,
      'created_at': creadoEn.toIso8601String(),
      'updated_at': actualizadoEn.toIso8601String(),
    };
  }

  CategoriaEntidad copyWith({
    String? id,
    String? appId,
    String? nombre,
    String? descripcion,
    String? color,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return CategoriaEntidad(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      color: color ?? this.color,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoriaEntidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoriaEntidad(id: $id, nombre: $nombre)';
  }
}