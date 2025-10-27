import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// Funcion para mensaje popUp de salir
Future<bool> onWillPopSalir(BuildContext context, {bool isHome = false}) async {
  if (!isHome) {
    return true;
  }
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
          onPressed: () {
            Navigator.of(context).pop(true);
            logout(context);
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Text('Sí'),
        ),
      ],
    ),
  )) ?? false;
}

// Funcion que oculta appbar en web y escritorio
bool shouldShowAppBar() {
  return !(kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS);
}

// Funcion para hacer logout
void logout(BuildContext context) {
  Provider.of<Auth>(context, listen: false).logout();
  // Ya no necesitamos navegar manualmente, el Consumer en main.dart
  // detectará el cambio de auth.isAuthenticated y mostrará el LoginView
}