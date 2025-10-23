import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/views/login/components/login_form.dart';
import 'package:proyecto_santi/views/login/components/login_buttons.dart';

Widget loginSmallLandscapeLayout(BuildContext context, BoxConstraints constraints, TextEditingController usernameController, TextEditingController passwordController, bool isLoading, VoidCallback login, VoidCallback showLoginDialog) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Stack(
        children: [
          Row(
            children: [
              SizedBox(
                width: constraints.maxWidth * 0.5,
                child: Center(
                  child: Image.asset(
                    'assets/logorecortado.png',
                  ),
                ),
              ),
              SizedBox(
                width: constraints.maxWidth * 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Adjust margin here
                  child: _buildRightSide(context, usernameController, passwordController, login, showLoginDialog),
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
        ],
      );
    },
  );
}

Widget _buildRightSide(BuildContext context, TextEditingController usernameController, TextEditingController passwordController, VoidCallback login, VoidCallback showLoginDialog) {
  return Center(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? lightTheme.primaryColor.withAlpha(25)
            : darkTheme.primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LoginForm(
            usernameController: usernameController,
            passwordController: passwordController,
            onSubmit: login,
          ),
          SizedBox(height: 7),
          LoginButtons(
            onLoginPressed: login,
            onMicrosoftLoginPressed: showLoginDialog,
            isColumn: false,
          ),
        ],
      ),
    ),
  );
}