class UnidadMedidaEntidad {
  final String id;
  final String appId;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  const UnidadMedidaEntidad({
    required this.id,
    required this.appId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  factory UnidadMedidaEntidad.fromJson(Map<String, dynamic> json) {
    return UnidadMedidaEntidad(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      codigo: json['codigo'] as String,
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
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'creado_en': creadoEn.toIso8601String(),
      'actualizado_en': actualizadoEn.toIso8601String(),
    };
  }

  UnidadMedidaEntidad copyWith({
    String? id,
    String? appId,
    String? codigo,
    String? nombre,
    String? descripcion,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return UnidadMedidaEntidad(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnidadMedidaEntidad && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UnidadMedidaEntidad(id: $id, codigo: $codigo, nombre: $nombre)';
  }
}