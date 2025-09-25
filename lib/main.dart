import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/config/app_config.dart';
import 'app/router/app_router.dart';

void main() async {
  print('📍 LÍNEA 3: Iniciando función main()');

  // Inicializar Flutter
  WidgetsFlutterBinding.ensureInitialized();
  print('📍 LÍNEA 6: WidgetsFlutterBinding inicializado');

  // Cargar variables de entorno
  print('📍 LÍNEA 9: Cargando variables de entorno...');
  await AppConfig.initialize();
  print('✅ LÍNEA 11: Variables de entorno cargadas');

  print(
      '📍 LÍNEA 13: Llamando runApp() con ProviderScope + Material 3 + Config');
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
  print('✅ LÍNEA 15: runApp() ejecutado con ProviderScope');
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('📍 LÍNEA 19: Iniciando build() de MyApp');
    print('📍 LÍNEA 20: Configurando Material 3 + Localización + Config');

    // Obtener color dinámico desde config
    final primaryColor = AppConfig.primaryColorHex.isNotEmpty
        ? Color(int.parse(AppConfig.primaryColorHex))
        : const Color(0xFF667eea);

    print(
        '📍 LÍNEA 26: Color primario configurado: ${AppConfig.primaryColorHex}');

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner:
          false, // Temporal: evitar bool.fromEnvironment en web

      // Router configuration
      routerConfig: router,

      // 🎨 Material 3 Theme con color dinámico
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      // 🌙 Dark Theme con color dinámico
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      // 🌍 Localización en Español
      locale: const Locale('es', 'ES'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
    );
  }
}
