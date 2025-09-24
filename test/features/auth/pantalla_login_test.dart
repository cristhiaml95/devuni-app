import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:devuni_app/features/auth/pantalla_login.dart';

void main() {
  group('PantallaLogin Widget Tests', () {
    testWidgets('debe mostrar elementos básicos de login', (WidgetTester tester) async {
      // Construir el widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const PantallaLogin(),
          ),
        ),
      );

      // Verificar que aparece el título
      expect(find.text('DevUni App'), findsOneWidget);
      
      // Verificar que aparece el subtítulo
      expect(find.text('Sistema de Inventario Multi-Espacio'), findsOneWidget);
      
      // Verificar que aparece el botón de Google
      expect(find.text('Continuar con Google'), findsOneWidget);
      
      // Verificar que aparece el icono de Google
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
    });

    testWidgets('debe navegar correctamente al tocar el botón', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const PantallaLogin(),
          ),
        ),
      );

      // Encontrar y tocar el botón de Google
      final botonGoogle = find.text('Continuar con Google');
      expect(botonGoogle, findsOneWidget);
      
      await tester.tap(botonGoogle);
      await tester.pump();

      // En un test real, aquí verificaríamos que se llama al método de autenticación
      // Por ahora solo verificamos que el botón sea tocable
    });
  });

  group('Responsive Design Tests', () {
    testWidgets('debe adaptarse a pantallas pequeñas', (WidgetTester tester) async {
      // Configurar tamaño de pantalla pequeña
      await tester.binding.setSurfaceSize(const Size(320, 568));
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const PantallaLogin(),
          ),
        ),
      );

      // Verificar que los elementos siguen siendo visibles
      expect(find.text('DevUni App'), findsOneWidget);
      expect(find.text('Continuar con Google'), findsOneWidget);
    });

    testWidgets('debe adaptarse a pantallas grandes', (WidgetTester tester) async {
      // Configurar tamaño de pantalla grande
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const PantallaLogin(),
          ),
        ),
      );

      // Verificar que los elementos siguen siendo visibles
      expect(find.text('DevUni App'), findsOneWidget);
      expect(find.text('Continuar con Google'), findsOneWidget);
    });
  });
}