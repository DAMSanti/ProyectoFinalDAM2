import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class EstadoCardWidget extends StatelessWidget {
  final String estado;

  const EstadoCardWidget({
    super.key,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    // Determinar color según el estado
    Color estadoColor;
    IconData estadoIcon;
    
    switch (estado.toLowerCase()) {
      case 'pendiente':
        estadoColor = Colors.orange;
        estadoIcon = Icons.schedule_rounded;
        break;
      case 'aprobada':
        estadoColor = Colors.green;
        estadoIcon = Icons.check_circle_rounded;
        break;
      case 'cancelada':
        estadoColor = Colors.red;
        estadoIcon = Icons.cancel_rounded;
        break;
      case 'rechazada':
        estadoColor = Colors.red;
        estadoIcon = Icons.cancel_rounded;
        break;
      case 'completada':
        estadoColor = Colors.blue;
        estadoIcon = Icons.done_all_rounded;
        break;
      default:
        estadoColor = Colors.grey;
        estadoIcon = Icons.help_rounded;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          (estadoColor.r * 255.0).round(),
          (estadoColor.g * 255.0).round(),
          (estadoColor.b * 255.0).round(),
          0.15,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color.fromRGBO(
            (estadoColor.r * 255.0).round(),
            (estadoColor.g * 255.0).round(),
            (estadoColor.b * 255.0).round(),
            0.3,
          ),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Estado',
                  style: TextStyle(
                    fontSize: isWeb ? 11 : 13.0,
                    fontWeight: FontWeight.w600,
                    color: estadoColor,
                  ),
                ),
                Text(
                  estado,
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 16.0,
                    fontWeight: FontWeight.bold,
                    color: estadoColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Icon(
            estadoIcon,
            color: estadoColor,
            size: isWeb ? 18 : 20.0,
          ),
        ],
      ),
    );
  }
}
