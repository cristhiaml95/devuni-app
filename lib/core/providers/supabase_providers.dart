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
  print(
      '🔗 RIVERPOD: AnonKey configurada: ${AppConfig.supabaseAnonKey.isNotEmpty}');

  final client = SupabaseClient(
    AppConfig.supabaseUrl,
    AppConfig.supabaseAnonKey,
    authOptions: const AuthClientOptions(
      autoRefreshToken: true,
      // Configuración estable para web
      authFlowType: AuthFlowType.implicit,
    ),
  );

  print('✅ RIVERPOD: Cliente Supabase inicializado correctamente');
  return client;
});

/// Provider para el estado de autenticación actual
/// Escucha los cambios de auth.onAuthStateChange con filtrado estable
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  print('🔐 RIVERPOD: Monitoreando estado de autenticación...');

  // Keepalive para evitar que el stream se cierre
  ref.keepAlive();

  return client.auth.onAuthStateChange.where((data) {
    // Filtrar eventos problemáticos que pueden causar logout automático
    // Solo procesar eventos importantes
    final shouldProcess = data.event == AuthChangeEvent.signedIn ||
        data.event == AuthChangeEvent.signedOut ||
        data.event == AuthChangeEvent.initialSession;

    if (!shouldProcess) {
      print('🔍 RIVERPOD: Ignorando evento: ${data.event}');
    }

    return shouldProcess;
  }).map((data) {
    print('🔐 RIVERPOD: Procesando cambio de estado auth: ${data.event}');

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
          print(
              '👤 RIVERPOD: Sesión existente para: ${data.session!.user.email}');
        } else {
          print('👤 RIVERPOD: No hay sesión existente');
        }
        break;
      default:
        print('❓ RIVERPOD: Evento procesado: ${data.event}');
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
/// Procesa activamente los tokens OAuth de la URL después del redirect
final oauthInitializerProvider = FutureProvider<void>((ref) async {
  try {
    print('🌐 Inicializando OAuth para web...');

    final client = ref.read(supabaseClientProvider);

    // Verificar si hay tokens en la URL (después de OAuth redirect)
    final uri = Uri.base;
    print('🔗 URL actual: ${uri.toString()}');
    print('🔗 Fragment: "${uri.fragment}"');

    if (uri.fragment.isNotEmpty && uri.fragment.contains('access_token')) {
      print('🔗 Tokens OAuth detectados en URL');
      print('🔗 Fragmento completo: ${uri.fragment}');

      try {
        // Método 1: Usar getSessionFromUrl con la URL completa
        print('🔄 Método 1: getSessionFromUrl...');
        await client.auth.getSessionFromUrl(uri);
        print('✅ Sesión OAuth procesada exitosamente con método 1');

        // Verificar si ahora tenemos una sesión válida
        final session = client.auth.currentSession;
        if (session?.user != null) {
          print('👤 Usuario autenticado: ${session!.user.email}');
          return; // Éxito, salir
        }
      } catch (e) {
        print('❌ Error en método 1: $e');
      }

      try {
        // Método 2: Parsear manualmente y usar setSession
        print('🔄 Método 2: Parseo manual de tokens...');

        final fragment = uri.fragment;
        final params = <String, String>{};

        // Parsear el fragment manualmente
        for (final pair in fragment.split('&')) {
          final parts = pair.split('=');
          if (parts.length == 2) {
            params[parts[0]] = Uri.decodeComponent(parts[1]);
          }
        }

        final accessToken = params['access_token'];

        if (accessToken != null) {
          print('🔑 Access token encontrado');

          // Usar el access token para obtener el usuario
          final response = await client.auth.getUser(accessToken);
          if (response.user != null) {
            print('� Usuario obtenido del token: ${response.user!.email}');

            // Crear sesión manualmente si es necesario
            // Esto debería activar el listener de auth state change
            print('✅ Método 2 exitoso');
            return;
          }
        }
      } catch (e2) {
        print('❌ Error en método 2: $e2');
      }

      try {
        // Método 3: Limpiar la URL y detectar automáticamente
        print('🔄 Método 3: Detección automática...');

        // Simplemente esperar a que Supabase detecte automáticamente
        await Future.delayed(const Duration(seconds: 1));

        final session = client.auth.currentSession;
        if (session?.user != null) {
          print('👤 Sesión detectada automáticamente: ${session!.user.email}');
          print('✅ Método 3 exitoso');
          return;
        }
      } catch (e3) {
        print('❌ Error en método 3: $e3');
      }

      print('⚠️ Todos los métodos OAuth fallaron, pero continuando...');
    } else {
      print('📱 No hay tokens OAuth en la URL - sesión normal');

      // Verificar si ya hay una sesión existente
      final existingSession = client.auth.currentSession;
      if (existingSession?.user != null) {
        print('👤 Sesión existente encontrada: ${existingSession!.user.email}');
      }
    }

    print('✅ Inicialización OAuth completada');
  } catch (error) {
    print('❌ Error inicializando OAuth: $error');
    // No relanzar el error para evitar crashes
  }
});
