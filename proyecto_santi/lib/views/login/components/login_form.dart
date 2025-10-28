import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback? onSubmit;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: usernameController,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            labelText: 'Username',
            labelStyle: const TextStyle(fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onSubmitted: (_) => onSubmit?.call(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          obscureText: true,
          onSubmitted: (_) => onSubmit?.call(),
        ),
      ],
    );
  }
}
