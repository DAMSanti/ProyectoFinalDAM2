import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/login/components/login_form.dart';
import 'package:proyecto_santi/views/login/components/login_buttons.dart';

Widget buildPortraitLayout(BuildContext context, TextEditingController usernameController, TextEditingController passwordController, bool isLoading, VoidCallback _login, VoidCallback showLoginDialog) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double imageSize = constraints.maxWidth * 0.5;
      double padding = 16.0;

      if (constraints.maxWidth < 600) {
        imageSize = constraints.maxWidth * 0.6;
        padding = 12.0;
      } else if (constraints.maxWidth < 400) {
        imageSize = constraints.maxWidth * 0.7;
        padding = 8.0;
      }

      return Stack(
        children: [
          Container(
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
                  usernameController: usernameController,
                  passwordController: passwordController,
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
    },
  );
}