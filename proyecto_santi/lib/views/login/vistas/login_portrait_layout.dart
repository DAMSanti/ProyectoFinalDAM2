import 'package:flutter/material.dart';
import 'package:proyecto_santi/views/login/components/login_form.dart';
import 'package:proyecto_santi/views/login/components/login_buttons.dart';

Widget loginPortraitLayout(BuildContext context, TextEditingController usernameController, TextEditingController passwordController, bool isLoading, VoidCallback login, VoidCallback showLoginDialog) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.6,
                        maxHeight: constraints.maxHeight * 0.3,
                      ),
                      child: Image.asset(
                        'assets/logorecortado.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: LoginForm(
                        usernameController: usernameController,
                        passwordController: passwordController,
                        onSubmit: login,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: LoginButtons(
                        onLoginPressed: login,
                        onMicrosoftLoginPressed: showLoginDialog,
                      ),
                    ),
                    const SizedBox(height: 32),
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
    },
  );
}