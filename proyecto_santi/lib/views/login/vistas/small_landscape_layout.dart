import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/login/components/login_form.dart';
import 'package:proyecto_santi/views/login/components/login_buttons.dart';

Widget buildSmallLandscapeLayout(BuildContext context, BoxConstraints constraints, double imageSize, double padding, TextEditingController usernameController, TextEditingController passwordController, bool isLoading, VoidCallback _login, VoidCallback showLoginDialog) {
  return Stack(
    children: [
      Row(
        children: [
          Container(
            width: constraints.maxWidth * 0.5,
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
                  usernameController: usernameController,
                  passwordController: passwordController,
                ),
                SizedBox(height: 12),
                LoginButtons(
                  onLoginPressed: _login,
                  onMicrosoftLoginPressed: showLoginDialog,
                ),
              ],
            ),
          ),
        ],
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