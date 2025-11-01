import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:proyecto_santi/models/actividad.dart';
import '../widgets/cards/info_card.dart';
import '../widgets/cards/folleto_card.dart';
import '../widgets/cards/estado_card.dart';
import '../widgets/cards/departamento_card.dart';
import 'package:proyecto_santi/tema/tema.dart';

class ActivityDetailHeader extends StatelessWidget {
  final Actividad actividad;
  final bool isAdminOrSolicitante;
  final bool folletoMarkedForDeletion;
  final String? newFolletoFileName; // Nombre del nuevo folleto seleccionado (antes de guardar)
  final VoidCallback onEditPressed;
  final Function(Map<String, dynamic>) onFolletoChanged;

  const ActivityDetailHeader({
    super.key,
    required this.actividad,
    required this.isAdminOrSolicitante,
    required this.folletoMarkedForDeletion,
    this.newFolletoFileName,
    required this.onEditPressed,
    required this.onFolletoChanged,
  });

  static String _extractFileName(String url) {
    final parts = url.split('/');
    if (parts.isEmpty) return 'folleto.pdf';
    
    final fileName = parts.last;
    
    // Si el nombre tiene formato "timestamp_nombreOriginal.pdf", extraer solo el nombre original
    final timestampPattern = RegExp(r'^\d+_(.+)$');
    final match = timestampPattern.firstMatch(fileName);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Determinar el nombre del folleto a mostrar
    String? displayFolletoName;
    String? displayFolletoUrl;
    
    if (!folletoMarkedForDeletion) {
      if (newFolletoFileName != null) {
        // Hay un nuevo folleto seleccionado
        displayFolletoName = newFolletoFileName;
        displayFolletoUrl = null;
      } else if (actividad.urlFolleto != null && actividad.urlFolleto!.isNotEmpty) {
        // Usar el folleto de la actividad
        displayFolletoName = _extractFileName(actividad.urlFolleto!);
        displayFolletoUrl = actividad.urlFolleto;
      }
    }

    // Parsear fechas y horas
    final DateTime fechaInicio = DateTime.parse(actividad.fini);
    final DateTime fechaFin = DateTime.parse(actividad.ffin);
    
    // Extraer solo la parte de fecha (sin hora) para comparar
    final fechaInicioSolo = DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day);
    final fechaFinSolo = DateTime(fechaFin.year, fechaFin.month, fechaFin.day);
    
    // Formatear fechas
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final String formattedStartDate = dateFormat.format(fechaInicio);
    final String formattedEndDate = dateFormat.format(fechaFin);
    
    // Formatear horas (hini y hfin vienen como "HH:mm" o "HH:mm:ss")
    String horaInicio = actividad.hini;
    String horaFin = actividad.hfin;
    
    // Si las horas tienen formato HH:mm:ss, quitar los segundos
    if (horaInicio.length > 5 && horaInicio.substring(5, 6) == ':') {
      horaInicio = horaInicio.substring(0, 5);
    }
    if (horaFin.length > 5 && horaFin.substring(5, 6) == ':') {
      horaFin = horaFin.substring(0, 5);
    }
    
    // Construir texto seg�n si es el mismo d�a o d�as diferentes
    final String dateText = fechaInicioSolo == fechaFinSolo
        ? '$formattedStartDate $horaInicio'
        : '$formattedStartDate $horaInicio - $formattedEndDate $horaFin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Contenedor principal del header
            Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color.fromRGBO(25, 118, 210, 0.25),
                      Color.fromRGBO(21, 101, 192, 0.20),
                    ]
                  : const [
                      Color.fromRGBO(187, 222, 251, 0.85),
                      Color.fromRGBO(144, 202, 249, 0.75),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? const Color.fromRGBO(0, 0, 0, 0.4) 
                    : const Color.fromRGBO(0, 0, 0, 0.15),
                offset: const Offset(0, 4),
                blurRadius: 12.0,
                spreadRadius: -1,
              ),
            ],
            border: Border.all(
              color: isDark 
                  ? const Color.fromRGBO(255, 255, 255, 0.1) 
                  : const Color.fromRGBO(0, 0, 0, 0.05),
              width: 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Gradiente superior decorativo
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: isMobile ? 3 : 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isMobile ? 16 : 20),
                      topRight: Radius.circular(isMobile ? 16 : 20),
                    ),
                    gradient: LinearGradient(
                      colors: actividad.tipo == 'Complementaria'
                        ? [
                            AppColors.primary,
                            Color(0xFF42A5F5),
                            Color(0xFF64B5F6),
                          ]
                        : [
                            Color(0xFFE65100),
                            Color(0xFFFF6F00),
                            Color(0xFFFF9800),
                          ],
                    ),
                  ),
                ),
              ),
              // Patr�n decorativo de fondo
              if (!isMobile)
                Positioned(
                  right: -30,
                  top: -30,
                  child: Opacity(
                    opacity: isDark ? 0.03 : 0.02,
                    child: Icon(
                      Icons.event_note_rounded,
                      size: 150,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              // Contenido
              Padding(
                padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // T�tulo con bot�n de editar
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isMobile ? 6 : 8),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(25, 118, 210, 0.15),
                            borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                          ),
                          child: Icon(
                            Icons.event_note_rounded,
                            color: AppColors.primary,
                            size: isMobile ? 18 : (isWeb ? 20 : 22.0),
                          ),
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        Expanded(
                          child: Text(
                            actividad.titulo,
                            style: TextStyle(
                              fontSize: isMobile ? 16 : (isWeb ? 20 : 22.0),
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.primary,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            maxLines: isMobile ? 2 : null,
                            overflow: isMobile ? TextOverflow.ellipsis : null,
                          ),
                        ),
                        if (isAdminOrSolicitante)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryOpacity10,
                              borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.edit_rounded, 
                                color: AppColors.primary,
                                size: isMobile ? 18 : 24,
                              ),
                              onPressed: onEditPressed,
                              tooltip: 'Editar actividad',
                              padding: EdgeInsets.all(isMobile ? 6 : 8),
                              constraints: isMobile ? BoxConstraints() : null,
                            ),
                          ),
                      ],
                    ),
                    
                    SizedBox(height: isMobile ? 10 : 16),
                    
                    // Descripci�n directamente debajo del t�tulo
                    if (actividad.descripcion != null && actividad.descripcion!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          left: isMobile ? 4 : 8.0, 
                          right: isMobile ? 4 : 8.0, 
                          bottom: isMobile ? 6 : 8.0,
                        ),
                        child: Text(
                          actividad.descripcion!,
                          style: TextStyle(
                            fontSize: isMobile ? 13 : (isWeb ? 14 : 16.0),
                            color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black87,
                            height: 1.5,
                          ),
                          maxLines: isMobile ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    
                    // Divider decorativo
                    Container(
                      height: 1,
                      margin: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            isDark 
                                ? const Color.fromRGBO(255, 255, 255, 0.2) 
                                : const Color.fromRGBO(0, 0, 0, 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: isMobile ? 8 : 12),
                    
                    // Layout condicional: m�vil = vertical, desktop = horizontal
                    if (isMobile) ...[
                      // M�VIL: Layout vertical compacto
                      // Fila 1: Fecha y Estado
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: InfoCardWidget(
                              icon: Icons.access_time_rounded,
                              label: 'Fecha',
                              value: dateText,
                              isMobile: true,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: EstadoCardWidget(
                              estado: actividad.estado,
                              isMobile: true,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Fila 2: Departamento
                      DepartamentoCardWidget(
                        responsable: actividad.responsable,
                        isMobile: true,
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Fila 3: Responsable
                      _ResponsableCard(
                        responsable: actividad.responsable,
                        isDark: isDark,
                        isWeb: isWeb,
                        isMobile: true,
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Fila 4: Folleto
                      FolletoCardWidget(
                        folletoFileName: displayFolletoName,
                        folletoMarkedForDeletion: folletoMarkedForDeletion,
                        actividadFolletoUrl: displayFolletoUrl,
                        isAdminOrSolicitante: isAdminOrSolicitante,
                        onFolletoChanged: onFolletoChanged,
                        isMobile: true,
                      ),
                    ] else ...[
                      // DESKTOP: Layout original horizontal
                      // Primera fila: Fecha/Hora (izq), Departamento (centro), Estado (der)
                      Row(
                        children: [
                          // Fecha y hora
                          Expanded(
                            flex: 4,
                            child: InfoCardWidget(
                              icon: Icons.access_time_rounded,
                              label: 'Fecha y Hora',
                              value: dateText,
                            ),
                          ),
                          
                          SizedBox(width: 12),
                          
                          // Departamento
                          Expanded(
                            flex: 3,
                            child: DepartamentoCardWidget(
                              responsable: actividad.responsable,
                            ),
                          ),
                          
                          SizedBox(width: 12),
                          
                          // Estado
                          Expanded(
                            flex: 3,
                            child: EstadoCardWidget(estado: actividad.estado),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Segunda fila: Responsable (izq) y Folleto (der)
                      Row(
                        children: [
                          // Responsable con foto
                          Expanded(
                            flex: 6,
                            child: _ResponsableCard(
                              responsable: actividad.responsable,
                              isDark: isDark,
                              isWeb: isWeb,
                            ),
                          ),
                          
                          SizedBox(width: 12),
                          
                          // Folleto
                          Expanded(
                            flex: 4,
                            child: FolletoCardWidget(
                              folletoFileName: displayFolletoName,
                              folletoMarkedForDeletion: folletoMarkedForDeletion,
                              actividadFolletoUrl: displayFolletoUrl,
                              isAdminOrSolicitante: isAdminOrSolicitante,
                              onFolletoChanged: onFolletoChanged,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Etiqueta de tipo de actividad (leng�eta de carpeta) - Por encima de todo
        Positioned(
          top: 0,
          left: isMobile ? 20 : 40,
          child: Transform.translate(
            offset: Offset(0, isMobile ? -22 : -28),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16, 
                vertical: isMobile ? 6 : 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: actividad.tipo == 'Complementaria'
                    ? [
                        AppColors.primary,
                        Color(0xFF42A5F5),
                      ]
                    : [
                        Color(0xFFE65100),
                        Color(0xFFFF6F00),
                      ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobile ? 10 : 12),
                  topRight: Radius.circular(isMobile ? 10 : 12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (actividad.tipo == 'Complementaria' 
                        ? AppColors.primary 
                        : Color(0xFFE65100)).withValues(alpha: 0.4),
                    offset: Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                actividad.tipo == 'Complementaria' ? 'COMPLEMENTARIA' : 'EXTRAESCOLAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 10 : (isWeb ? 11 : 13.0),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
      ],
    );
  }
}

// Widget personalizado para la tarjeta del Responsable con foto
class _ResponsableCard extends StatelessWidget {
  final dynamic responsable;
  final bool isDark;
  final bool isWeb;
  final bool isMobile;

  const _ResponsableCard({
    required this.responsable,
    required this.isDark,
    required this.isWeb,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = responsable != null 
        ? '${responsable!.nombre} ${responsable!.apellidos}'
        : 'Sin responsable';
    
    final iniciales = responsable != null 
        ? '${responsable!.nombre[0]}${responsable!.apellidos[0]}'.toUpperCase()
        : 'SR';

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
          // Foto de perfil circular
          Container(
            width: isMobile ? 36 : 40,
            height: isMobile ? 36 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  Color(0xFF42A5F5),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOpacity30,
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: Text(
                iniciales,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 14 : (isWeb ? 14 : 16.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          SizedBox(width: isMobile ? 10 : 12),
          
          // Informaci�n del responsable
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Responsable',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : (isWeb ? 11 : 13.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  nombre,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : (isWeb ? 13 : 15.0),
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
