// ============================================
// CATEGORIA INVENTARIO MODEL - DEVUNI APP
// ============================================
// Mapeo exacto de la tabla 'categorias_inventario' del backend
// Fuente: Auditoría completa del 25 Sep 2025

/// Modelo de Categoría de Inventario
/// Fuente DB: tabla public.categorias_inventario
class CategoriaInventario {
  /// ID único de la categoría (UUID)
  /// DB: categorias_inventario.id (PRIMARY KEY)
  final String id;

  /// ID de la app a la que pertenece (UUID)
  /// DB: categorias_inventario.app_id (FK → apps.id)
  final String appId;

  /// Código único de la categoría por app
  /// DB: categorias_inventario.codigo (NOT NULL, UNIQUE con app_id)
  final String codigo;

  /// Nombre de la categoría
  /// DB: categorias_inventario.nombre (NOT NULL)
  final String nombre;

  /// Descripción opcional de la categoría
  /// DB: categorias_inventario.descripcion (NULLABLE)
  final String? descripcion;

  /// Color para UI (hex: #RRGGBB)
  /// DB: categorias_inventario.color (DEFAULT '#808080')
  final String color;

  /// Fecha de creación
  /// DB: categorias_inventario.creado_en (DEFAULT now())
  final DateTime creadoEn;

  /// Fecha de última actualización (auto-actualizada por trigger)
  /// DB: categorias_inventario.actualizado_en (DEFAULT now(), trigger: touch_actualizado_en)
  final DateTime actualizadoEn;

  const CategoriaInventario({
    required this.id,
    required this.appId,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.color,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  /// Constructor desde Map de Supabase (nombres de DB)
  factory CategoriaInventario.fromSupabase(Map<String, dynamic> data) {
    return CategoriaInventario(
      id: data['id'] as String,
      appId: data['app_id'] as String,
      codigo: data['codigo'] as String,
      nombre: data['nombre'] as String,
      descripcion: data['descripcion'] as String?,
      color: data['color'] as String? ?? '#808080',
      creadoEn: DateTime.parse(data['creado_en'] as String),
      actualizadoEn: DateTime.parse(data['actualizado_en'] as String),
    );
  }

  /// Constructor desde JSON
  factory CategoriaInventario.fromJson(Map<String, dynamic> json) {
    return CategoriaInventario.fromSupabase(json);
  }

  /// Convierte a Map para inserción en Supabase
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'app_id': appId,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'color': color,
    };
  }

  /// Convierte a Map para actualización en Supabase
  Map<String, dynamic> toSupabaseUpdate() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'color': color,
    };
  }

  /// Crea una copia con campos modificados
  CategoriaInventario copyWith({
    String? id,
    String? appId,
    String? codigo,
    String? nombre,
    String? descripcion,
    String? color,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return CategoriaInventario(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      color: color ?? this.color,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriaInventario &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoriaInventario{codigo: $codigo, nombre: $nombre}';
}

/// Extensiones para funcionalidad adicional
extension CategoriaInventarioExtensions on CategoriaInventario {
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

    // Validar formato de color hexadecimal
    if (!_esColorHexValido(color)) {
      errores.add('El color debe estar en formato hexadecimal (#RRGGBB)');
    }

    return errores;
  }

  /// Verifica si la categoría es válida
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

  /// Convierte el color hex a un entero
  int get colorInt {
    try {
      final hexColor = color.replaceAll('#', '');
      return int.parse('FF$hexColor', radix: 16);
    } catch (e) {
      // Color por defecto (gris) si hay error
      return 0xFF808080;
    }
  }

  /// Validador privado para color hexadecimal
  bool _esColorHexValido(String color) {
    final RegExp hexColorRegex = RegExp(r'^#([A-Fa-f0-9]{6})$');
    return hexColorRegex.hasMatch(color);
  }
}

/// Colores predefinidos para categorías
class ColoresCategorias {
  static const String azul = '#2196F3';
  static const String verde = '#4CAF50';
  static const String naranja = '#FF9800';
  static const String rojo = '#F44336';
  static const String morado = '#9C27B0';
  static const String cyan = '#00BCD4';
  static const String amarillo = '#FFEB3B';
  static const String rosa = '#E91E63';
  static const String gris = '#808080';
  static const String negro = '#424242';

  /// Lista de colores disponibles
  static const List<String> disponibles = [
    azul,
    verde,
    naranja,
    rojo,
    morado,
    cyan,
    amarillo,
    rosa,
    gris,
    negro,
  ];

  /// Obtiene un color aleatorio de la lista
  static String obtenerAleatorio() {
    final random = DateTime.now().millisecondsSinceEpoch % disponibles.length;
    return disponibles[random];
  }
}
