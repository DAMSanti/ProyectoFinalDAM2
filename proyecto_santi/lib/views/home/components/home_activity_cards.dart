import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/activityDetail/activity_detail_view.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ActivityCardItem extends StatefulWidget {
  final Actividad actividad;
  final bool isDarkTheme;

  const ActivityCardItem({
    super.key,
    required this.actividad,
    required this.isDarkTheme,
  });

  @override
  _ActivityCardItemState createState() => _ActivityCardItemState();
}

class _ActivityCardItemState extends State<ActivityCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            transform: _isHovered 
                ? (Matrix4.identity()
                  ..translate(0.0, -8.0, 0.0)
                  ..scale(1.02))
                : Matrix4.identity(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Color(0xFF1976d2).withOpacity(0.25),
                          Color(0xFF1565C0).withOpacity(0.20),
                        ]
                      : [
                          Color(0xFFBBDEFB).withOpacity(0.85),
                          Color(0xFF90CAF9).withOpacity(0.75),
                        ],
                ),
                boxShadow: [
                  // Sombra principal
                  BoxShadow(
                    color: _isHovered 
                        ? Color(0xFF1976d2).withOpacity(0.35)
                        : (isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.15)),
                    offset: _isHovered ? Offset(0, 12) : Offset(0, 4),
                    blurRadius: _isHovered ? 24.0 : 12.0,
                    spreadRadius: _isHovered ? 0 : -1,
                  ),
                  // Sombra secundaria para más profundidad
                  if (_isHovered)
                    BoxShadow(
                      color: Color(0xFF1976d2).withOpacity(0.2),
                      offset: Offset(0, 6),
                      blurRadius: 16.0,
                    ),
                ],
                border: Border.all(
                  color: _isHovered
                      ? Color(0xFF1976d2).withOpacity(0.6)
                      : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                  width: _isHovered ? 2 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Stack(
                    children: [
                    // Gradiente superior decorativo
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1976d2),
                              Color(0xFF42A5F5),
                              Color(0xFF64B5F6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Efecto de brillo en hover
                    if (_isHovered)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topRight,
                              radius: 1.5,
                              colors: [
                                Color(0xFF1976d2).withOpacity(0.08),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Patrón de puntos decorativos
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Opacity(
                        opacity: isDark ? 0.03 : 0.02,
                        child: Icon(
                          Icons.calendar_month_rounded,
                          size: 120,
                          color: Color(0xFF1976d2),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        navigateToActivityDetailInShell(
                          context,
                          {'activity': widget.actividad},
                        );
                      },
                      borderRadius: BorderRadius.circular(20.0),
                      child: ActivityInfo(
                        actividad: widget.actividad,
                        isHovered: _isHovered,
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ActivityInfo extends StatelessWidget {
  final Actividad actividad;
  final bool isHovered;

  const ActivityInfo({
    super.key,
    required this.actividad,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Formatear la fecha y hora desde campos separados
    String formatearFechaHora() {
      try {
        // Parsear la fecha (fini está en formato YYYY-MM-DDT00:00:00)
        final fecha = DateTime.parse(actividad.fini);
        
        // Combinar fecha con hora (hini está en formato HH:mm)
        final partsHora = actividad.hini.split(':');
        final hora = int.tryParse(partsHora[0]) ?? 0;
        final minuto = int.tryParse(partsHora.length > 1 ? partsHora[1] : '0') ?? 0;
        
        final fechaHoraCompleta = DateTime(
          fecha.year,
          fecha.month,
          fecha.day,
          hora,
          minuto,
        );
        
        return DateFormat('dd-MM-yyyy HH:mm').format(fechaHoraCompleta);
      } catch (e) {
        // Fallback: mostrar fecha y hora como vienen
        try {
          final fecha = DateTime.parse(actividad.fini);
          return '${DateFormat('dd-MM-yyyy').format(fecha)} ${actividad.hini}';
        } catch (e2) {
          return '${actividad.fini} ${actividad.hini}';
        }
      }
    }

    // Color según estado
    Color getEstadoColor() {
      switch (actividad.estado.toLowerCase()) {
        case 'aprobada':
          return Color(0xFF4CAF50);
        case 'pendiente':
          return Color(0xFFFFA726);
        case 'rechazada':
          return Color(0xFFEF5350);
        default:
          return Colors.grey;
      }
    }

    // Icono según estado
    IconData getEstadoIcon() {
      switch (actividad.estado.toLowerCase()) {
        case 'aprobada':
          return Icons.check_circle_rounded;
        case 'pendiente':
          return Icons.schedule_rounded;
        case 'rechazada':
          return Icons.cancel_rounded;
        default:
          return Icons.info_rounded;
      }
    }

    return Container(
      decoration: BoxDecoration(
        // Efecto glassmorphism sutil en hover
        gradient: isHovered
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Color(0xFF1976d2).withOpacity(0.05),
                        Colors.transparent,
                      ]
                    : [
                        Color(0xFF1976d2).withOpacity(0.02),
                        Colors.transparent,
                      ],
              )
            : null,
      ),
      padding: EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0), // Padding reducido vertical
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Ocupar solo el espacio necesario
        children: [
          // Título con icono
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color(0xFF1976d2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: Color(0xFF1976d2),
                  size: 18,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  actividad.titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Color(0xFF1A237E),
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 10),
          
          // Descripción
          Text(
            actividad.descripcion?.isNotEmpty == true 
                ? actividad.descripcion! 
                : 'Sin descripción',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          
          SizedBox(height: 10),
          
          // Divider sutil
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Fecha y estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fecha con icono
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 15,
                    color: isDark ? Colors.white60 : Colors.black45,
                  ),
                  SizedBox(width: 5),
                  Text(
                    formatearFechaHora(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Badge de estado
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: getEstadoColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: getEstadoColor().withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getEstadoIcon(),
                      size: 14,
                      color: getEstadoColor(),
                    ),
                    SizedBox(width: 4),
                    Text(
                      actividad.estado,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: getEstadoColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}