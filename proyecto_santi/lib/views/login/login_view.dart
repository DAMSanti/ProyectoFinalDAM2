import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'vistas/login_portrait_layout.dart';
import 'vistas/login_small_landscape_layout.dart';
import 'vistas/login_large_landscape_layout.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:proyecto_santi/components/app_bar.dart';
import 'package:proyecto_santi/func.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class LoginView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LoginView({super.key, required this.onToggleTheme});

  @override
  LoginViewState createState() => LoginViewState();
}

// Comprueba conexión y almacena datos de forma segura
class LoginViewState extends State<LoginView> {
  bool isLoading = false;
  final ApiService _apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    setState(() {
      isLoading = true;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      // Usar directamente el Auth provider en lugar de authenticate()
      final success = await Provider.of<Auth>(context, listen: false).login(username, password);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (success) {
        // Ya no necesitamos navegar manualmente, el Consumer en main.dart
        // detectará el cambio de auth.isAuthenticated y mostrará el DesktopShell
        // Navigator.pushReplacementNamed ya no es necesario
      } else {
        showLoginDialog();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showLoginDialog();
    }
  }

  // Construye la vista
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onWillPopSalir(context),
      child: Scaffold(
        body: Stack(
          children: [
            Theme.of(context).brightness == Brightness.dark
                ? GradientBackgroundDark(
              child: Container(),
            )
                : GradientBackgroundLight(
              child: Container(),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AndroidAppBar(
                onToggleTheme: widget.onToggleTheme,
                title: 'Login',
                showMenuButton: false,
              ),
              body: _buildLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  // Diferentes vistas para dispositivos y orientaciones
  Widget _buildLayout(BuildContext context) {
    if (kIsWeb) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return loginLargeLandscapeLayout(context, constraints, _usernameController, _passwordController, isLoading, _login, showLoginDialog);
        },
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return loginLargeLandscapeLayout(context, constraints, _usernameController, _passwordController, isLoading, _login, showLoginDialog);
          },
      );
    } else {
      return OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return loginPortraitLayout(context, _usernameController, _passwordController, isLoading, _login, showLoginDialog);
          } else {
            return LayoutBuilder(
              builder: (context, constraints) {
                return loginSmallLandscapeLayout(context, constraints, _usernameController, _passwordController, isLoading, _login, showLoginDialog);
              },
            );
          }
        },
      );
    }
  }

  // Mensaje de error en el login
  void showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permiso denegado'),
          content: Text(
              'Lo sentimos, no tienes permisos para entrar a esta aplicación.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}