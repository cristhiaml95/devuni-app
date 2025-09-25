// ============================================
// ALMACEN MODEL - DEVUNI APP
// ============================================
// Mapeo exacto de la tabla 'almacenes' del backend
// Fuente: Auditoría completa del 25 Sep 2025

/// Modelo de Almacén
/// Fuente DB: tabla public.almacenes
class Almacen {
  /// ID único del almacén (UUID)
  /// DB: almacenes.id (PRIMARY KEY)
  final String id;

  /// ID de la app a la que pertenece (UUID)
  /// DB: almacenes.app_id (FK → apps.id)
  final String appId;

  /// Código único del almacén por app
  /// DB: almacenes.codigo (NOT NULL, UNIQUE con app_id)
  final String codigo;

  /// Nombre del almacén
  /// DB: almacenes.nombre (NOT NULL)
  final String nombre;

  /// Descripción opcional del almacén
  /// DB: almacenes.descripcion (NULLABLE)
  final String? descripcion;

  /// Ubicación física del almacén
  /// DB: almacenes.ubicacion (NULLABLE)
  final String? ubicacion;

  /// Indica si es el almacén principal
  /// DB: almacenes.es_principal (DEFAULT false)
  final bool esPrincipal;

  /// Indica si el almacén está activo
  /// DB: almacenes.activo (DEFAULT true)
  final bool activo;

  /// Fecha de creación
  /// DB: almacenes.creado_en (DEFAULT now())
  final DateTime creadoEn;

  /// Fecha de última actualización (auto-actualizada por trigger)
  /// DB: almacenes.actualizado_en (DEFAULT now(), trigger: touch_actualizado_en)
  final DateTime actualizadoEn;

  const Almacen({
    required this.id,
    required this.appId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    this.ubicacion,
    required this.esPrincipal,
    required this.activo,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  /// Constructor desde Map de Supabase (nombres de DB)
  factory Almacen.fromSupabase(Map<String, dynamic> data) {
    return Almacen(
      id: data['id'] as String,
      appId: data['app_id'] as String,
      codigo: data['codigo'] as String,
      nombre: data['nombre'] as String,
      descripcion: data['descripcion'] as String?,
      ubicacion: data['ubicacion'] as String?,
      esPrincipal: data['es_principal'] as bool? ?? false,
      activo: data['activo'] as bool? ?? true,
      creadoEn: DateTime.parse(data['creado_en'] as String),
      actualizadoEn: DateTime.parse(data['actualizado_en'] as String),
    );
  }

  /// Constructor desde JSON
  factory Almacen.fromJson(Map<String, dynamic> json) {
    return Almacen.fromSupabase(json);
  }

  /// Convierte a Map para inserción en Supabase
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'app_id': appId,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'es_principal': esPrincipal,
      'activo': activo,
    };
  }

  /// Convierte a Map para actualización en Supabase
  Map<String, dynamic> toSupabaseUpdate() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'es_principal': esPrincipal,
      'activo': activo,
    };
  }

  /// Crea una copia con campos modificados
  Almacen copyWith({
    String? id,
    String? appId,
    String? codigo,
    String? nombre,
    String? descripcion,
    String? ubicacion,
    bool? esPrincipal,
    bool? activo,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return Almacen(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      ubicacion: ubicacion ?? this.ubicacion,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      activo: activo ?? this.activo,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Almacen && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Almacen{codigo: $codigo, nombre: $nombre, activo: $activo}';
}

/// Extensiones para funcionalidad adicional
extension AlmacenExtensions on Almacen {
  /// Validaciones de negocio
  List<String> validar() {
    final errores = <String>[];

    if (codigo.trim().isEmpty) {
      errores.add('El código es requerido');
    }

    if (codigo.trim().length > 20) {
      errores.add('El código no puede exceder 20 caracteres');
    }

    if (nombre.trim().isEmpty) {
      errores.add('El nombre es requerido');
    }

    if (nombre.trim().length > 100) {
      errores.add('El nombre no puede exceder 100 caracteres');
    }

    if (descripcion != null && descripcion!.length > 300) {
      errores.add('La descripción no puede exceder 300 caracteres');
    }

    if (ubicacion != null && ubicacion!.length > 200) {
      errores.add('La ubicación no puede exceder 200 caracteres');
    }

    return errores;
  }

  /// Verifica si el almacén es válido
  bool get esValido => validar().isEmpty;

  /// Formato completo para mostrar (código - nombre)
  String get formatoCompleto => '$codigo - $nombre';

  /// Resumen para listas
  String get resumen {
    final partes = <String>[formatoCompleto];

    if (ubicacion != null && ubicacion!.isNotEmpty) {
      partes.add('📍 $ubicacion');
    }

    if (esPrincipal) {
      partes.add('⭐ Principal');
    }

    if (!activo) {
      partes.add('❌ Inactivo');
    }

    return partes.join(' | ');
  }

  /// Descripción completa del almacén
  String get descripcionCompleta {
    final buffer = StringBuffer(formatoCompleto);

    if (descripcion != null && descripcion!.isNotEmpty) {
      buffer.write('\n$descripcion');
    }

    if (ubicacion != null && ubicacion!.isNotEmpty) {
      buffer.write('\nUbicación: $ubicacion');
    }

    final estados = <String>[];
    if (esPrincipal) estados.add('Principal');
    if (!activo) estados.add('Inactivo');

    if (estados.isNotEmpty) {
      buffer.write('\nEstado: ${estados.join(', ')}');
    }

    return buffer.toString();
  }

  /// Icono según el estado del almacén
  String get icono {
    if (!activo) return '❌';
    if (esPrincipal) return '⭐';
    return '📦';
  }

  /// Color según el estado (para UI)
  String get colorEstado {
    if (!activo) return '#F44336'; // Rojo
    if (esPrincipal) return '#FF9800'; // Naranja/Dorado
    return '#4CAF50'; // Verde
  }
}
