import 'package:flutter_test/flutter_test.dart';
import 'package:devuni_app/domain/entities/app_entidad.dart';
import 'package:devuni_app/domain/entities/rol_usuario.dart';

void main() {
  group('AppEntidad Tests', () {
    test('debe crear una instancia de AppEntidad correctamente', () {
      final app = AppEntidad(
        id: 'test-id',
        nombre: 'Mi App de Prueba',
        descripcion: 'Una app para testing',
        propietarioId: 'user-123',
        activa: true,
        configuracion: {'tema': 'claro'},
        creadaEn: DateTime.now(),
        actualizadaEn: DateTime.now(),
      );

      expect(app.id, equals('test-id'));
      expect(app.nombre, equals('Mi App de Prueba'));
      expect(app.descripcion, equals('Una app para testing'));
      expect(app.propietarioId, equals('user-123'));
      expect(app.activa, isTrue);
      expect(app.configuracion?['tema'], equals('claro'));
    });

    test('copyWith debe funcionar correctamente', () {
      final app = AppEntidad(
        id: 'test-id',
        nombre: 'App Original',
        propietarioId: 'user-123',
        activa: true,
        creadaEn: DateTime.now(),
        actualizadaEn: DateTime.now(),
      );

      final appModificada = app.copyWith(
        nombre: 'App Modificada',
        activa: false,
      );

      expect(appModificada.id, equals(app.id));
      expect(appModificada.nombre, equals('App Modificada'));
      expect(appModificada.activa, isFalse);
      expect(appModificada.propietarioId, equals(app.propietarioId));
    });

    test('toJson y fromJson deben ser consistentes', () {
      final fechaCreacion = DateTime.now();
      final fechaActualizacion = DateTime.now();
      
      final app = AppEntidad(
        id: 'test-id',
        nombre: 'Mi App',
        descripcion: 'Descripción de prueba',
        propietarioId: 'user-123',
        activa: true,
        configuracion: {'clave': 'valor'},
        creadaEn: fechaCreacion,
        actualizadaEn: fechaActualizacion,
      );

      final json = app.toJson();
      final appFromJson = AppEntidad.fromJson(json);

      expect(appFromJson.id, equals(app.id));
      expect(appFromJson.nombre, equals(app.nombre));
      expect(appFromJson.descripcion, equals(app.descripcion));
      expect(appFromJson.propietarioId, equals(app.propietarioId));
      expect(appFromJson.activa, equals(app.activa));
      expect(appFromJson.configuracion, equals(app.configuracion));
    });
  });

  group('RolUsuarioApp Tests', () {
    test('niveles de rol deben estar ordenados correctamente', () {
      expect(RolUsuarioApp.visor.nivel, equals(1));
      expect(RolUsuarioApp.colaborador.nivel, equals(2));
      expect(RolUsuarioApp.administrador.nivel, equals(3));
      expect(RolUsuarioApp.propietario.nivel, equals(4));
    });

    test('puedeHacer debe funcionar correctamente', () {
      final admin = RolUsuarioApp.administrador;
      final colaborador = RolUsuarioApp.colaborador;
      final visor = RolUsuarioApp.visor;

      // Admin puede hacer tareas de colaborador y visor
      expect(admin.puedeHacer(RolUsuarioApp.colaborador), isTrue);
      expect(admin.puedeHacer(RolUsuarioApp.visor), isTrue);
      expect(admin.puedeHacer(RolUsuarioApp.administrador), isTrue);
      
      // Admin NO puede hacer tareas de propietario
      expect(admin.puedeHacer(RolUsuarioApp.propietario), isFalse);

      // Colaborador puede hacer tareas de visor
      expect(colaborador.puedeHacer(RolUsuarioApp.visor), isTrue);
      expect(colaborador.puedeHacer(RolUsuarioApp.colaborador), isTrue);
      
      // Colaborador NO puede hacer tareas de admin
      expect(colaborador.puedeHacer(RolUsuarioApp.administrador), isFalse);

      // Visor solo puede hacer tareas de visor
      expect(visor.puedeHacer(RolUsuarioApp.visor), isTrue);
      expect(visor.puedeHacer(RolUsuarioApp.colaborador), isFalse);
    });

    test('fromString debe parsear correctamente', () {
      expect(RolUsuarioApp.fromString('visor'), equals(RolUsuarioApp.visor));
      expect(RolUsuarioApp.fromString('colaborador'), equals(RolUsuarioApp.colaborador));
      expect(RolUsuarioApp.fromString('administrador'), equals(RolUsuarioApp.administrador));
      expect(RolUsuarioApp.fromString('propietario'), equals(RolUsuarioApp.propietario));
      
      // Caso por defecto
      expect(RolUsuarioApp.fromString('invalido'), equals(RolUsuarioApp.visor));
      expect(RolUsuarioApp.fromString(''), equals(RolUsuarioApp.visor));
    });

    test('nombres deben estar en español', () {
      expect(RolUsuarioApp.visor.nombre, equals('Visor'));
      expect(RolUsuarioApp.colaborador.nombre, equals('Colaborador'));
      expect(RolUsuarioApp.administrador.nombre, equals('Administrador'));
      expect(RolUsuarioApp.propietario.nombre, equals('Propietario'));
    });
  });
}