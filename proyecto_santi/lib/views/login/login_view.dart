import 'package:flutter/material.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'login_form.dart';
import 'login_buttons.dart';

class LoginView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LoginView({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isLoading = false;
  final ApiService _apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
              child: Text('Cancelar'),
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

    setState(() {
      isLoading = false;
    });

    if (profesor != null) {
      // Autenticación exitosa
      print('Autenticación exitosa');
      // Navegar a la siguiente pantalla o realizar alguna acción
    } else {
      setState(() {
        showLoginDialog();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: Stack(
          children: [
            AppBar(
              leading: IconButton(
                icon: Icon(Icons.brightness_6),
                onPressed: widget.onToggleTheme,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Center(
                child: Text('Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    )),
              ),
            ),
          ],
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return _buildPortraitLayout(context);
          } else {
            return _buildLandscapeLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double imageSize = constraints.maxWidth * 0.5;
        double padding = 16.0;
        double fontSize = 30.0;

        if (constraints.maxWidth < 600) {
          imageSize = constraints.maxWidth * 0.6;
          padding = 12.0;
          fontSize = 24.0;
        } else if (constraints.maxWidth < 400) {
          imageSize = constraints.maxWidth * 0.7;
          padding = 8.0;
          fontSize = 20.0;
        }

        return Stack(
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logorecortado.png',
                    width: imageSize,
                    height: imageSize,
                  ),
                  SizedBox(height: 32),
                  LoginForm(
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                  ),
                  SizedBox(height: 16),
                  LoginButtons(
                    onLoginPressed: _login,
                    onMicrosoftLoginPressed: showLoginDialog,
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double imageSize = constraints.maxHeight * 0.5;
        double padding = 16.0;
        double fontSize = 30.0;

        if (constraints.maxHeight < 600) {
          imageSize = constraints.maxHeight;
          padding = 12.0;
          fontSize = 24.0;
        } else if (constraints.maxHeight < 400) {
          imageSize = constraints.maxHeight * 0.7;
          padding = 8.0;
          fontSize = 20.0;
        }

        return Row(
          children: [
            Container(
              width: constraints.maxWidth * 0.5,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Image.asset(
                  'assets/logorecortado.png',
                  width: imageSize,
                  height: imageSize,
                ),
              ),
            ),
            Container(
              width: constraints.maxWidth * 0.5,
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoginForm(
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                  ),
                  SizedBox(height: 12),
                  LoginButtons(
                    onLoginPressed: _login,
                    onMicrosoftLoginPressed: showLoginDialog,
                  ),
                ],
              ),
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
          ],
        );
      },
    );
  }
}
