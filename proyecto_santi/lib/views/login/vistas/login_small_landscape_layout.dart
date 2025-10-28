import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:proyecto_santi/views/login/components/login_form.dart';
import 'package:proyecto_santi/views/login/components/login_buttons.dart';

Widget loginSmallLandscapeLayout(BuildContext context, BoxConstraints constraints, TextEditingController usernameController, TextEditingController passwordController, bool isLoading, VoidCallback login, VoidCallback showLoginDialog) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.35,
                          maxHeight: constraints.maxHeight * 0.5,
                        ),
                        child: Image.asset(
                          'assets/logorecortado.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: _buildRightSide(context, usernameController, passwordController, login, showLoginDialog),
                    ),
                  ),
                ],
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
    },
  );
}

Widget _buildRightSide(BuildContext context, TextEditingController usernameController, TextEditingController passwordController, VoidCallback login, VoidCallback showLoginDialog) {
  return Center(
    child: Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
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
          LoginForm(
            usernameController: usernameController,
            passwordController: passwordController,
            onSubmit: login,
          ),
          const SizedBox(height: 20),
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