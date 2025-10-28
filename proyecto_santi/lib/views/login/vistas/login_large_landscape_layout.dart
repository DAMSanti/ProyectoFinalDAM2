import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/views/login/components/login_form.dart';
import 'package:proyecto_santi/views/login/components/login_buttons.dart';

Widget loginLargeLandscapeLayout(BuildContext context, BoxConstraints constraints, TextEditingController usernameController, TextEditingController passwordController, bool isLoading, VoidCallback login, VoidCallback showLoginDialog) {
  return Stack(
    children: [
      Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 450,
              minWidth: 350,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? lightTheme.primaryColor.withAlpha(25)
                  : darkTheme.primaryColor.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo con tamaño fijo
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 180,
                    maxHeight: 180,
                  ),
                  child: Image.asset(
                    'assets/logorecortado.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                // Form
                LoginForm(
                  usernameController: usernameController,
                  passwordController: passwordController,
                  onSubmit: login,
                ),
                const SizedBox(height: 24),
                // Botones
                LoginButtons(
                  onLoginPressed: login,
                  onMicrosoftLoginPressed: showLoginDialog,
                ),
              ],
            ),
          ),
        ),
      ),
      if (isLoading)
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
    ],
  );
}