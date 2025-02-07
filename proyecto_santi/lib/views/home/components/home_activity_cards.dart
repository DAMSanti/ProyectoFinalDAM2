import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/activityDetail/activity_detail_view.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? lightTheme.primaryColor
                      : darkTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(4, 4),
                      blurRadius: 10.0,
                      spreadRadius: 1.0,
                      blurStyle: BlurStyle.inner,
                    ),
                  ],
                ),
                child: InkWell(
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
    return Padding(
      padding: EdgeInsets.all(16.0),
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
                  fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 13.dg : 3.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isHovered ? Colors.blue : Theme.of(context).brightness == Brightness.light ? lightTheme.textTheme.labelMedium?.color
                      : darkTheme.textTheme.labelMedium?.color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: 6.0),
              Text(
                actividad.descripcion ?? 'Sin descripción',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 3.sp,
                  color: isHovered ? Colors.blue : Theme.of(context).brightness == Brightness.light ? lightTheme.textTheme.labelMedium?.color
                      : darkTheme.textTheme.labelMedium?.color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: MediaQuery.of(context).size.height > 800 ? 2 : 1,
              ),
            ],
          ),
          SizedBox(height: 10.0), // Add spacing between the columns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                actividad.fini,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 3.sp,
                ),
              ),
              Text(
                actividad.estado,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 3.sp,
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