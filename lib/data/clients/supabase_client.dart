import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/error_app.dart';
import '../../core/types/resultado.dart';

class SupabaseClientService {
  static SupabaseClientService get instance => SupabaseClientService._();
  SupabaseClientService._();

  SupabaseClient get client => Supabase.instance.client;
  GoTrueClient get auth => client.auth;
  PostgrestClient get rest => client.rest;

  // Método helper para manejo de errores
  Resultado<T> manejarError<T>(dynamic error) {
    if (error is PostgrestException) {
      return ResultadoError(ErrorApp.servidor(error.message));
    }

    if (error is AuthException) {
      return ResultadoError(ErrorApp.autenticacion(error.message));
    }

    if (error is Exception) {
      return ResultadoError(ErrorApp.red(error.toString(), error));
    }

    return ResultadoError(ErrorApp.desconocido(error.toString(), error));
  }

  // Método helper para ejecutar queries con manejo de errores
  Future<Resultado<T>> ejecutarQuery<T>(
    Future<T> Function() query,
  ) async {
    try {
      final resultado = await query();
      return ResultadoExitoso(resultado);
    } catch (error) {
      return manejarError<T>(error);
    }
  }

  // Método helper para ejecutar RPCs
  Future<Resultado<T>> ejecutarRpc<T>(
    String nombreFuncion,
    Map<String, dynamic>? parametros,
    T Function(dynamic) parser,
  ) async {
    try {
      final resultado = await client.rpc(nombreFuncion, params: parametros);
      return ResultadoExitoso(parser(resultado));
    } catch (error) {
      return manejarError<T>(error);
    }
  }

  // Verificar si el usuario está autenticado
  bool get estaAutenticado => auth.currentUser != null;

  // Obtener ID del usuario actual
  String? get usuarioActualId => auth.currentUser?.id;

  // Obtener email del usuario actual
  String? get usuarioActualEmail => auth.currentUser?.email;
}