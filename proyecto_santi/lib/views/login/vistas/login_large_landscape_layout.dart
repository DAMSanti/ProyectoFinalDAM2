import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/views/login/components/login_form.dart';
import 'package:proyecto_santi/views/login/components/login_buttons.dart';

Widget loginLargeLandscapeLayout(BuildContext context, BoxConstraints constraints, TextEditingController usernameController, TextEditingController passwordController, bool isLoading, VoidCallback login, VoidCallback showLoginDialog) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Stack(
        children: [
          Center(
            child: Container(
              width: constraints.maxWidth * 0.35, // Fixed size
              height: constraints.maxHeight * 0.6, // Fixed size
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? lightTheme.primaryColor.withAlpha(25)
                    : darkTheme.primaryColor.withAlpha(25),
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
                      onSubmit: login,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  SizedBox(
                    width: constraints.maxWidth * 0.25, // Fixed width
                    child: LoginButtons(
                      onLoginPressed: login,
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
        ],
      );
    },
  );
}