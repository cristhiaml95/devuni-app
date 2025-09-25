// ============================================
// CATALOGOS PROVIDER - DEVUNI APP
// ============================================
// Providers Riverpod para la gestión de catálogos base:
// - Unidades de Medida
// - Categorías de Inventario
// - Almacenes

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/supabase_providers.dart';
import '../../domain/models.dart';

// ============================================
// UNIDADES DE MEDIDA
// ============================================

/// Proveedor de lista de unidades de medida para la app seleccionada
final unidadesMedidaProvider = StreamNotifierProvider.autoDispose
    .family<UnidadesMedidaNotifier, List<UnidadMedida>, String>(
  UnidadesMedidaNotifier.new,
);

class UnidadesMedidaNotifier
    extends AutoDisposeFamilyStreamNotifier<List<UnidadMedida>, String> {
  @override
  Stream<List<UnidadMedida>> build(String appId) async* {
    if (appId.isEmpty) {
      yield [];
      return;
    }

    final supabase = ref.read(supabaseClientProvider);

    try {
      final stream = supabase
          .from('unidades_medida')
          .stream(primaryKey: ['id'])
          .eq('app_id', appId)
          .order('codigo');

      await for (final data in stream) {
        final unidades =
            data.map((json) => UnidadMedida.fromSupabase(json)).toList();
        yield unidades;
      }
    } catch (error) {
      print('Error en unidadesMedidaProvider: $error');
      yield [];
    }
  }

  Future<UnidadMedida?> crear(UnidadMedida unidad) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase
          .from('unidades_medida')
          .insert(unidad.toSupabaseInsert())
          .select()
          .single();

      return UnidadMedida.fromSupabase(response);
    } catch (error) {
      print('Error al crear unidad: $error');
      throw Exception('No se pudo crear la unidad: $error');
    }
  }

  Future<UnidadMedida?> actualizar(UnidadMedida unidad) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase
          .from('unidades_medida')
          .update(unidad.toSupabaseUpdate())
          .eq('id', unidad.id)
          .select()
          .single();

      return UnidadMedida.fromSupabase(response);
    } catch (error) {
      print('Error al actualizar unidad: $error');
      throw Exception('No se pudo actualizar la unidad: $error');
    }
  }

  Future<bool> eliminar(String unidadId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      // Verificar si la unidad está siendo usada
      final productos = await supabase
          .from('productos_inventario')
          .select('id')
          .eq('unidad_medida_id', unidadId)
          .limit(1);

      if (productos.isNotEmpty) {
        throw Exception(
            'No se puede eliminar la unidad porque está siendo usada por productos');
      }

      await supabase.from('unidades_medida').delete().eq('id', unidadId);

      return true;
    } catch (error) {
      print('Error al eliminar unidad: $error');
      throw Exception('No se pudo eliminar la unidad: $error');
    }
  }
}

// ============================================
// CATEGORIAS DE INVENTARIO
// ============================================

/// Proveedor de lista de categorías de inventario para la app seleccionada
final categoriasInventarioProvider = StreamNotifierProvider.autoDispose
    .family<CategoriasInventarioNotifier, List<CategoriaInventario>, String>(
  CategoriasInventarioNotifier.new,
);

class CategoriasInventarioNotifier
    extends AutoDisposeFamilyStreamNotifier<List<CategoriaInventario>, String> {
  @override
  Stream<List<CategoriaInventario>> build(String appId) async* {
    if (appId.isEmpty) {
      yield [];
      return;
    }

    final supabase = ref.read(supabaseClientProvider);

    try {
      final stream = supabase
          .from('categorias_inventario')
          .stream(primaryKey: ['id'])
          .eq('app_id', appId)
          .order('codigo');

      await for (final data in stream) {
        final categorias =
            data.map((json) => CategoriaInventario.fromSupabase(json)).toList();
        yield categorias;
      }
    } catch (error) {
      print('Error en categoriasInventarioProvider: $error');
      yield [];
    }
  }

  Future<CategoriaInventario?> crear(CategoriaInventario categoria) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase
          .from('categorias_inventario')
          .insert(categoria.toSupabaseInsert())
          .select()
          .single();

      return CategoriaInventario.fromSupabase(response);
    } catch (error) {
      print('Error al crear categoría: $error');
      throw Exception('No se pudo crear la categoría: $error');
    }
  }

  Future<CategoriaInventario?> actualizar(CategoriaInventario categoria) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase
          .from('categorias_inventario')
          .update(categoria.toSupabaseUpdate())
          .eq('id', categoria.id)
          .select()
          .single();

      return CategoriaInventario.fromSupabase(response);
    } catch (error) {
      print('Error al actualizar categoría: $error');
      throw Exception('No se pudo actualizar la categoría: $error');
    }
  }

  Future<bool> eliminar(String categoriaId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      // Verificar si la categoría está siendo usada
      final productos = await supabase
          .from('productos_inventario')
          .select('id')
          .eq('categoria_id', categoriaId)
          .limit(1);

      if (productos.isNotEmpty) {
        throw Exception(
            'No se puede eliminar la categoría porque está siendo usada por productos');
      }

      await supabase
          .from('categorias_inventario')
          .delete()
          .eq('id', categoriaId);

      return true;
    } catch (error) {
      print('Error al eliminar categoría: $error');
      throw Exception('No se pudo eliminar la categoría: $error');
    }
  }
}

// ============================================
// ALMACENES
// ============================================

/// Proveedor de lista de almacenes para la app seleccionada
final almacenesProvider = StreamNotifierProvider.autoDispose
    .family<AlmacenesNotifier, List<Almacen>, String>(
  AlmacenesNotifier.new,
);

class AlmacenesNotifier
    extends AutoDisposeFamilyStreamNotifier<List<Almacen>, String> {
  @override
  Stream<List<Almacen>> build(String appId) async* {
    if (appId.isEmpty) {
      yield [];
      return;
    }

    final supabase = ref.read(supabaseClientProvider);

    try {
      final stream = supabase
          .from('almacenes')
          .stream(primaryKey: ['id'])
          .eq('app_id', appId)
          .order('es_principal', ascending: false)
          .order('codigo');

      await for (final data in stream) {
        final almacenes =
            data.map((json) => Almacen.fromSupabase(json)).toList();
        yield almacenes;
      }
    } catch (error) {
      print('Error en almacenesProvider: $error');
      yield [];
    }
  }

  Future<Almacen?> crear(Almacen almacen) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase
          .from('almacenes')
          .insert(almacen.toSupabaseInsert())
          .select()
          .single();

      return Almacen.fromSupabase(response);
    } catch (error) {
      print('Error al crear almacén: $error');
      throw Exception('No se pudo crear el almacén: $error');
    }
  }

  Future<Almacen?> actualizar(Almacen almacen) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase
          .from('almacenes')
          .update(almacen.toSupabaseUpdate())
          .eq('id', almacen.id)
          .select()
          .single();

      return Almacen.fromSupabase(response);
    } catch (error) {
      print('Error al actualizar almacén: $error');
      throw Exception('No se pudo actualizar el almacén: $error');
    }
  }

  Future<bool> eliminar(String almacenId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      // Verificar si el almacén está siendo usado
      final movimientos = await supabase
          .from('movimientos_inventario')
          .select('id')
          .eq('almacen_id', almacenId)
          .limit(1);

      if (movimientos.isNotEmpty) {
        throw Exception(
            'No se puede eliminar el almacén porque tiene movimientos de inventario');
      }

      await supabase.from('almacenes').delete().eq('id', almacenId);

      return true;
    } catch (error) {
      print('Error al eliminar almacén: $error');
      throw Exception('No se pudo eliminar el almacén: $error');
    }
  }

  /// Marcar como almacén principal (solo puede haber uno)
  Future<bool> marcarComoPrincipal(String almacenId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      // Usar RPC que maneja la lógica de único principal
      await supabase.rpc('marcar_almacen_principal', params: {
        'p_almacen_id': almacenId,
      });

      return true;
    } catch (error) {
      print('Error al marcar almacén como principal: $error');
      throw Exception('No se pudo marcar el almacén como principal: $error');
    }
  }
}

// ============================================
// PROVIDERS POR ID
// ============================================

/// Provider para una unidad específica por ID
final unidadMedidaPorIdProvider =
    StreamProvider.autoDispose.family<UnidadMedida?, String>((ref, unidadId) {
  if (unidadId.isEmpty) return Stream.value(null);

  final supabase = ref.read(supabaseClientProvider);

  return supabase
      .from('unidades_medida')
      .stream(primaryKey: ['id'])
      .eq('id', unidadId)
      .map((data) {
        if (data.isEmpty) return null;
        return UnidadMedida.fromSupabase(data.first);
      });
});

/// Provider para una categoría específica por ID
final categoriaInventarioPorIdProvider = StreamProvider.autoDispose
    .family<CategoriaInventario?, String>((ref, categoriaId) {
  if (categoriaId.isEmpty) return Stream.value(null);

  final supabase = ref.read(supabaseClientProvider);

  return supabase
      .from('categorias_inventario')
      .stream(primaryKey: ['id'])
      .eq('id', categoriaId)
      .map((data) {
        if (data.isEmpty) return null;
        return CategoriaInventario.fromSupabase(data.first);
      });
});

/// Provider para un almacén específico por ID
final almacenPorIdProvider =
    StreamProvider.autoDispose.family<Almacen?, String>((ref, almacenId) {
  if (almacenId.isEmpty) return Stream.value(null);

  final supabase = ref.read(supabaseClientProvider);

  return supabase
      .from('almacenes')
      .stream(primaryKey: ['id'])
      .eq('id', almacenId)
      .map((data) {
        if (data.isEmpty) return null;
        return Almacen.fromSupabase(data.first);
      });
});

/// Provider para el almacén principal de una app
final almacenPrincipalProvider =
    FutureProvider.autoDispose.family<Almacen?, String>((ref, appId) async {
  if (appId.isEmpty) return null;

  try {
    final supabase = ref.read(supabaseClientProvider);

    final response = await supabase
        .from('almacenes')
        .select()
        .eq('app_id', appId)
        .eq('es_principal', true)
        .eq('activo', true)
        .limit(1);

    if (response.isEmpty) return null;
    return Almacen.fromSupabase(response.first);
  } catch (error) {
    print('Error al obtener almacén principal: $error');
    return null;
  }
});
