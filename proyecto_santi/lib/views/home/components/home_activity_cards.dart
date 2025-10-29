import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'package:proyecto_santi/shared/helpers/activity_formatters.dart';

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
    
    // Usar helpers centralizados
    final fechaHora = ActivityFormatters.formatearFechaHora(actividad);
    final estadoColor = ActivityFormatters.getEstadoColor(actividad.estado);
    final estadoIcon = ActivityFormatters.getEstadoIcon(actividad.estado);

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
                    fechaHora,
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
                  color: estadoColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: estadoColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      estadoIcon,
                      size: 14,
                      color: estadoColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      actividad.estado,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: estadoColor,
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