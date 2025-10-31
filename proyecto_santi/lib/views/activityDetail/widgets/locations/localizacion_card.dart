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
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: localizacion.esPrincipal 
            ? [
                Color.fromRGBO(239, 83, 80, 0.25), // Red for principal
                Color.fromRGBO(255, 205, 210, 0.85),
              ]
            : [
                Color.fromRGBO(25, 118, 210, 0.20),
                Color.fromRGBO(187, 222, 251, 0.75),
              ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: localizacion.esPrincipal
              ? Color(0xFFEF5350).withOpacity(0.4)
              : Color(0xFF1976d2).withOpacity(0.3),
          width: localizacion.esPrincipal ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: localizacion.esPrincipal 
              ? Color(0xFFEF5350).withOpacity(0.2)
              : Color(0xFF1976d2).withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: localizacion.esPrincipal
                      ? [
                          Color(0xFFEF5350).withOpacity(0.8),
                          Color(0xFFE53935).withOpacity(0.9),
                        ]
                      : [
                          Color(0xFF1976d2).withOpacity(0.8),
                          Color(0xFF1565c0).withOpacity(0.9),
                        ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: localizacion.esPrincipal 
                        ? Color(0xFFEF5350).withOpacity(0.3)
                        : Color(0xFF1976d2).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  localizacion.esPrincipal ? Icons.location_pin : Icons.location_on,
                  color: Colors.white,
                  size: !isWeb ? 24.dg : 7.sp,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizacion.nombre,
                      style: TextStyle(
                        fontSize: !isWeb ? 15.dg : 5.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976d2),
                      ),
                    ),
                    if (localizacion.esPrincipal)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFEF5350),
                              Color(0xFFE53935),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFEF5350).withOpacity(0.4),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'PRINCIPAL',
                          style: TextStyle(
                            fontSize: !isWeb ? 9.dg : 3.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isAdminOrSolicitante && onDelete != null) ...[
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, size: !isWeb ? 20.dg : 6.sp),
                    onPressed: onDelete,
                    tooltip: 'Eliminar',
                    color: Colors.red[700],
                  ),
                ),
              ],
            ],
          ),
          if (localizacion.direccionCompleta.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.place_rounded, 
                    color: Color(0xFF1976d2), 
                    size: !isWeb ? 18.dg : 5.sp
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      localizacion.direccionCompleta,
                      style: TextStyle(
                        fontSize: !isWeb ? 12.dg : 4.sp,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (localizacion.latitud != null && localizacion.longitud != null) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF1976d2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFF1976d2).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.my_location_rounded, 
                    color: Color(0xFF1976d2), 
                    size: !isWeb ? 14.dg : 4.sp
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Lat: ${localizacion.latitud!.toStringAsFixed(4)}, Lng: ${localizacion.longitud!.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: !isWeb ? 10.dg : 3.sp,
                      color: Color(0xFF1976d2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
