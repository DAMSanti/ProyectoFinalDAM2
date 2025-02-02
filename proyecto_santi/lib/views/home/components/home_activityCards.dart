import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';

class ActivityList extends StatelessWidget {
  final List<Actividad> activities;

  const ActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Ajusta la altura según tus necesidades
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Desplazamiento horizontal
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final actividad = activities[index];
          return ActivityCardItem(
            activityName: actividad.titulo,
            activityDate: actividad.fini,
            activityStatus: actividad.estado,
            index: actividad.id,
            navController: Navigator.of(context),
          );
        },
      ),
    );
  }
}

class ActivityCardItem extends StatelessWidget {
  final String activityName;
  final String activityDate;
  final String activityStatus;
  final int index;
  final NavigatorState navController;

  const ActivityCardItem({
    super.key,
    required this.activityName,
    required this.activityDate,
    required this.activityStatus,
    required this.index,
    required this.navController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Ajusta el ancho según tus necesidades
      margin: EdgeInsets.symmetric(horizontal: 8.0), // Espacio entre tarjetas
      child: Card(
        child: ListTile(
          title: Text(activityName),
          subtitle: Text(activityDate),
          trailing: Text(activityStatus),
          onTap: () {
            // Navegar a la vista de detalles de la actividad
            Navigator.pushNamed(
              context,
              '/activityDetail',
              arguments: {
                'activityId': index,
                'isDarkTheme': Theme.of(context).brightness == Brightness.dark,
              },
            );
          },
        ),
      ),
    );
  }
}
