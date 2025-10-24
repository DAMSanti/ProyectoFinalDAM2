import 'package:flutter/material.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';

class DetailBar extends StatelessWidget {
  final bool isDataChanged;
  final VoidCallback onSaveChanges;
  final VoidCallback? onRevertChanges;

  DetailBar({
    required this.isDataChanged,
    required this.onSaveChanges,
    this.onRevertChanges,
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
              color: Colors.blue,
              onPressed: () {
                // Volver a la vista anterior (funciona tanto en shell como en mobile)
                navigateBackFromDetail(context, '/home');
              },
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDataChanged && onRevertChanges != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton.icon(
                    onPressed: onRevertChanges,
                    icon: Icon(Icons.undo, size: 18),
                    label: Text('Revertir'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
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
        ],
      ),
    );
  }
}