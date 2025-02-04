import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/activities/views/activityDetail_view.dart';
import 'package:proyecto_santi/tema/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityList extends StatelessWidget {
  final List<Actividad> activities;

  const ActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Proximas Actividades',
              style: TextStyle(fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 16.dg : 3.5.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          height: 134, // Adjust the height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Horizontal scrolling
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final actividad = activities[index];
              return ActivityCardItem(
                actividad: actividad,
                isDarkTheme: Theme.of(context).brightness == Brightness.dark,
              );
            },
          ),
        ),
      ],
    );
  }
}

class ActivityCardItem extends StatelessWidget {
  final Actividad actividad;
  final bool isDarkTheme;

  const ActivityCardItem({
    super.key,
    required this.actividad,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: 275.0, // Ajusta el ancho según sea necesario
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Card(
            elevation: 8.0,
            color: Theme.of(context).brightness == Brightness.light
                ? lightTheme.primaryColor.withOpacity(1)
                : darkTheme.primaryColor.withOpacity(1),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityDetailView(
                      actividad: actividad,
                      isDarkTheme: isDarkTheme,
                      onToggleTheme: () {},
                    ),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actividad.titulo ?? 'Sin título',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 13.dg : 3.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 6.0),
                        Text(
                          actividad.descripcion ?? 'Sin descripción',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 3.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: MediaQuery.of(context).size.height > 800 ? 2 : 1,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          actividad.fini ?? 'Sin fecha',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 3.sp,
                          ),
                        ),
                        Text(
                          actividad.estado ?? 'Sin estado',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.shortestSide < 400 ? 10.dg : 3.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}