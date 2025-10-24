import 'package:flutter/material.dart';

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
          if (ModalRoute.of(context)?.settings.name != '/')
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ElevatedButton(
            onPressed: isDataChanged ? onSaveChanges : null,
            style: ElevatedButton.styleFrom(
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