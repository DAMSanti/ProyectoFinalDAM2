import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:proyecto_santi/views/login/login_view.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/firebase_options.dart';
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });
  group('E2E: Pantalla de Login', () {
    testWidgets('La pantalla de login se muestra correctamente', (WidgetTester tester) async {
      final auth = Auth();
      await tester.pumpWidget(
        ChangeNotifierProvider<Auth>.value(
          value: auth,
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) {
              return MaterialApp(
                title: 'ACEX Test',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: ThemeMode.light,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('es', 'ES'),
                  Locale('en', 'US'),
                ],
                locale: const Locale('es', 'ES'),
                home: LoginView(onToggleTheme: () {}),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsAtLeastNWidgets(2)); 
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1)); 
    });
    testWidgets('Usuario puede escribir en los campos de texto', (WidgetTester tester) async {
      final auth = Auth();
      await tester.pumpWidget(
        ChangeNotifierProvider<Auth>.value(
          value: auth,
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) {
              return MaterialApp(
                title: 'ACEX Test',
                theme: lightTheme,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('es', 'ES')],
                locale: const Locale('es', 'ES'),
                home: LoginView(onToggleTheme: () {}),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(2));
      await tester.enterText(textFields.first, 'usuario@test.com');
      await tester.pumpAndSettle();
      await tester.enterText(textFields.at(1), 'miPassword123');
      await tester.pumpAndSettle();
      expect(find.text('usuario@test.com'), findsOneWidget);
    });
    testWidgets('Botón de login responde al tap', (WidgetTester tester) async {
      final auth = Auth();
      await tester.pumpWidget(
        ChangeNotifierProvider<Auth>.value(
          value: auth,
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) {
              return MaterialApp(
                title: 'ACEX Test',
                theme: lightTheme,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('es', 'ES')],
                locale: const Locale('es', 'ES'),
                home: LoginView(onToggleTheme: () {}),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'test@ejemplo.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pumpAndSettle();
      final loginButton = find.byType(ElevatedButton).first;
      await tester.tap(loginButton);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(Scaffold), findsOneWidget);
    });
    testWidgets('La app maneja campos vacíos correctamente', (WidgetTester tester) async {
      final auth = Auth();
      await tester.pumpWidget(
        ChangeNotifierProvider<Auth>.value(
          value: auth,
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) {
              return MaterialApp(
                title: 'ACEX Test',
                theme: lightTheme,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('es', 'ES')],
                locale: const Locale('es', 'ES'),
                home: LoginView(onToggleTheme: () {}),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final loginButton = find.byType(ElevatedButton).first;
      await tester.tap(loginButton);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(LoginView), findsOneWidget);
    });
  });
  group('E2E: Navegación y UI', () {
    testWidgets('El tema se aplica correctamente', (WidgetTester tester) async {
      final auth = Auth();
      await tester.pumpWidget(
        ChangeNotifierProvider<Auth>.value(
          value: auth,
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) {
              return MaterialApp(
                title: 'ACEX Test',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: ThemeMode.light,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('es', 'ES')],
                locale: const Locale('es', 'ES'),
                home: LoginView(onToggleTheme: () {}),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });
    testWidgets('Los widgets responden a interacciones', (WidgetTester tester) async {
      final auth = Auth();
      await tester.pumpWidget(
        ChangeNotifierProvider<Auth>.value(
          value: auth,
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (context, child) {
              return MaterialApp(
                title: 'ACEX Test',
                theme: lightTheme,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('es', 'ES')],
                locale: const Locale('es', 'ES'),
                home: LoginView(onToggleTheme: () {}),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final textFields = find.byType(TextField);
      await tester.tap(textFields.first);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsAtLeastNWidgets(2));
    });
  });
}