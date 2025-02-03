import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/views/activities/views/activityDetail_view.dart';
import 'package:proyecto_santi/tema/theme.dart';

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
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        SizedBox(
          height: 120, // Adjust the height as needed
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
    return Container(
      width: 300, // Adjust the width as needed
      margin: EdgeInsets.symmetric(horizontal: 8.0), // Space between cards
      child: Card(
        color: Theme.of(context).brightness == Brightness.light
            ? lightTheme.primaryColor.withOpacity(1)
            : darkTheme.primaryColor.withOpacity(1),
        child: InkWell(
          onTap: () {
            // Navigate to the activity detail view
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actividad.titulo ?? 'Sin título',
                        style: Theme.of(context).textTheme.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        actividad.fini ?? 'Sin fecha de inicio',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    actividad.estado ?? 'Sin estado',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}