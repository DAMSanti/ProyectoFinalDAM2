import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/views/login/components/login_form.dart';
import 'package:proyecto_santi/views/login/components/login_buttons.dart';

Widget buildLargeLandscapeLayout(BuildContext context, BoxConstraints constraints, TextEditingController usernameController, TextEditingController passwordController, bool isLoading, VoidCallback _login, VoidCallback showLoginDialog) {
  return Stack(
    children: [
      Center(
        child: Container(
          width: constraints.maxWidth * 0.35, // Fixed size
          height: constraints.maxHeight * 0.6, // Fixed size
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? lightTheme.primaryColor.withValues(alpha: 0.1)
                : darkTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: constraints.maxHeight * 0.20, // Fixed width
                height: constraints.maxHeight * 0.20, // Fixed height
                child: Image.asset(
                  'assets/logorecortado.png',
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.02),
              SizedBox(
                width: constraints.maxWidth * 0.25, // Fixed width
                child: LoginForm(
                  usernameController: usernameController,
                  passwordController: passwordController,
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.02),
              SizedBox(
                width: constraints.maxWidth * 0.25, // Fixed width
                child: LoginButtons(
                  onLoginPressed: _login,
                  onMicrosoftLoginPressed: showLoginDialog,
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.05),
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
      Positioned(
        top: 10,
        left: 10,
        child: Text(
          'Width: ${constraints.maxWidth.toStringAsFixed(2)}\nHeight: ${constraints.maxHeight.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            backgroundColor: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    ],
  );
}