import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/supabase_providers.dart';

/// Pantalla de prueba para verificar conectividad con la base de datos
class DatabaseTestScreen extends ConsumerStatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  ConsumerState<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends ConsumerState<DatabaseTestScreen> {
  String _testResult = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Base de Datos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pruebas de Conectividad',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Probar Conexión'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetUserApps,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Probar get_user_apps()'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetMemberApps,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Probar get_member_apps()'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testCreateApp,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Probar create_app()'),
            ),
            const SizedBox(height: 24),
            Text(
              'Resultados:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult.isEmpty ? 'Sin resultados aún...' : _testResult,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Probando conexión...\n';
    });

    try {
      final client = ref.read(supabaseClientProvider);
      final user = ref.read(currentUserProvider);

      setState(() {
        _testResult += 'Cliente Supabase: ✅ Conectado\n';
        _testResult += 'Usuario actual: ${user?.email ?? 'No autenticado'}\n';
        _testResult += 'User ID: ${user?.id ?? 'N/A'}\n';
        _testResult += 'Timestamp: ${DateTime.now()}\n';
      });
    } catch (e) {
      setState(() {
        _testResult += '❌ Error de conexión: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetUserApps() async {
    setState(() {
      _isLoading = true;
      _testResult += '\n--- Probando get_user_apps() ---\n';
    });

    try {
      final client = ref.read(supabaseClientProvider);
      final response = await client.rpc('get_user_apps');

      setState(() {
        _testResult += 'get_user_apps(): ✅ Éxito\n';
        _testResult += 'Respuesta: $response\n';
        _testResult += 'Tipo: ${response.runtimeType}\n';
        if (response is List) {
          _testResult += 'Número de apps propias: ${response.length}\n';
        }
      });
    } catch (e) {
      setState(() {
        _testResult += 'get_user_apps(): ❌ Error: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetMemberApps() async {
    setState(() {
      _isLoading = true;
      _testResult += '\n--- Probando get_member_apps() ---\n';
    });

    try {
      final client = ref.read(supabaseClientProvider);
      final response = await client.rpc('get_member_apps');

      setState(() {
        _testResult += 'get_member_apps(): ✅ Éxito\n';
        _testResult += 'Respuesta: $response\n';
        _testResult += 'Tipo: ${response.runtimeType}\n';
        if (response is List) {
          _testResult += 'Número de apps compartidas: ${response.length}\n';
        }
      });
    } catch (e) {
      setState(() {
        _testResult += 'get_member_apps(): ❌ Error: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreateApp() async {
    setState(() {
      _isLoading = true;
      _testResult += '\n--- Probando create_app() ---\n';
    });

    try {
      final client = ref.read(supabaseClientProvider);
      final testAppName = 'Test App ${DateTime.now().millisecondsSinceEpoch}';

      final response = await client.rpc('create_app', params: {
        'app_name': testAppName,
        'app_description': 'App de prueba creada automáticamente'
      });

      setState(() {
        _testResult += 'create_app(): ✅ Éxito\n';
        _testResult += 'App creada: $testAppName\n';
        _testResult += 'Respuesta: $response\n';
      });
    } catch (e) {
      setState(() {
        _testResult += 'create_app(): ❌ Error: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
