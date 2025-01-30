import 'package:flutter/material.dart';
import 'package:proyecto_santi/services/api_service.dart';

class LoginView extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LoginView({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isLoading = false;
  bool showDialog = false;
  final ApiService _apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  void _login() async {
    setState(() {
      isLoading = true;
    });

    // Implementa la lógica de autenticación aquí
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
      // Autenticación fallida
      setState(() {
        showDialog = true;
      });
    }
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
          SingleChildScrollView(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 32),
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
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('Login'),
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
                  SizedBox(height: 32),
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
