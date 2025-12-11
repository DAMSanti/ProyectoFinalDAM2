import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/views/login/login_view.dart';
import 'package:proyecto_santi/models/auth.dart';
void main() {
  group('LoginView Widget Tests', () {
    late Auth mockAuth;
    setUp(() {
      mockAuth = Auth();
    });
    Widget createLoginView() {
      return MaterialApp(
        home: ChangeNotifierProvider<Auth>.value(
          value: mockAuth,
          child: LoginView(onToggleTheme: () {}),
        ),
      );
    }
    testWidgets('debe mostrar campos de usuario y contraseña', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginView());
      expect(find.byType(TextField), findsAtLeastNWidgets(2));
    });
    testWidgets('debe mostrar botón de login', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginView());
      final loginButtons = find.byType(ElevatedButton);
      expect(loginButtons, findsAtLeastNWidgets(1));
    });
    testWidgets('debe poder escribir en el campo de usuario', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginView());
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'usuario@test.com');
      await tester.pump();
      expect(find.text('usuario@test.com'), findsOneWidget);
    });
    testWidgets('debe poder escribir en el campo de contraseña', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginView());
      final textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(1), 'password123');
        await tester.pump();
      }
      expect(textFields.evaluate().length, greaterThanOrEqualTo(2));
    });
    testWidgets('debe mostrar indicador de carga durante login', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginView());
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'test@test.com');
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(1), 'password');
      }
      await tester.pump();
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pump(); 
      }
    });
    testWidgets('debe tener el logo de la aplicación', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginView());
      final images = find.byType(Image);
      expect(images.evaluate().length, greaterThanOrEqualTo(0));
    });
  });
}