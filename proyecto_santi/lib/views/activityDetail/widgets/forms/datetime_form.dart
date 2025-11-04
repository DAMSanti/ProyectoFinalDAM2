import 'package:flutter/material.dart';

/// Sección de fechas y horarios
class DateTimeSection extends StatelessWidget {
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;
  final Function(BuildContext, bool) onSelectDate;
  final Function(BuildContext, bool) onSelectTime;
  final bool isMobile;
  final bool isMobileLandscape;
  final Widget Function(String title, IconData icon, bool isMobile, bool isMobileLandscape) buildSectionTitle;
  final Widget Function({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    required bool isMobile,
    required bool isMobileLandscape,
  }) buildDateTimeButton;

  const DateTimeSection({
    super.key,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horaInicio,
    required this.horaFin,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.buildSectionTitle,
    required this.buildDateTimeButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Fechas y Horarios', Icons.event_rounded, isMobile, isMobileLandscape),
        SizedBox(height: isMobile ? 10 : 12),
        if (isMobile && !isMobileLandscape) ...[
          // Layout vertical para móviles portrait
          buildDateTimeButton(
            label: 'Fecha Inicio',
            icon: Icons.calendar_today_rounded,
            value: '${fechaInicio.day.toString().padLeft(2, '0')}/${fechaInicio.month.toString().padLeft(2, '0')}/${fechaInicio.year}',
            onTap: () => onSelectDate(context, true),
            isMobile: isMobile,
            isMobileLandscape: isMobileLandscape,
          ),
          SizedBox(height: 10),
          buildDateTimeButton(
            label: 'Hora Inicio',
            icon: Icons.access_time_rounded,
            value: '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
            onTap: () => onSelectTime(context, true),
            isMobile: isMobile,
            isMobileLandscape: isMobileLandscape,
          ),
          SizedBox(height: 10),
          buildDateTimeButton(
            label: 'Fecha Fin',
            icon: Icons.calendar_today_rounded,
            value: '${fechaFin.day.toString().padLeft(2, '0')}/${fechaFin.month.toString().padLeft(2, '0')}/${fechaFin.year}',
            onTap: () => onSelectDate(context, false),
            isMobile: isMobile,
            isMobileLandscape: isMobileLandscape,
          ),
          SizedBox(height: 10),
          buildDateTimeButton(
            label: 'Hora Fin',
            icon: Icons.access_time_rounded,
            value: '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}',
            onTap: () => onSelectTime(context, false),
            isMobile: isMobile,
            isMobileLandscape: isMobileLandscape,
          ),
        ] else if (isMobileLandscape) ...[
          // Layout compacto para landscape mobile
          Row(
            children: [
              Expanded(
                child: buildDateTimeButton(
                  label: 'Inicio',
                  icon: Icons.calendar_today_rounded,
                  value: '${fechaInicio.day.toString().padLeft(2, '0')}/${fechaInicio.month.toString().padLeft(2, '0')}',
                  onTap: () => onSelectDate(context, true),
                  isMobile: isMobile,
                  isMobileLandscape: isMobileLandscape,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: buildDateTimeButton(
                  label: 'Hora',
                  icon: Icons.access_time_rounded,
                  value: '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
                  onTap: () => onSelectTime(context, true),
                  isMobile: isMobile,
                  isMobileLandscape: isMobileLandscape,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: buildDateTimeButton(
                  label: 'Fin',
                  icon: Icons.calendar_today_rounded,
                  value: '${fechaFin.day.toString().padLeft(2, '0')}/${fechaFin.month.toString().padLeft(2, '0')}',
                  onTap: () => onSelectDate(context, false),
                  isMobile: isMobile,
                  isMobileLandscape: isMobileLandscape,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: buildDateTimeButton(
                  label: 'Hora',
                  icon: Icons.access_time_rounded,
                  value: '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}',
                  onTap: () => onSelectTime(context, false),
                  isMobile: isMobile,
                  isMobileLandscape: isMobileLandscape,
                ),
              ),
            ],
          ),
        ] else ...[
          // Layout horizontal para desktop
          Row(
            children: [
              Expanded(
                child: buildDateTimeButton(
                  label: 'Fecha Inicio',
                  icon: Icons.calendar_today_rounded,
                  value: '${fechaInicio.day.toString().padLeft(2, '0')}/${fechaInicio.month.toString().padLeft(2, '0')}/${fechaInicio.year}',
                  onTap: () => onSelectDate(context, true),
                  isMobile: isMobile,
                  isMobileLandscape: isMobileLandscape,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: buildDateTimeButton(
                  label: 'Hora Inicio',
                  icon: Icons.access_time_rounded,
                  value: '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
                  onTap: () => onSelectTime(context, true),
                  isMobile: isMobile,
                  isMobileLandscape: isMobileLandscape,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildDateTimeButton(
                  label: 'Fecha Fin',
                  icon: Icons.calendar_today_rounded,
                  value: '${fechaFin.day.toString().padLeft(2, '0')}/${fechaFin.month.toString().padLeft(2, '0')}/${fechaFin.year}',
                  onTap: () => onSelectDate(context, false),
                  isMobile: isMobile,
                  isMobileLandscape: isMobileLandscape,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: buildDateTimeButton(
                  label: 'Hora Fin',
                  icon: Icons.access_time_rounded,
                  value: '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}',
                  onTap: () => onSelectTime(context, false),
                  isMobile: isMobile,
                  isMobileLandscape: isMobileLandscape,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
