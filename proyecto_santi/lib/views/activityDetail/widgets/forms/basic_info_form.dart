import 'package:flutter/material.dart';

/// Sección de información básica (nombre y descripción)
class BasicInfoSection extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController descripcionController;
  final bool isMobile;
  final bool isMobileLandscape;
  final Widget Function({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired,
    int? maxLines,
    required bool isMobile,
    required bool isMobileLandscape,
  }) buildTextField;
  final Widget Function(String title, IconData icon, bool isMobile, bool isMobileLandscape) buildSectionTitle;

  const BasicInfoSection({
    Key? key,
    required this.nombreController,
    required this.descripcionController,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.buildTextField,
    required this.buildSectionTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Información Básica', Icons.info_rounded, isMobile, isMobileLandscape),
        SizedBox(height: isMobile ? 10 : 12),
        buildTextField(
          controller: nombreController,
          label: isMobileLandscape ? 'Nombre' : 'Nombre de la actividad',
          hint: isMobileLandscape ? 'Nombre de la actividad' : 'Ej: Visita al Museo del Prado',
          icon: Icons.title_rounded,
          isRequired: true,
          isMobile: isMobile,
          isMobileLandscape: isMobileLandscape,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        buildTextField(
          controller: descripcionController,
          label: 'Descripción',
          hint: isMobileLandscape ? 'Descripción breve' : 'Describe brevemente la actividad...',
          icon: Icons.description_rounded,
          maxLines: isMobileLandscape ? 2 : 3,
          isMobile: isMobile,
          isMobileLandscape: isMobileLandscape,
        ),
      ],
    );
  }
}
