import 'package:flutter/material.dart';

class AndroidAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onToggleTheme;
  final String title;
  final bool showMenuButton;

  const AndroidAppBar({
    super.key,
    required this.onToggleTheme,
    required this.title,
    this.showMenuButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return OrientationBuilder(
      builder: (context, orientation) {
        return AppBar(
          centerTitle: true,
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF1976d2), // Azul consistente con desktop
              letterSpacing: 0.5,
            ),
          ),
          leading: showMenuButton
              ? Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark ? Colors.white : Color(0xFF1976d2),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          )
              : null,
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? Colors.amber : Color(0xFF1976d2),
              ),
              onPressed: onToggleTheme,
              tooltip: 'Cambiar tema',
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize {
    final orientation = WidgetsBinding.instance.window.physicalSize.aspectRatio > 1
        ? Orientation.landscape
        : Orientation.portrait;
    double appBarHeight = orientation == Orientation.portrait
        ? kToolbarHeight
        : kToolbarHeight * 0.65; // Adjust height based on orientation
    return Size.fromHeight(appBarHeight);
  }
}
