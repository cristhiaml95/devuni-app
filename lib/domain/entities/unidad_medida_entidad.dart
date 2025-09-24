class UnidadMedidaEntidad {
  final String id;
  final String appId;
  final String nombre;
  final String simbolo;
  final bool esDecimal;
  final String? descripcion;
  final DateTime creadoEn;
  final DateTime actualizadoEn;

  const UnidadMedidaEntidad({
    required this.id,
    required this.appId,
    required this.nombre,
    required this.simbolo,
    required this.esDecimal,
    this.descripcion,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  factory UnidadMedidaEntidad.fromJson(Map<String, dynamic> json) {
    return UnidadMedidaEntidad(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      nombre: json['nombre'] as String,
      simbolo: json['simbolo'] as String,
      esDecimal: json['es_decimal'] as bool,
      descripcion: json['descripcion'] as String?,
      creadoEn: DateTime.parse(json['created_at'] as String),
      actualizadoEn: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'nombre': nombre,
      'simbolo': simbolo,
      'es_decimal': esDecimal,
      'descripcion': descripcion,
      'created_at': creadoEn.toIso8601String(),
      'updated_at': actualizadoEn.toIso8601String(),
    };
  }

  UnidadMedidaEntidad copyWith({
    String? id,
    String? appId,
    String? nombre,
    String? simbolo,
    bool? esDecimal,
    String? descripcion,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return UnidadMedidaEntidad(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      nombre: nombre ?? this.nombre,
      simbolo: simbolo ?? this.simbolo,
      esDecimal: esDecimal ?? this.esDecimal,
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
    return 'UnidadMedidaEntidad(id: $id, nombre: $nombre, simbolo: $simbolo)';
  }
}