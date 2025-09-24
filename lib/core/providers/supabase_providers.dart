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
      pkceAsyncStorage: null, // Para web, usar storage nativo del navegador
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
    
    // Logging detallado para cada evento
    switch (data.event) {
      case AuthChangeEvent.signedIn:
        print('✅ RIVERPOD: Usuario inició sesión exitosamente');
        if (data.session?.user != null) {
          print('👤 RIVERPOD: Email: ${data.session!.user.email}');
          print('🆔 RIVERPOD: User ID: ${data.session!.user.id}');
        }
        break;
      case AuthChangeEvent.signedOut:
        print('🚪 RIVERPOD: Usuario cerró sesión');
        break;
      case AuthChangeEvent.initialSession:
        print('🏁 RIVERPOD: Sesión inicial detectada');
        if (data.session?.user != null) {
          print('👤 RIVERPOD: Sesión existente para: ${data.session!.user.email}');
        } else {
          print('👤 RIVERPOD: No hay sesión existente');
        }
        break;
      case AuthChangeEvent.tokenRefreshed:
        print('🔄 RIVERPOD: Token refrescado');
        break;
      default:
        print('❓ RIVERPOD: Evento desconocido: ${data.event}');
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

/// Provider para inicializar la sesión OAuth en web
/// Verifica si hay tokens en la URL después de redirect OAuth
final oauthInitializerProvider = FutureProvider<void>((ref) async {
  final client = ref.read(supabaseClientProvider);
  
  try {
    print('🌐 Inicializando OAuth para web...');
    
    // Para web: verificar si hay parámetros OAuth en la URL
    final uri = Uri.base;
    if (uri.fragment.isNotEmpty) {
      print('🔗 Fragmento de URL detectado: ${uri.fragment}');
      
      // Supabase maneja automáticamente la extracción de tokens
      // Solo necesitamos forzar una verificación de sesión
      final session = client.auth.currentSession;
      if (session != null) {
        print('✅ Sesión OAuth recuperada exitosamente');
      } else {
        print('⚠️ No se pudo recuperar sesión OAuth');
      }
    }
    
    print('✅ Inicialización OAuth completada');
  } catch (error) {
    print('❌ Error inicializando OAuth: $error');
    // No relanzar el error, solo registrarlo
  }
});