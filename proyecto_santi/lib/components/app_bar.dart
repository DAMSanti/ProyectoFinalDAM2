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
    return OrientationBuilder(
      builder: (context, orientation) {
        return AppBar(
          centerTitle: true,
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: showMenuButton
              ? Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          )
              : null,
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: onToggleTheme,
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