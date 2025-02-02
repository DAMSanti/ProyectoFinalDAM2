import 'package:flutter/material.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/components/appBar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'vistas/portrait_layout.dart';
import 'vistas/small_landscape_layout.dart';
import 'vistas/large_landscape_layout.dart';
import 'package:proyecto_santi/tema/GradientBackground.dart';

class LoginView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LoginView({super.key, required this.onToggleTheme});

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  bool isLoading = false;
  final ApiService _apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final user = FlutterSecureStorage();

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

  void _login() async {
    setState(() {
      isLoading = true;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;

    final profesor = await _apiService.authenticate(username, password);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    //if (profesor != null) {
    //  await user.write(
    //      key: 'username', value: '${profesor.nombre} ${profesor.apellidos}');
    //  await user.write(key: 'correo', value: profesor.correo);
    //  await user.write(key: 'rol', value: profesor.rol);
    await user.write(key: 'username', value: 'ACEX Database');
    await user.write(key: 'correo', value: 'ACEX2025@hotmail.com');
    await user.write(key: 'rol', value: 'ED');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
    //} else {
    //showLoginDialog();
    //}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
        child: Scaffold(
        appBar: CustomAppBar(
          onToggleTheme: widget.onToggleTheme,
          title: 'Login',
          showMenuButton: false,
        ),
        body: GradientBackground(
          child: OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                return buildPortraitLayout(context, _usernameController, _passwordController, isLoading, _login, showLoginDialog);
              } else {
                return _buildLandscapeLayout(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double imageSize = constraints.maxHeight * 0.5;
        double padding = 16.0;

        if (constraints.maxHeight < 600) {
          imageSize = constraints.maxHeight;
          padding = 12.0;
        } else if (constraints.maxHeight < 400) {
          imageSize = constraints.maxHeight * 0.7;
          padding = 8.0;
        }
        if (constraints.maxWidth > 1300) {
          return buildLargeLandscapeLayout(context, constraints, imageSize, padding, _usernameController, _passwordController, isLoading, _login, showLoginDialog);
        } else {
          return buildSmallLandscapeLayout(context, constraints, imageSize, padding, _usernameController, _passwordController, isLoading, _login, showLoginDialog);
        }
      },
    );
  }
}