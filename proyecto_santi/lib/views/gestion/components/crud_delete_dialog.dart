import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Diálogo de confirmación para eliminar elementos en las vistas CRUD
class CrudDeleteDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const CrudDeleteDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontSize: kIsWeb ? 5.sp : 18.dg,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: TextStyle(fontSize: kIsWeb ? 4.sp : 14.dg),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(fontSize: kIsWeb ? 4.sp : 14.dg),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Eliminar',
            style: TextStyle(fontSize: kIsWeb ? 4.sp : 14.dg),
          ),
        ),
      ],
    );
  }

  /// Muestra el diálogo de confirmación de eliminación
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CrudDeleteDialog(
        title: title,
        content: content,
        onConfirm: onConfirm,
      ),
    );
  }
}
