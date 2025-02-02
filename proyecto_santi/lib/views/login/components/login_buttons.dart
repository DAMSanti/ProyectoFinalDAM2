import 'package:flutter/material.dart';

class LoginButtons extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onMicrosoftLoginPressed;

  const LoginButtons({
    super.key,
    required this.onLoginPressed,
    required this.onMicrosoftLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onLoginPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                child: Text('Login'),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onMicrosoftLoginPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/microsoft.png',
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(width: 8),
                    Text('Iniciar sesión con Microsoft'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LoginButtonsRow extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onMicrosoftLoginPressed;

  const LoginButtonsRow({
    super.key,
    required this.onLoginPressed,
    required this.onMicrosoftLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onLoginPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            child: Text('Login'),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: onMicrosoftLoginPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/microsoft.png',
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 8),
                Text('Microsoft'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}