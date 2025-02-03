import 'package:flutter/material.dart';

class LoginButtons extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onMicrosoftLoginPressed;
  final bool isColumn;

  const LoginButtons({
    super.key,
    required this.onLoginPressed,
    required this.onMicrosoftLoginPressed,
    this.isColumn = true,
  });

  @override
  Widget build(BuildContext context) {
    return isColumn
        ? Column(
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
    )
        : Row(
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