import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'vistas/portrait_layout.dart';
import 'vistas/small_landscape_layout.dart';
import 'vistas/large_landscape_layout.dart';
import 'package:proyecto_santi/tema/GradientBackground.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:proyecto_santi/components/appBar.dart';
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
      final profesor = await _apiService.authenticate(username, password);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      await Provider.of<Auth>(context, listen: false).login(username, password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showLoginDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
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
              appBar: CustomAppBar(
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
          return buildLargeLandscapeLayout(context, constraints, _usernameController, _passwordController, isLoading, _login, showLoginDialog);
        },
      );
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return buildLargeLandscapeLayout(context, constraints, _usernameController, _passwordController, isLoading, _login, showLoginDialog);
          },
      );
    } else {
      return OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return buildPortraitLayout(context, _usernameController, _passwordController, isLoading, _login, showLoginDialog);
          } else {
            return LayoutBuilder(
              builder: (context, constraints) {
                return buildSmallLandscapeLayout(context, constraints, _usernameController, _passwordController, isLoading, _login, showLoginDialog);
              },
            );
          }
        },
      );
    }
  }


  // Mensaje para salir de la aplicacion
  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Estás seguro?'),
        content: Text('¿Quieres salir de la aplicación?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sí'),
          ),
        ],
      ),
    )) ??
        false;
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