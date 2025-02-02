import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/theme.dart';

class GradientBackgroundLight extends StatelessWidget {
  final Widget child;

  const GradientBackgroundLight({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorAccentLight, colorFondoLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

  class GradientBackgroundDark extends StatelessWidget {
    final Widget child;

    const GradientBackgroundDark({required this.child});

    @override
    Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorAccentDark, colorFondoDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child,
      );
    }
  }