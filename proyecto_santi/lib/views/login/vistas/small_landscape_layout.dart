import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/views/login/components/login_form.dart';
import 'package:proyecto_santi/views/login/components/login_buttons.dart';
import 'package:proyecto_santi/tema/GradientBackground.dart';

Widget buildSmallLandscapeLayout(BuildContext context, BoxConstraints constraints, double imageSize, double padding, TextEditingController usernameController, TextEditingController passwordController, bool isLoading, VoidCallback _login, VoidCallback showLoginDialog) {
  return Stack(
    children: [
      Theme.of(context).brightness == Brightness.dark
          ? GradientBackgroundDark(
        child: Container(),
      )
          : GradientBackgroundLight(
        child: Container(),
      ),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Adjust margin here
              child: _buildRightSide(context, padding, usernameController, passwordController, _login, showLoginDialog),
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

Widget _buildRightSide(BuildContext context, double padding, TextEditingController usernameController, TextEditingController passwordController, VoidCallback _login, VoidCallback showLoginDialog) {
  return Center(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 32),
      decoration: BoxDecoration(
        color:  Theme.of(context).brightness == Brightness.dark
            ? lightTheme.primaryColor.withOpacity(0.1)
            : darkTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LoginForm(
            usernameController: usernameController,
            passwordController: passwordController,
          ),
          LoginButtonsRow(
            onLoginPressed: _login,
            onMicrosoftLoginPressed: showLoginDialog,
          ),
        ],
      ),
    ),
  );
}