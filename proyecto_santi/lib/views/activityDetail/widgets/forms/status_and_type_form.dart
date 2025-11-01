import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/tema.dart';

/// Sección de estado y tipo de actividad
class ActivityStatusAndTypeSection extends StatelessWidget {
  final String estadoActividad;
  final String tipoActividad;
  final Function(String) onEstadoChanged;
  final Function(String) onTipoChanged;
  final bool isMobile;
  final bool isMobileLandscape;
  final Widget Function({
    required String value,
    required String groupValue,
    required String label,
    required IconData icon,
    required Color color,
    required Function(String?) onChanged,
    required bool isMobile,
    required bool isMobileLandscape,
  }) buildRadioOption;

  const ActivityStatusAndTypeSection({
    Key? key,
    required this.estadoActividad,
    required this.tipoActividad,
    required this.onEstadoChanged,
    required this.onTipoChanged,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.buildRadioOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estado de la Actividad
        Container(
          padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 16)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
            border: Border.all(
              color: AppColors.primaryOpacity30,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado de la Actividad',
                style: TextStyle(
                  fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
              Row(
                children: [
                  Expanded(
                    child: buildRadioOption(
                      value: 'Pendiente',
                      groupValue: estadoActividad,
                      label: 'Pendiente',
                      icon: Icons.schedule_rounded,
                      color: AppColors.estadoPendiente,
                      onChanged: (value) => onEstadoChanged(value!),
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                    ),
                  ),
                  SizedBox(width: isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
                  Expanded(
                    child: buildRadioOption(
                      value: 'Aprobada',
                      groupValue: estadoActividad,
                      label: 'Aprobada',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.estadoAprobado,
                      onChanged: (value) => onEstadoChanged(value!),
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                    ),
                  ),
                  SizedBox(width: isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
                  Expanded(
                    child: buildRadioOption(
                      value: 'Cancelada',
                      groupValue: estadoActividad,
                      label: 'Cancelada',
                      icon: Icons.cancel_rounded,
                      color: AppColors.estadoRechazado,
                      onChanged: (value) => onEstadoChanged(value!),
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: isMobileLandscape ? 10 : (isMobile ? 12 : 16)),
        
        // Tipo de Actividad
        Container(
          padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 16)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
            border: Border.all(
              color: AppColors.primaryOpacity30,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tipo de Actividad',
                style: TextStyle(
                  fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
              Row(
                children: [
                  Expanded(
                    child: buildRadioOption(
                      value: 'Complementaria',
                      groupValue: tipoActividad,
                      label: 'Complementaria',
                      icon: Icons.school_rounded,
                      color: AppColors.primary,
                      onChanged: (value) => onTipoChanged(value!),
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                    ),
                  ),
                  SizedBox(width: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                  Expanded(
                    child: buildRadioOption(
                      value: 'Extraescolar',
                      groupValue: tipoActividad,
                      label: 'Extraescolar',
                      icon: Icons.sports_soccer_rounded,
                      color: AppColors.tipoComplementaria,
                      onChanged: (value) => onTipoChanged(value!),
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
