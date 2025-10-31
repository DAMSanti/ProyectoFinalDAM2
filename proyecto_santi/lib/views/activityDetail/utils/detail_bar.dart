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
          IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF1976d2)),
            onPressed: () {
              navigateBackFromDetail(context, '/home');
            },
          ),
          Row(
            children: [
              // Botón Revertir (solo visible cuando hay cambios)
              if (isDataChanged && onRevertChanges != null) ...[
                OutlinedButton.icon(
                  onPressed: onRevertChanges,
                  icon: Icon(Icons.undo),
                  label: Text('Revertir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF1976d2),
                    side: BorderSide(color: Color(0xFF1976d2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
              // Botón Guardar
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
        ],
      ),
    );
  }
}