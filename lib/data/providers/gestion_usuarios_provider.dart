// ============================================
// GESTION USUARIOS PROVIDER - DEVUNI APP
// ============================================
// Providers Riverpod para la gestión de usuarios:
// - Miembros de Apps
// - Invitaciones
// - Roles y Permisos

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/supabase_providers.dart';
import '../../domain/models.dart';

// ============================================
// MIEMBROS DE APP
// ============================================

/// Proveedor de lista de miembros para la app seleccionada
final miembrosAppProvider = StreamNotifierProvider.autoDispose
    .family<MiembrosAppNotifier, List<AppMiembroConUsuario>, String>(
  MiembrosAppNotifier.new,
);

class MiembrosAppNotifier extends AutoDisposeFamilyStreamNotifier<
    List<AppMiembroConUsuario>, String> {
  @override
  Stream<List<AppMiembroConUsuario>> build(String appId) async* {
    if (appId.isEmpty) {
      yield [];
      return;
    }

    final supabase = ref.read(supabaseClientProvider);

    try {
      // Query con JOIN para obtener datos del usuario
      final stream = supabase
          .from('app_miembros')
          .stream(primaryKey: ['id'])
          .eq('app_id', appId)
          .order('rol', ascending: false) // Propietario primero
          .order('unido_en');

      await for (final data in stream) {
        // Para cada miembro, obtener datos del usuario
        final miembrosConUsuario = <AppMiembroConUsuario>[];

        for (final miembroJson in data) {
          try {
            // Obtener datos del usuario de auth.users y perfiles
            final usuarioResponse =
                await supabase.rpc('obtener_usuario_completo', params: {
              'p_usuario_id': miembroJson['usuario_id'],
            });

            // Combinar datos del miembro con datos del usuario
            final miembroCompleto = {
              ...miembroJson,
              'email': usuarioResponse['email'],
              'nombre_completo': usuarioResponse['nombre_completo'],
              'avatar': usuarioResponse['avatar'],
            };

            miembrosConUsuario
                .add(AppMiembroConUsuario.fromSupabase(miembroCompleto));
          } catch (e) {
            // Si no se pueden obtener datos del usuario, crear miembro básico
            miembrosConUsuario
                .add(AppMiembroConUsuario.fromSupabase(miembroJson));
          }
        }

        yield miembrosConUsuario;
      }
    } catch (error) {
      print('Error en miembrosAppProvider: $error');
      yield [];
    }
  }

  /// Invitar un nuevo miembro
  Future<AppInvitacion?> invitarMiembro(String email, TipoRolApp rol,
      {Duration? duracionExpiracion}) async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      final usuarioActual = ref.read(currentUserProvider);

      if (usuarioActual == null) {
        throw Exception('Usuario no autenticado');
      }

      final expiraEn = duracionExpiracion != null
          ? DateTime.now().add(duracionExpiracion)
          : DateTime.now().add(const Duration(days: 7)); // 7 días por defecto

      final response = await supabase.rpc('crear_invitacion_app', params: {
        'p_app_id': arg,
        'p_email': email.trim().toLowerCase(),
        'p_rol': rol.toDb(),
        'p_invitado_por': usuarioActual.id,
        'p_expira_en': expiraEn.toIso8601String(),
      });

      return AppInvitacion.fromSupabase(response);
    } catch (error) {
      print('Error al invitar miembro: $error');
      throw Exception('No se pudo enviar la invitación: $error');
    }
  }

  /// Cambiar rol de un miembro existente
  Future<AppMiembro?> cambiarRol(String miembroId, TipoRolApp nuevoRol) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      final response = await supabase
          .from('app_miembros')
          .update({'rol': nuevoRol.toDb()})
          .eq('id', miembroId)
          .select()
          .single();

      return AppMiembro.fromSupabase(response);
    } catch (error) {
      print('Error al cambiar rol: $error');
      throw Exception('No se pudo cambiar el rol: $error');
    }
  }

  /// Desactivar un miembro (no puede eliminar, por auditoría)
  Future<bool> desactivarMiembro(String miembroId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      await supabase
          .from('app_miembros')
          .update({'activo': false}).eq('id', miembroId);

      return true;
    } catch (error) {
      print('Error al desactivar miembro: $error');
      throw Exception('No se pudo desactivar el miembro: $error');
    }
  }

  /// Reactivar un miembro
  Future<bool> reactivarMiembro(String miembroId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      await supabase
          .from('app_miembros')
          .update({'activo': true}).eq('id', miembroId);

      return true;
    } catch (error) {
      print('Error al reactivar miembro: $error');
      throw Exception('No se pudo reactivar el miembro: $error');
    }
  }
}

// ============================================
// INVITACIONES
// ============================================

/// Proveedor de lista de invitaciones para la app seleccionada
final invitacionesAppProvider = StreamNotifierProvider.autoDispose
    .family<InvitacionesAppNotifier, List<AppInvitacionConInvitador>, String>(
  InvitacionesAppNotifier.new,
);

class InvitacionesAppNotifier extends AutoDisposeFamilyStreamNotifier<
    List<AppInvitacionConInvitador>, String> {
  @override
  Stream<List<AppInvitacionConInvitador>> build(String appId) async* {
    if (appId.isEmpty) {
      yield [];
      return;
    }

    final supabase = ref.read(supabaseClientProvider);

    try {
      final stream = supabase
          .from('app_invitaciones')
          .stream(primaryKey: ['id'])
          .eq('app_id', appId)
          .order('creado_en', ascending: false);

      await for (final data in stream) {
        // Para cada invitación, obtener datos del invitador
        final invitacionesConInvitador = <AppInvitacionConInvitador>[];

        for (final invitacionJson in data) {
          try {
            // Obtener datos del invitador
            final invitadorResponse =
                await supabase.rpc('obtener_usuario_completo', params: {
              'p_usuario_id': invitacionJson['invitado_por'],
            });

            // Combinar datos
            final invitacionCompleta = {
              ...invitacionJson,
              'email_invitador': invitadorResponse['email'],
              'nombre_invitador': invitadorResponse['nombre_completo'],
              'avatar_invitador': invitadorResponse['avatar'],
            };

            invitacionesConInvitador.add(
                AppInvitacionConInvitador.fromSupabase(invitacionCompleta));
          } catch (e) {
            // Si no se pueden obtener datos del invitador, crear invitación básica
            invitacionesConInvitador
                .add(AppInvitacionConInvitador.fromSupabase(invitacionJson));
          }
        }

        yield invitacionesConInvitador;
      }
    } catch (error) {
      print('Error en invitacionesAppProvider: $error');
      yield [];
    }
  }

  /// Cancelar una invitación pendiente
  Future<bool> cancelarInvitacion(String invitacionId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      await supabase
          .from('app_invitaciones')
          .update({
            'estado': EstadoInvitacion.cancelada.toDbString(),
          })
          .eq('id', invitacionId)
          .eq('estado', EstadoInvitacion.pendiente.toDbString());

      return true;
    } catch (error) {
      print('Error al cancelar invitación: $error');
      throw Exception('No se pudo cancelar la invitación: $error');
    }
  }

  /// Reenviar una invitación (actualiza token y fecha de expiración)
  Future<bool> reenviarInvitacion(String invitacionId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);

      await supabase.rpc('reenviar_invitacion_app', params: {
        'p_invitacion_id': invitacionId,
      });

      return true;
    } catch (error) {
      print('Error al reenviar invitación: $error');
      throw Exception('No se pudo reenviar la invitación: $error');
    }
  }
}

/// Proveedor para aceptar invitaciones (por token público)
final aceptarInvitacionProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, token) async {
  if (token.isEmpty) return false;

  try {
    final supabase = ref.read(supabaseClientProvider);

    await supabase.rpc('aceptar_invitacion_app', params: {
      'p_token': token,
    });

    return true;
  } catch (error) {
    print('Error al aceptar invitación: $error');
    return false;
  }
});

// ============================================
// PERMISOS Y ROLES
// ============================================

/// Provider para verificar permisos del usuario actual en una app
final permisosUsuarioAppProvider = FutureProvider.autoDispose
    .family<PermisosUsuario?, String>((ref, appId) async {
  if (appId.isEmpty) return null;

  try {
    final supabase = ref.read(supabaseClientProvider);
    final usuarioActual = ref.read(currentUserProvider);

    if (usuarioActual == null) return null;

    final response = await supabase
        .from('app_miembros')
        .select('rol, activo')
        .eq('app_id', appId)
        .eq('usuario_id', usuarioActual.id)
        .eq('activo', true)
        .limit(1);

    if (response.isEmpty) return null;

    final rol = TipoRolApp.fromString(response.first['rol'] as String);
    return PermisosUsuario(rol: rol);
  } catch (error) {
    print('Error al obtener permisos: $error');
    return null;
  }
});

/// Clase para encapsular permisos del usuario
class PermisosUsuario {
  final TipoRolApp rol;

  const PermisosUsuario({required this.rol});

  /// Verificaciones de permisos
  bool get puedeVer => rol.puedeVer;
  bool get puedeEditar => rol.puedeEditar;
  bool get puedeGestionarUsuarios => rol.puedeGestionarUsuarios;
  bool get esPropietario => rol.esProprietario;

  /// Puede invitar usuarios
  bool get puedeInvitar => puedeGestionarUsuarios;

  /// Puede cambiar roles (solo admin y propietario)
  bool get puedeCambiarRoles => puedeGestionarUsuarios;

  /// Puede eliminar/desactivar miembros
  bool get puedeGestionarMiembros => puedeGestionarUsuarios;

  /// Roles que puede asignar
  List<TipoRolApp> get rolesQueCanAsignar => rol.rolesQueCanAsignar();

  /// Puede asignar un rol específico
  bool puedeAsignarRol(TipoRolApp rolAAsignar) {
    return rolesQueCanAsignar.contains(rolAAsignar);
  }
}

// ============================================
// ESTADÍSTICAS DE USUARIOS
// ============================================

/// Provider para estadísticas de usuarios de una app
final estadisticasUsuariosProvider = FutureProvider.autoDispose
    .family<EstadisticasUsuarios, String>((ref, appId) async {
  if (appId.isEmpty) {
    return EstadisticasUsuarios.vacio();
  }

  try {
    final supabase = ref.read(supabaseClientProvider);

    final response =
        await supabase.rpc('obtener_estadisticas_usuarios', params: {
      'p_app_id': appId,
    });

    return EstadisticasUsuarios.fromJson(response);
  } catch (error) {
    print('Error al obtener estadísticas de usuarios: $error');
    return EstadisticasUsuarios.vacio();
  }
});

/// Modelo para estadísticas de usuarios
class EstadisticasUsuarios {
  final int totalMiembros;
  final int miembrosActivos;
  final int invitacionesPendientes;
  final int invitacionesExpiradas;
  final Map<String, int> miembrosPorRol;

  const EstadisticasUsuarios({
    required this.totalMiembros,
    required this.miembrosActivos,
    required this.invitacionesPendientes,
    required this.invitacionesExpiradas,
    required this.miembrosPorRol,
  });

  factory EstadisticasUsuarios.fromJson(Map<String, dynamic> json) {
    return EstadisticasUsuarios(
      totalMiembros: json['total_miembros'] as int? ?? 0,
      miembrosActivos: json['miembros_activos'] as int? ?? 0,
      invitacionesPendientes: json['invitaciones_pendientes'] as int? ?? 0,
      invitacionesExpiradas: json['invitaciones_expiradas'] as int? ?? 0,
      miembrosPorRol:
          Map<String, int>.from(json['miembros_por_rol'] as Map? ?? {}),
    );
  }

  factory EstadisticasUsuarios.vacio() {
    return const EstadisticasUsuarios(
      totalMiembros: 0,
      miembrosActivos: 0,
      invitacionesPendientes: 0,
      invitacionesExpiradas: 0,
      miembrosPorRol: {},
    );
  }

  /// Número de miembros inactivos
  int get miembrosInactivos => totalMiembros - miembrosActivos;

  /// Porcentaje de miembros activos
  double get porcentajeMiembrosActivos {
    if (totalMiembros == 0) return 0.0;
    return (miembrosActivos / totalMiembros) * 100;
  }
}
