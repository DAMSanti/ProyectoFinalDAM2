import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';

class DetailBar extends StatelessWidget {
  final bool isDataChanged;
  final VoidCallback onSaveChanges;

  DetailBar({
    required this.isDataChanged,
    required this.onSaveChanges,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF1976d2)),
            onPressed: () {
              navigateBackFromDetail(context, '/home');
            },
          ),
          ElevatedButton(
            onPressed: isDataChanged ? onSaveChanges : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1976d2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }
}