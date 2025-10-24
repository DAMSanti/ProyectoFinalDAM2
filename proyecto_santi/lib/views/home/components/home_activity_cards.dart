import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/activityDetail/activity_detail_view.dart';
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
            duration: Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            transform: _isHovered 
                ? (Matrix4.identity()..translate(0.0, -8.0, 0.0))
                : Matrix4.identity(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? colorAccentDark : colorAccentLight,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered 
                          ? (isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.2))
                          : Colors.black26,
                      offset: _isHovered ? Offset(0, 12) : Offset(4, 4),
                      blurRadius: _isHovered ? 24.0 : 10.0,
                      spreadRadius: _isHovered ? 2.0 : 1.0,
                    ),
                  ],
                  border: Border.all(
                    color: _isHovered
                        ? (isDark ? Colors.blue.withOpacity(0.5) : Colors.blue.withOpacity(0.3))
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Stack(
                    children: [
                      // Efecto de brillo en hover
                      if (_isHovered)
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityDetailView(
                                actividad: widget.actividad,
                                isDarkTheme: widget.isDarkTheme,
                                onToggleTheme: () {},
                              ),
                            ),
                          );
                        },
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
    // Formatear la fecha a DD-MM-YYYY HH:MM
    String formatearFecha(String fechaStr) {
      try {
        final fecha = DateTime.parse(fechaStr);
        return DateFormat('dd-MM-yyyy HH:mm').format(fecha);
      } catch (e) {
        return fechaStr; // Si no se puede parsear, devolver la cadena original
      }
    }

    // Calcular factor de escala basado en la resolución
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Factor de escala: 1.0 para 1080p, escala hacia arriba para resoluciones mayores
    double scaleFactor = 1.0;
    if (screenHeight >= 2160) { // 4K
      scaleFactor = 1.8;
    } else if (screenHeight >= 1440) { // 2K/QHD
      scaleFactor = 1.4;
    } else if (screenHeight >= 1080) { // Full HD
      scaleFactor = 1.2;
    }

    return Padding(
      padding: EdgeInsets.all(16.0 * scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                actividad.titulo,
                style: TextStyle(
                  fontSize: (MediaQuery.of(context).size.shortestSide < 400 ? 13.dg : 3.5.sp) * scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976d2), // Azul de los items del menú y "Próximas Actividades"
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: 6.0 * scaleFactor),
              Text(
                actividad.descripcion ?? 'Sin descripción',
                style: TextStyle(
                  fontSize: (MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 3.sp) * scaleFactor,
                  color: isHovered ? Colors.blue : Theme.of(context).brightness == Brightness.light ? lightTheme.textTheme.labelMedium?.color
                      : darkTheme.textTheme.labelMedium?.color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: MediaQuery.of(context).size.height > 800 ? 2 : 1,
              ),
            ],
          ),
          SizedBox(height: 10.0 * scaleFactor), // Add spacing between the columns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatearFecha(actividad.fini),
                style: TextStyle(
                  fontSize: (MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 3.sp) * scaleFactor,
                ),
              ),
              Text(
                actividad.estado,
                style: TextStyle(
                  fontSize: (MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 3.sp) * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}