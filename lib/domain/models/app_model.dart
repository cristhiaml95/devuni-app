// ============================================
// APP MODEL - DEVUNI APP
// ============================================
// Mapeo exacto de la tabla 'apps' del backend
// Fuente: Auditoría completa del 25 Sep 2025

/// Modelo principal de una App/Espacio multi-tenant
/// Fuente DB: tabla public.apps
class AppModel {
  /// ID único de la app (UUID)
  /// DB: apps.id (PRIMARY KEY)
  final String id;

  /// ID del propietario de la app (UUID)
  /// DB: apps.propietario_id (FK → auth.users.id)
  final String propietarioId;

  /// Nombre de la app (único por propietario)
  /// DB: apps.nombre (NOT NULL, UNIQUE con propietario_id)
  final String nombre;

  /// Descripción opcional de la app
  /// DB: apps.descripcion (NULLABLE)
  final String? descripcion;

  /// Fecha de creación
  /// DB: apps.creado_en (DEFAULT now())
  final DateTime creadoEn;

  /// Fecha de última actualización (auto-actualizada por trigger)
  /// DB: apps.actualizado_en (DEFAULT now(), trigger: touch_actualizado_en)
  final DateTime actualizadoEn;

  const AppModel({
    required this.id,
    required this.propietarioId,
    required this.nombre,
    this.descripcion,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  /// Constructor desde JSON (para deserialización de Supabase)
  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel.fromSupabase(json);
  }

  /// Constructor desde Map de Supabase (nombres de DB)
  factory AppModel.fromSupabase(Map<String, dynamic> data) {
    return AppModel(
      id: data['id'] as String,
      propietarioId: data['propietario_id'] as String,
      nombre: data['nombre'] as String,
      descripcion: data['descripcion'] as String?,
      creadoEn: DateTime.parse(data['creado_en'] as String),
      actualizadoEn: DateTime.parse(data['actualizado_en'] as String),
    );
  }
}

/// Extensiones para funcionalidad adicional
extension AppModelExtensions on AppModel {
  /// Verifica si el usuario actual es propietario de esta app
  bool soyPropietario(String? userId) {
    return userId != null && propietarioId == userId;
  }

  /// Convierte a Map para inserción/actualización en Supabase
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      // propietario_id se establece automáticamente en RLS
      // id, creado_en, actualizado_en son auto-generados
    };
  }

  /// Convierte a Map para actualización en Supabase
  Map<String, dynamic> toSupabaseUpdate() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      // actualizado_en se actualiza automáticamente por trigger
    };
  }

  /// Validaciones de negocio
  List<String> validar() {
    final errores = <String>[];

    if (nombre.trim().isEmpty) {
      errores.add('El nombre es requerido');
    }

    if (nombre.trim().length < 2) {
      errores.add('El nombre debe tener al menos 2 caracteres');
    }

    if (nombre.trim().length > 100) {
      errores.add('El nombre no puede exceder 100 caracteres');
    }

    if (descripcion != null && descripcion!.length > 500) {
      errores.add('La descripción no puede exceder 500 caracteres');
    }

    return errores;
  }

  /// Verifica si la app es válida
  bool get esValida => validar().isEmpty;

  /// Resumen de la app para mostrar en listas
  String get resumen {
    if (descripcion != null && descripcion!.isNotEmpty) {
      return descripcion!.length > 100
          ? '${descripcion!.substring(0, 97)}...'
          : descripcion!;
    }
    return 'Sin descripción';
  }

  /// Iniciales del nombre para avatares
  String get iniciales {
    final palabras = nombre.trim().split(' ');
    if (palabras.length >= 2) {
      return '${palabras[0][0]}${palabras[1][0]}'.toUpperCase();
    }
    return palabras[0].length >= 2
        ? palabras[0].substring(0, 2).toUpperCase()
        : palabras[0][0].toUpperCase();
  }

  /// Tiempo transcurrido desde la creación
  String get tiempoCreacion {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(creadoEn);

    if (diferencia.inDays > 0) {
      return 'Creada hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return 'Creada hace ${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else {
      return 'Creada recientemente';
    }
  }

  /// Última actualización formateada
  String get ultimaActualizacion {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(actualizadoEn);

    if (diferencia.inDays > 0) {
      return 'Actualizada hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return 'Actualizada hace ${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else if (diferencia.inMinutes > 0) {
      return 'Actualizada hace ${diferencia.inMinutes} minuto${diferencia.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Actualizada ahora';
    }
  }
}
