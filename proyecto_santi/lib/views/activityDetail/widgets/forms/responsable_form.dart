import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/profesor.dart';

/// Sección de profesor responsable
class ResponsableSection extends StatelessWidget {
  final String? selectedProfesorId;
  final List<Profesor> profesores;
  final Function(String?) onChanged;
  final bool isMobile;
  final bool isMobileLandscape;
  final Widget Function(String title, IconData icon, bool isMobile, bool isMobileLandscape) buildSectionTitle;
  final Widget Function<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    required bool isMobile,
    required bool isMobileLandscape,
  }) buildDropdown;

  const ResponsableSection({
    Key? key,
    required this.selectedProfesorId,
    required this.profesores,
    required this.onChanged,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.buildSectionTitle,
    required this.buildDropdown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle(
          isMobileLandscape ? 'Responsable' : 'Responsables',
          Icons.people_rounded,
          isMobile,
          isMobileLandscape,
        ),
        SizedBox(height: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
        buildDropdown<String>(
          value: profesores.any((p) => p.uuid == selectedProfesorId) 
              ? selectedProfesorId 
              : null,
          label: isMobileLandscape ? 'Profesor' : 'Profesor Responsable',
          icon: Icons.person_rounded,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                isMobileLandscape ? 'Seleccionar...' : 'Seleccionar profesor...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobileLandscape ? 12 : null,
                ),
              ),
            ),
            ...profesores.map((profesor) {
              return DropdownMenuItem<String>(
                value: profesor.uuid,
                child: Text(
                  '${profesor.nombre} ${profesor.apellidos}',
                  style: TextStyle(fontSize: isMobileLandscape ? 12 : null),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ],
          onChanged: onChanged,
          isMobile: isMobile,
          isMobileLandscape: isMobileLandscape,
        ),
      ],
    );
  }
}
