import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/tema.dart';
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
      padding: const EdgeInsets.all(8.0), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () {
              navigateBackFromDetail(context, '/home');
            },
          ),
          Row(
            children: [
              if (isDataChanged && onRevertChanges != null) ...[
                OutlinedButton.icon(
                  onPressed: onRevertChanges,
                  icon: Icon(Icons.undo),
                  label: Text('Revertir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
              ElevatedButton(
                onPressed: isDataChanged ? onSaveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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