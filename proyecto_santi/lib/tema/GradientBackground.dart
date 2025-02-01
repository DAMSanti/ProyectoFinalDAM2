import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorFondoLight, colorAccentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}