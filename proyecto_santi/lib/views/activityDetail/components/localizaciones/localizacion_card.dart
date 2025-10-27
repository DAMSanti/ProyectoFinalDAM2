import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/localizacion.dart';

/// Widget para mostrar una tarjeta de localización
class LocalizacionCard extends StatelessWidget {
  final Localizacion localizacion;
  final bool isAdminOrSolicitante;
  final VoidCallback? onDelete;

  const LocalizacionCard({
    Key? key,
    required this.localizacion,
    required this.isAdminOrSolicitante,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: localizacion.esPrincipal 
            ? Color(0xFF1976d2).withOpacity(0.1)
            : (Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!.withOpacity(0.5)
                : Colors.white.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: localizacion.esPrincipal
              ? Color(0xFF1976d2).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: localizacion.esPrincipal ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                localizacion.esPrincipal ? Icons.location_pin : Icons.location_on,
                color: localizacion.esPrincipal ? Colors.red : Color(0xFF1976d2),
                size: !isWeb ? 20.dg : 6.sp,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizacion.nombre,
                  style: TextStyle(
                    fontSize: !isWeb ? 14.dg : 4.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (localizacion.esPrincipal)
                Chip(
                  label: Text(
                    'Principal',
                    style: TextStyle(
                      fontSize: !isWeb ? 10.dg : 3.sp,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              if (isAdminOrSolicitante && onDelete != null) ...[
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: !isWeb ? 18.dg : 5.sp),
                  onPressed: onDelete,
                  tooltip: 'Eliminar',
                  color: Colors.red[300],
                ),
              ],
            ],
          ),
          if (localizacion.direccionCompleta.isNotEmpty) ...[
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.place, color: Colors.grey[600], size: !isWeb ? 14.dg : 4.sp),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizacion.direccionCompleta,
                    style: TextStyle(
                      fontSize: !isWeb ? 12.dg : 4.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (localizacion.latitud != null && localizacion.longitud != null) ...[
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.my_location, color: Colors.grey[600], size: !isWeb ? 12.dg : 4.sp),
                SizedBox(width: 4),
                Text(
                  'Lat: ${localizacion.latitud!.toStringAsFixed(4)}, Lng: ${localizacion.longitud!.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: !isWeb ? 10.dg : 3.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
