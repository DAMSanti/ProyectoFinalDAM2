import 'package:flutter/material.dart';
import 'app_colors.dart';

class GradientBackgroundLight extends StatelessWidget {
  final Widget child;

  const GradientBackgroundLight({required this.child});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // Portrait y Landscape: oscuro arriba, claro abajo
          colors: [AppColors.backgroundLight, AppColors.accentLight],
          // Diagonal en portrait, vertical en landscape
          begin: orientation == Orientation.portrait 
              ? Alignment.topLeft 
              : Alignment.topCenter,
          end: orientation == Orientation.portrait 
              ? Alignment.bottomRight 
              : Alignment.bottomCenter,
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
      final orientation = MediaQuery.of(context).orientation;
      
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // Portrait y Landscape: oscuro arriba, claro abajo
            colors: [AppColors.backgroundDark, AppColors.accentDark],
            // Diagonal en portrait, vertical en landscape
            begin: orientation == Orientation.portrait 
                ? Alignment.topLeft 
                : Alignment.topCenter,
            end: orientation == Orientation.portrait 
                ? Alignment.bottomRight 
                : Alignment.bottomCenter,
          ),
        ),
        child: child,
      );
    }
  }