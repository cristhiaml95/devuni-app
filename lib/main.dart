import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/config/app_config.dart';

// Imports condicionales para testing
import 'core/providers/supabase_providers.dart' as supabase_providers;

void main() async {
  print('📍 LÍNEA 3: Iniciando función main()');
  
  // Inicializar Flutter
  WidgetsFlutterBinding.ensureInitialized();
  print('📍 LÍNEA 6: WidgetsFlutterBinding inicializado');
  
  // Cargar variables de entorno
  print('📍 LÍNEA 9: Cargando variables de entorno...');
  await AppConfig.initialize();
  print('✅ LÍNEA 11: Variables de entorno cargadas');
  
  print('📍 LÍNEA 13: Llamando runApp() con ProviderScope + Material 3 + Config');
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
    
    print('📍 LÍNEA 26: Color primario configurado: ${AppConfig.primaryColorHex}');
    
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false, // Temporal: evitar bool.fromEnvironment en web
      
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
      
      home: Scaffold(
        appBar: AppBar(
          title: Text('${AppConfig.appName} v${AppConfig.appVersion}'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                '¡Variables de Entorno Funcionando!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Configuración dinámica cargada desde .env',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Configuración Cargada',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildConfigInfo(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  print('🎯 Variables de entorno funcionando - Probando Riverpod + Supabase');
                  AppConfig.printConfig();
                  
                  // Probar el cliente de Supabase con Riverpod
                  try {
                    final client = ref.read(supabase_providers.supabaseClientProvider);
                    print('✅ Cliente Supabase inicializado con Riverpod');
                    print('   🔗 URL: ${AppConfig.supabaseUrl}');
                    print('   🔑 Auth client: ${client.auth.currentUser?.email ?? "No auth"}');
                  } catch (e) {
                    print('❌ Error inicializando cliente Supabase: $e');
                  }
                },
                icon: const Icon(Icons.rocket_launch_rounded),
                label: const Text('Probar Riverpod + Supabase'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildConfigInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildConfigRow(context, 'Entorno', AppConfig.environment),
        _buildConfigRow(context, 'Debug', AppConfig.debugMode ? 'Activo' : 'Inactivo'),
        _buildConfigRow(context, 'Supabase', AppConfig.isSupabaseConfigured ? 'Configurado' : 'No configurado'),
        _buildConfigRow(context, 'Tema', AppConfig.defaultTheme),
      ],
    );
  }
  
  Widget _buildConfigRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}