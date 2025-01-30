import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onToggleTheme;
  final String title;
  final bool showLogoutButton;

  const CustomAppBar({
    Key? key,
    required this.onToggleTheme,
    required this.title,
    this.showLogoutButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(56.0),
      child: Stack(
        children: [
          AppBar(
            leading: IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: onToggleTheme,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: showLogoutButton
                ? [
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                  ]
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.0);
}
