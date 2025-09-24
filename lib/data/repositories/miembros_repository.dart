import '../../core/types/resultado.dart';
import '../../domain/entities/miembro_entidad.dart';
import '../../domain/entities/invitacion_entidad.dart';
import '../../domain/entities/rol_usuario.dart';
import '../clients/supabase_client.dart';

class MiembrosRepository {
  final SupabaseClientService _client;

  MiembrosRepository(this._client);

  // Obtener miembros de una app
  Future<Resultado<List<MiembroEntidad>>> obtenerMiembros(String appId) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('app_miembros')
          .select()
          .eq('app_id', appId)
          .order('anadido_en', ascending: false);

      return (response as List)
          .map((json) => MiembroEntidad.fromJson(json))
          .toList();
    });
  }

  // Invitar a un usuario
  Future<Resultado<String>> invitarUsuario({
    required String appId,
    required String email,
    required RolUsuarioApp rol,
  }) async {
    return _client.ejecutarRpc<String>(
      'invitar_a_app',
      {
        'p_app_id': appId,
        'p_email': email,
        'p_rol': rol.toString(),
      },
      (data) => data as String,
    );
  }

  // Aceptar invitación
  Future<Resultado<MiembroEntidad>> aceptarInvitacion(String appId) async {
    return _client.ejecutarRpc<MiembroEntidad>(
      'aceptar_invitacion',
      {'p_app_id': appId},
      (data) => MiembroEntidad.fromJson(data[0]),
    );
  }

  // Obtener invitaciones pendientes para el usuario actual
  Future<Resultado<List<InvitacionEntidad>>> obtenerMisInvitaciones() async {
    return _client.ejecutarQuery(() async {
      final email = _client.usuarioActualEmail;
      if (email == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.client
          .from('app_invitaciones')
          .select()
          .ilike('email', email)
          .eq('estado', 'pendiente')
          .order('creado_en', ascending: false);

      return (response as List)
          .map((json) => InvitacionEntidad.fromJson(json))
          .toList();
    });
  }

  // Obtener invitaciones de una app (para admins)
  Future<Resultado<List<InvitacionEntidad>>> obtenerInvitacionesApp(
    String appId,
  ) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('app_invitaciones')
          .select()
          .eq('app_id', appId)
          .order('creado_en', ascending: false);

      return (response as List)
          .map((json) => InvitacionEntidad.fromJson(json))
          .toList();
    });
  }

  // Actualizar rol de miembro
  Future<Resultado<MiembroEntidad>> actualizarRolMiembro({
    required String appId,
    required String userId,
    required RolUsuarioApp nuevoRol,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .from('app_miembros')
          .update({'rol': nuevoRol.toString()})
          .eq('app_id', appId)
          .eq('user_id', userId)
          .select()
          .single();

      return MiembroEntidad.fromJson(response);
    });
  }

  // Eliminar miembro
  Future<Resultado<void>> eliminarMiembro({
    required String appId,
    required String userId,
  }) async {
    return _client.ejecutarQuery(() async {
      await _client.client
          .from('app_miembros')
          .delete()
          .eq('app_id', appId)
          .eq('user_id', userId);
    });
  }

  // Cancelar invitación
  Future<Resultado<void>> cancelarInvitacion(String invitacionId) async {
    return _client.ejecutarQuery(() async {
      await _client.client
          .from('app_invitaciones')
          .update({'estado': 'cancelada'})
          .eq('id', invitacionId);
    });
  }

  // Obtener mi rol en una app
  Future<Resultado<RolUsuarioApp?>> obtenerMiRol(String appId) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client
          .rpc('mi_rol_en_app', params: {'p_app_id': appId});

      return response != null ? RolUsuarioApp.fromString(response) : null;
    });
  }

  // Verificar si tengo rol mínimo
  Future<Resultado<bool>> tieneRolMinimo({
    required String appId,
    required RolUsuarioApp rolMinimo,
  }) async {
    return _client.ejecutarQuery(() async {
      final response = await _client.client.rpc(
        'tiene_rol_minimo',
        params: {
          'p_app_id': appId,
          'p_min': rolMinimo.toString(),
        },
      );

      return response as bool;
    });
  }
}