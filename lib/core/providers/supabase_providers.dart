import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Provider para el cliente de Supabase
/// Inicializa el cliente usando las variables de entorno desde AppConfig
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  print('🔗 RIVERPOD: Inicializando cliente Supabase...');
  
  if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
    throw StateError('❌ Error: URLs de Supabase no configuradas en .env');
  }
  
  print('🔗 RIVERPOD: URL: ${AppConfig.supabaseUrl}');
  print('🔗 RIVERPOD: AnonKey configurada: ${AppConfig.supabaseAnonKey.isNotEmpty}');
  
  final client = SupabaseClient(
    AppConfig.supabaseUrl,
    AppConfig.supabaseAnonKey,
    authOptions: const AuthClientOptions(
      autoRefreshToken: true,
    ),
  );
  
  print('✅ RIVERPOD: Cliente Supabase inicializado correctamente');
  return client;
});

/// Provider para el estado de autenticación actual
/// Escucha los cambios de auth.onAuthStateChange con timeout
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  print('🔐 RIVERPOD: Monitoreando estado de autenticación...');
  
  return client.auth.onAuthStateChange.timeout(
    const Duration(seconds: 10),
    onTimeout: (sink) {
      print('⏰ RIVERPOD: Timeout en autenticación, usando estado inicial');
      // En caso de timeout, crear un AuthState inicial sin sesión
      sink.add(AuthState(AuthChangeEvent.signedOut, null));
    },
  ).map((data) {
    print('🔐 RIVERPOD: Cambio de estado auth: ${data.event}');
    if (data.session?.user != null) {
      print('👤 RIVERPOD: Usuario autenticado: ${data.session!.user.email}');
    } else {
      print('👤 RIVERPOD: Usuario no autenticado');
    }
    return data;
  });
});

/// Provider para obtener el usuario actual
/// Devuelve null si no hay usuario autenticado
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (authData) {
      final user = authData.session?.user;
      if (user != null) {
        print('👤 RIVERPOD: Usuario actual: ${user.email}');
      } else {
        print('👤 RIVERPOD: No hay usuario autenticado');
      }
      return user;
    },
    loading: () {
      print('⏳ RIVERPOD: Cargando estado de autenticación...');
      return null;
    },
    error: (error, stack) {
      print('❌ RIVERPOD: Error en autenticación: $error');
      return null;
    },
  );
});

/// Provider para verificar si el usuario está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  final isAuth = user != null;
  print('🔐 RIVERPOD: Usuario autenticado: $isAuth');
  return isAuth;
});

/// Provider para obtener la sesión actual
final currentSessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (authData) {
      final session = authData.session;
      if (session != null) {
        print('📱 RIVERPOD: Sesión activa hasta: ${session.expiresAt}');
      } else {
        print('📱 RIVERPOD: No hay sesión activa');
      }
      return session;
    },
    loading: () {
      print('⏳ RIVERPOD: Cargando sesión...');
      return null;
    },
    error: (error, stack) {
      print('❌ RIVERPOD: Error cargando sesión: $error');
      return null;
    },
  );
});