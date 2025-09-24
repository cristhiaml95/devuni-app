import '../errors/error_app.dart';

sealed class Resultado<T> {
  const Resultado();
}

class ResultadoExitoso<T> extends Resultado<T> {
  final T datos;
  
  const ResultadoExitoso(this.datos);
  
  @override
  String toString() => 'ResultadoExitoso($datos)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResultadoExitoso<T> && other.datos == datos;
  }
  
  @override
  int get hashCode => datos.hashCode;
}

class ResultadoError<T> extends Resultado<T> {
  final ErrorApp error;
  
  const ResultadoError(this.error);
  
  @override
  String toString() => 'ResultadoError($error)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResultadoError<T> && other.error == error;
  }
  
  @override
  int get hashCode => error.hashCode;
}

// Extensiones para facilitar el uso
extension ResultadoExtensions<T> on Resultado<T> {
  bool get esExitoso => this is ResultadoExitoso<T>;
  bool get esError => this is ResultadoError<T>;
  
  T? get datos => switch (this) {
    ResultadoExitoso<T> exitoso => exitoso.datos,
    ResultadoError<T> _ => null,
  };
  
  ErrorApp? get error => switch (this) {
    ResultadoExitoso<T> _ => null,
    ResultadoError<T> error => error.error,
  };
  
  R fold<R>({
    required R Function(T datos) siExito,
    required R Function(ErrorApp error) siError,
  }) {
    return switch (this) {
      ResultadoExitoso<T> exitoso => siExito(exitoso.datos),
      ResultadoError<T> error => siError(error.error),
    };
  }
}