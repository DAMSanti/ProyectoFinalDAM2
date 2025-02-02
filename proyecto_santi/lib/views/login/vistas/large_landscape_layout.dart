import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/views/login/components/login_form.dart';
import 'package:proyecto_santi/views/login/components/login_buttons.dart';

Widget buildLargeLandscapeLayout(BuildContext context, BoxConstraints constraints, double imageSize, double padding, TextEditingController usernameController, TextEditingController passwordController, bool isLoading, VoidCallback _login, VoidCallback showLoginDialog) {
  return Stack(
    children: [
      Center(
        child: Container(
          width: 800, // Fixed size
          height: 600, // Fixed size
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 32),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? lightTheme.primaryColor.withOpacity(0.1)
                : darkTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200, // Fixed width
                height: 200, // Fixed height
                child: Image.asset(
                  'assets/logorecortado.png',
                  width: imageSize,
                  height: imageSize,
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: 400, // Fixed width
                child: LoginForm(
                  usernameController: usernameController,
                  passwordController: passwordController,
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 400, // Fixed width
                child: LoginButtons(
                  onLoginPressed: _login,
                  onMicrosoftLoginPressed: showLoginDialog,
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
      Positioned(
        top: 10,
        left: 10,
        child: Text(
          'Width: ${constraints.maxWidth.toStringAsFixed(2)}\nHeight: ${constraints.maxHeight.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            backgroundColor: Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    ],
  );
}