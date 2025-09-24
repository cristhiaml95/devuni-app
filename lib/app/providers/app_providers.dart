import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/clients/supabase_client.dart';
import '../../data/repositories/apps_repository.dart';
import '../../data/repositories/miembros_repository.dart';
import '../../data/repositories/inventario_repository_simple.dart';
import '../../domain/entities/rol_usuario.dart';
import '../../core/types/resultado.dart';

// Provider del cliente Supabase
final supabaseClientProvider = Provider<SupabaseClientService>((ref) {
  return SupabaseClientService.instance;
});

// Providers de repositorios
final appsRepositoryProvider = Provider<AppsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AppsRepository(client);
});

final miembrosRepositoryProvider = Provider<MiembrosRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MiembrosRepository(client);
});

final inventarioRepositoryProvider = Provider<InventarioRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return InventarioRepository(client);
});

// Provider de sesión del usuario
final sesionUsuarioProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((data) => data.session?.user);
});

// Provider del usuario actual (estado, no stream)
final usuarioActualProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser;
});

// Provider de la app actual seleccionada
final appActualIdProvider = StateProvider<String?>((ref) => null);

// Provider del rol del usuario en la app actual
final rolUsuarioActualProvider = FutureProvider<RolUsuarioApp?>((ref) async {
  final appId = ref.watch(appActualIdProvider);
  if (appId == null) return null;

  final miembrosRepo = ref.watch(miembrosRepositoryProvider);
  final resultado = await miembrosRepo.obtenerMiRol(appId);

  return resultado.fold(
    siExito: (rol) => rol,
    siError: (error) => null,
  );
});

// Provider helper para verificar permisos
final verificadorPermisosProvider = Provider<VerificadorPermisos>((ref) {
  return VerificadorPermisos(ref);
});

class VerificadorPermisos {
  final Ref _ref;

  VerificadorPermisos(this._ref);

  // Verificar si está autenticado
  bool get estaAutenticado {
    final usuario = _ref.read(usuarioActualProvider);
    return usuario != null;
  }

  // Verificar si tiene una app seleccionada
  bool get tieneAppSeleccionada {
    final appId = _ref.read(appActualIdProvider);
    return appId != null;
  }

  // Verificar si puede realizar una acción (rol mínimo)
  bool puedeHacer(RolUsuarioApp rolMinimo) {
    final rolActual = _ref.read(rolUsuarioActualProvider).value;
    if (rolActual == null) return false;

    return rolActual.puedeHacer(rolMinimo);
  }

  // Verificar permisos específicos
  bool get puedeVer => true; // Todos pueden ver si tienen acceso a la app
  bool get puedeCrear => puedeHacer(RolUsuarioApp.colaborador);
  bool get puedeEditar => puedeHacer(RolUsuarioApp.colaborador);
  bool get puedeAdministrar => puedeHacer(RolUsuarioApp.administrador);
  bool get esPropietario => puedeHacer(RolUsuarioApp.propietario);
}