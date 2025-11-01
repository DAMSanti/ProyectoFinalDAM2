import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/tema.dart';
import 'dart:io';
import 'package:proyecto_santi/models/profesor.dart';

class DepartamentoCardWidget extends StatelessWidget {
  final Profesor? responsable;
  final bool isMobile;

  const DepartamentoCardWidget({
    super.key,
    required this.responsable,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    // Debug: Imprimir información del responsable
    print('[DEBUG DepartamentoCard] Responsable: ${responsable?.nombre ?? 'null'}');
    print('[DEBUG DepartamentoCard] Departamento objeto: ${responsable?.depart}');
    print('[DEBUG DepartamentoCard] Departamento nombre: ${responsable?.depart?.nombre ?? 'null'}');
    
    // Obtener el nombre del departamento del responsable
    final departamentoNombre = responsable?.depart?.nombre ?? 'Sin asignar';

    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.05) 
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 5 : 6),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(25, 118, 210, 0.1),
              borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
            ),
            child: Icon(
              Icons.business_rounded,
              color: AppColors.primary,
              size: isMobile ? 14 : (isWeb ? 16 : 18.0),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Departamento',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : (isWeb ? 11 : 13.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  departamentoNombre,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : (isWeb ? 13 : 15.0),
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
