import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Configuración de Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Configuración de la App
  static String get appName => dotenv.env['APP_NAME'] ?? 'DevUni App';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get environment => dotenv.env['APP_ENVIRONMENT'] ?? 'development';
  
  // Configuración de Debug
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static bool get enableLogging => dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  
  // URLs de API
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '') ?? 30000;
  
  // Configuración de UI
  static String get defaultTheme => dotenv.env['DEFAULT_THEME'] ?? 'light';
  static String get primaryColorHex => dotenv.env['PRIMARY_COLOR'] ?? '0xFF667eea';
  
  // Métodos de utilidad
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isTest => environment == 'test';
  
  // Validaciones
  static bool get isSupabaseConfigured => 
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  
  // Inicialización
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      if (debugMode) {
        printConfig();
      }
    } catch (e) {
      print('⚠️ Error cargando .env: $e');
    }
  }
  
  // Debug info
  static void printConfig() {
    print('🔧 AppConfig Debug Info:');
    print('   📱 App: $appName v$appVersion');
    print('   🌍 Environment: $environment');  
    print('   🔑 Supabase configured: $isSupabaseConfigured');
    print('   🐛 Debug mode: $debugMode');
    print('   📝 Logging: $enableLogging');
    print('   🎨 Primary color: $primaryColorHex');
    print('   📊 API Base URL: $apiBaseUrl');
  }
}