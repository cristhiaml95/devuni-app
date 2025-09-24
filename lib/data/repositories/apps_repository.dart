import '../../core/types/resultado.dart';
import '../../domain/entities/app_entidad.dart';
import '../clients/supabase_client.dart';

class AppsRepository {
  final SupabaseClientService _client;

  AppsRepository(this._client);

  // Obtener mis apps (propias)
  Future<Resultado<List<AppEntidad>>> obtenerMisApps() async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('vista_apps_propias')
          .select()
          .order('creado_en', ascending: false);

      return (response as List)
          .map((json) => AppEntidad.fromJson(json))
          .toList();
    });
  }

  // Obtener apps compartidas conmigo
  Future<Resultado<List<AppEntidad>>> obtenerAppsCompartidasConmigo() async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('vista_apps_compartidas_conmigo')
          .select()
          .order('creado_en', ascending: false);

      return (response as List)
          .map((json) => AppEntidad.fromJson(json))
          .toList();
    });
  }

  // Obtener todas las apps accesibles
  Future<Resultado<List<AppEntidad>>> obtenerAppsAccesibles() async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('vista_apps_accesibles')
          .select()
          .order('creado_en', ascending: false);

      return (response as List)
          .map((json) => AppEntidad.fromJson(json))
          .toList();
    });
  }

  // Crear nueva app
  Future<Resultado<AppEntidad>> crearApp({
    required String nombre,
    String? descripcion,
  }) async {
    return _client.ejecutarQuery(() async {
      final usuarioId = _client.usuarioActualId;
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.client
          .from('apps')
          .insert({
            'propietario_id': usuarioId,
            'nombre': nombre,
            'descripcion': descripcion,
          })
          .select()
          .single();

      return AppEntidad.fromJson(response);
    });
  }

  // Obtener app por ID
  Future<Resultado<AppEntidad?>> obtenerAppPorId(String appId) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('apps')
          .select()
          .eq('id', appId)
          .maybeSingle();

      return response != null ? AppEntidad.fromJson(response) : null;
    });
  }

  // Actualizar app
  Future<Resultado<AppEntidad>> actualizarApp({
    required String appId,
    required String nombre,
    String? descripcion,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('apps')
          .update({
            'nombre': nombre,
            'descripcion': descripcion,
          })
          .eq('id', appId)
          .select()
          .single();

      return AppEntidad.fromJson(response);
    });
  }

  // Eliminar app
  Future<Resultado<void>> eliminarApp(String appId) async {
    return _client.ejecutarQuery(() async {
      await _client.client
          .from('apps')
          .delete()
          .eq('id', appId);
    });
  }
}