// ============================================
// UNIDAD MEDIDA MODEL - DEVUNI APP
// ============================================
// Mapeo exacto de la tabla 'unidades_medida' del backend
// Fuente: Auditoría completa del 25 Sep 2025

/// Modelo de Unidad de Medida
/// Fuente DB: tabla public.unidades_medida
class UnidadMedida {
  /// ID único de la unidad (UUID)
  /// DB: unidades_medida.id (PRIMARY KEY)
  final String id;

  /// ID de la app a la que pertenece (UUID)
  /// DB: unidades_medida.app_id (FK → apps.id)
  final String appId;

  /// Código único de la unidad por app
  /// DB: unidades_medida.codigo (NOT NULL, UNIQUE con app_id)
  final String codigo;

  /// Nombre de la unidad
  /// DB: unidades_medida.nombre (NOT NULL)
  final String nombre;

  /// Descripción opcional de la unidad
  /// DB: unidades_medida.descripcion (NULLABLE)
  final String? descripcion;

  /// Fecha de creación
  /// DB: unidades_medida.creado_en (DEFAULT now())
  final DateTime creadoEn;

  /// Fecha de última actualización (auto-actualizada por trigger)
  /// DB: unidades_medida.actualizado_en (DEFAULT now(), trigger: touch_actualizado_en)
  final DateTime actualizadoEn;

  const UnidadMedida({
    required this.id,
    required this.appId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  /// Constructor desde Map de Supabase (nombres de DB)
  factory UnidadMedida.fromSupabase(Map<String, dynamic> data) {
    return UnidadMedida(
      id: data['id'] as String,
      appId: data['app_id'] as String,
      codigo: data['codigo'] as String,
      nombre: data['nombre'] as String,
      descripcion: data['descripcion'] as String?,
      creadoEn: DateTime.parse(data['creado_en'] as String),
      actualizadoEn: DateTime.parse(data['actualizado_en'] as String),
    );
  }

  /// Constructor desde JSON
  factory UnidadMedida.fromJson(Map<String, dynamic> json) {
    return UnidadMedida.fromSupabase(json);
  }

  /// Convierte a Map para inserción en Supabase
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'app_id': appId,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  /// Convierte a Map para actualización en Supabase
  Map<String, dynamic> toSupabaseUpdate() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  /// Crea una copia con campos modificados
  UnidadMedida copyWith({
    String? id,
    String? appId,
    String? codigo,
    String? nombre,
    String? descripcion,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return UnidadMedida(
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnidadMedida &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UnidadMedida{codigo: $codigo, nombre: $nombre}';
}

/// Extensiones para funcionalidad adicional
extension UnidadMedidaExtensions on UnidadMedida {
  /// Validaciones de negocio
  List<String> validar() {
    final errores = <String>[];

    if (codigo.trim().isEmpty) {
      errores.add('El código es requerido');
    }

    if (codigo.trim().length > 10) {
      errores.add('El código no puede exceder 10 caracteres');
    }

    if (nombre.trim().isEmpty) {
      errores.add('El nombre es requerido');
    }

    if (nombre.trim().length > 50) {
      errores.add('El nombre no puede exceder 50 caracteres');
    }

    if (descripcion != null && descripcion!.length > 200) {
      errores.add('La descripción no puede exceder 200 caracteres');
    }

    return errores;
  }

  /// Verifica si la unidad es válida
  bool get esValida => validar().isEmpty;

  /// Formato completo para mostrar (código - nombre)
  String get formatoCompleto => '$codigo - $nombre';

  /// Resumen para listas
  String get resumen {
    if (descripcion != null && descripcion!.isNotEmpty) {
      return '$formatoCompleto: $descripcion';
    }
    return formatoCompleto;
  }
}
