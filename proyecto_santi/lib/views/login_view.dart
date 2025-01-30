import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LoginView({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isLoading = false;
  bool showDialog = false;

  void showLoginDialog() {
    // Implementa la lógica de autenticación aquí
    setState(() {
      isLoading = true;
    });

    // Simula una autenticación exitosa después de 2 segundos
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        showDialog = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.brightness_6),
          onPressed: widget.onToggleTheme,
        ),
        title: Text('Login'),
      ),
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logorecortado.png',
                    width: 300,
                    height: 300,
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: showLoginDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/microsoft.png',
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 8),
                        Text('Iniciar sesión con Microsoft'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          if (showDialog)
            AlertDialog(
              title: Text('Permiso denegado'),
              content: Text(
                  'Lo sentimos, no tienes permisos para entrar a esta aplicación.'),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      showDialog = false;
                    });
                  },
                  child: Text('Cancelar'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
