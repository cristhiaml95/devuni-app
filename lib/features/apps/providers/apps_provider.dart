import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_providers.dart';
import '../models/app_model.dart';

/// Provider para gestionar el estado de Apps del usuario actual
final userAppsProvider = StreamProvider<List<AppModel>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);

  // Keepalive para mantener el provider estable
  ref.keepAlive();

  if (user == null) {
    print('📱 APPS: Usuario no autenticado, devolviendo lista vacía');
    return Stream.value([]);
  }

  print('📱 APPS: Obteniendo Apps para usuario: ${user.email}');

  // Crear stream simple sin polling para evitar problemas de autenticación
  return Stream.fromFuture(_fetchUserAppsRPC(client));
});

/// Helper para obtener user apps via RPC
Future<List<AppModel>> _fetchUserAppsRPC(SupabaseClient client) async {
  try {
    final response = await client.rpc('get_user_apps');

    if (response is List) {
      final apps = response.map((json) => AppModel.fromJson(json)).toList();
      print('📱 APPS: Obtenidos ${apps.length} Apps via RPC');
      return apps;
    }

    return [];
  } catch (e) {
    print(
        '❌ APPS: Error obteniendo user apps (funciones RPC no configuradas): $e');
    // Devolver datos de ejemplo para testing si no están las funciones RPC
    return [
      AppModel(
        id: 'demo-1',
        name: 'Mi Inventario Demo',
        description: 'App de demostración para testing',
        ownerId: 'current-user',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
    ];
  }
}

/// Provider para el App actualmente seleccionado
final selectedAppProvider = StateProvider<AppModel?>((ref) => null);

/// Provider para Apps donde el usuario es miembro (no owner)
final memberAppsProvider = StreamProvider<List<AppModel>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);

  // Keepalive para mantener el provider estable
  ref.keepAlive();

  if (user == null) {
    return Stream.value([]);
  }

  print('📱 APPS: Obteniendo Apps donde usuario es miembro');

  // Crear stream simple sin polling para evitar problemas de autenticación
  return Stream.fromFuture(_fetchMemberAppsRPC(client));
});

/// Helper para obtener member apps via RPC
Future<List<AppModel>> _fetchMemberAppsRPC(SupabaseClient client) async {
  try {
    // Obtener el ID del usuario actual
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      print('❌ APPS: Usuario no autenticado para obtener member apps');
      return [];
    }

    final response = await client.rpc('get_member_apps', params: {
      'user_uuid': userId,
    });

    if (response is List) {
      final apps = response.map((json) => AppModel.fromJson(json)).toList();
      print('📱 APPS: Obtenidos ${apps.length} member Apps via RPC');
      return apps;
    }

    return [];
  } catch (e) {
    print(
        '❌ APPS: Error obteniendo member apps (funciones RPC no configuradas): $e');
    // Devolver datos de ejemplo para testing si no están las funciones RPC
    return [
      AppModel(
        id: 'shared-1',
        name: 'Inventario Compartido',
        description: 'App compartida como miembro',
        ownerId: 'other-user',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
    ];
  }
}

/// Provider para operaciones CRUD de Apps
final appsRepositoryProvider = Provider<AppsRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return AppsRepository(client);
});

/// Repositorio para operaciones de Apps
class AppsRepository {
  final SupabaseClient _client;

  AppsRepository(this._client);

  /// Crear un nuevo App usando RPC
  Future<AppModel> createApp({
    required String name,
    String? description,
  }) async {
    print('📱 APPS: Creando nuevo App: $name');

    try {
      // Obtener el ID del usuario actual
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.rpc('create_app_and_membership', params: {
        'user_uuid': userId,
        'app_name': name,
        'app_description': description ?? '',
      });

      if (response is List && response.isNotEmpty) {
        // La función devuelve una tabla con información del app creado
        final appData = response[0];
        print('✅ APPS: App creado exitosamente: ${appData}');

        return AppModel.fromJson(appData);
      } else {
        throw Exception('No se pudo crear la App');
      }
    } catch (e) {
      print('❌ APPS: Error creando App (funciones RPC no configuradas): $e');
      // Simular creación exitosa para testing
      final newApp = AppModel(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description ?? '',
        ownerId: 'current-user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );
      print('✅ APPS: App simulado creado para testing: ${newApp.id}');
      return newApp;
    }
  }

  /// Actualizar un App existente
  Future<AppModel> updateApp({
    required String appId,
    String? name,
    String? description,
    String? logoUrl,
    bool? isActive,
  }) async {
    print('📱 APPS: Actualizando App: $appId');

    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (logoUrl != null) updateData['logo_url'] = logoUrl;
      if (isActive != null) updateData['is_active'] = isActive;

      final response = await _client
          .from('apps')
          .update(updateData)
          .eq('id', appId)
          .select()
          .single();

      print('✅ APPS: App actualizado exitosamente');
      return AppModel.fromJson(response);
    } catch (e) {
      print('❌ APPS: Error actualizando App: $e');
      rethrow;
    }
  }

  /// Eliminar un App (soft delete)
  Future<void> deleteApp(String appId) async {
    print('📱 APPS: Eliminando App: $appId');

    try {
      await _client.from('apps').update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', appId);

      print('✅ APPS: App eliminado exitosamente');
    } catch (e) {
      print('❌ APPS: Error eliminando App: $e');
      rethrow;
    }
  }

  /// Obtener un App específico por ID
  Future<AppModel?> getAppById(String appId) async {
    print('📱 APPS: Obteniendo App por ID: $appId');

    try {
      final response = await _client
          .from('apps')
          .select()
          .eq('id', appId)
          .eq('is_active', true)
          .single();

      return AppModel.fromJson(response);
    } catch (e) {
      print('❌ APPS: App no encontrado: $e');
      return null;
    }
  }

  /// Verificar si el usuario tiene acceso a un App
  Future<AppMemberModel?> getUserAppMembership({
    required String appId,
    required String userId,
  }) async {
    print('📱 APPS: Verificando membresía: userId=$userId, appId=$appId');

    try {
      final response = await _client
          .from('app_members')
          .select()
          .eq('app_id', appId)
          .eq('user_id', userId)
          .eq('is_active', true)
          .single();

      return AppMemberModel.fromJson(response);
    } catch (e) {
      print('❌ APPS: Membresía no encontrada: $e');
      return null;
    }
  }

  /// Invitar usuario a un App
  Future<AppMemberModel> inviteUserToApp({
    required String appId,
    required String userId,
    required AppRole role,
  }) async {
    print('📱 APPS: Invitando usuario a App: $userId -> $appId (rol: $role)');

    try {
      final response = await _client
          .from('app_members')
          .insert({
            'app_id': appId,
            'user_id': userId,
            'role': role.value,
            'invited_at': DateTime.now().toIso8601String(),
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      print('✅ APPS: Usuario invitado exitosamente');
      return AppMemberModel.fromJson(response);
    } catch (e) {
      print('❌ APPS: Error invitando usuario: $e');
      rethrow;
    }
  }
}
