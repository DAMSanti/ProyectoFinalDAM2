import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../shared/constants/app_theme_constants.dart';

/// Widget para los botones de cambio de vista del calendario
class CalendarViewButtons extends StatelessWidget {
  final CalendarView currentView;
  final Function(CalendarView) onViewChanged;
  final bool isDark;
  final bool isVertical;

  const CalendarViewButtons({
    super.key,
    required this.currentView,
    required this.onViewChanged,
    required this.isDark,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return _buildVerticalButtons();
    } else {
      return _buildHorizontalButtons();
    }
  }

  Widget _buildHorizontalButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color.fromRGBO(26, 35, 126, 0.08),
                  Color.fromRGBO(13, 71, 161, 0.05),
                ]
              : const [
                  Color(0xFFe3f2fd),
                  Color.fromRGBO(187, 222, 251, 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color.fromRGBO(
            (AppThemeConstants.primaryBlue.r * 255.0).round(),
            (AppThemeConstants.primaryBlue.g * 255.0).round(),
            (AppThemeConstants.primaryBlue.b * 255.0).round(),
            0.15,
          ),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              (AppThemeConstants.primaryBlue.r * 255.0).round(),
              (AppThemeConstants.primaryBlue.g * 255.0).round(),
              (AppThemeConstants.primaryBlue.b * 255.0).round(),
              0.08,
            ),
            blurRadius: 20,
            offset: const Offset(0, 5),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton('Día', CalendarView.day, Icons.view_day, showText: true),
          SizedBox(width: 8),
          _buildButton('Semana', CalendarView.week, Icons.view_week, showText: true),
          SizedBox(width: 8),
          _buildButton('Mes', CalendarView.month, Icons.calendar_view_month, showText: true),
          SizedBox(width: 8),
          _buildButton('Agenda', CalendarView.schedule, Icons.view_agenda, showText: true),
        ],
      ),
    );
  }

  Widget _buildVerticalButtons() {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color.fromRGBO(26, 35, 126, 0.08),
                  Color.fromRGBO(13, 71, 161, 0.05),
                ]
              : const [
                  Color(0xFFe3f2fd),
                  Color.fromRGBO(187, 222, 251, 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color.fromRGBO(
            (AppThemeConstants.primaryBlue.r * 255.0).round(),
            (AppThemeConstants.primaryBlue.g * 255.0).round(),
            (AppThemeConstants.primaryBlue.b * 255.0).round(),
            0.15,
          ),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              (AppThemeConstants.primaryBlue.r * 255.0).round(),
              (AppThemeConstants.primaryBlue.g * 255.0).round(),
              (AppThemeConstants.primaryBlue.b * 255.0).round(),
              0.08,
            ),
            blurRadius: 20,
            offset: const Offset(5, 0),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildButton('Día', CalendarView.day, Icons.view_day, showText: false),
          SizedBox(height: 12),
          _buildButton('Semana', CalendarView.week, Icons.view_week, showText: false),
          SizedBox(height: 12),
          _buildButton('Mes', CalendarView.month, Icons.calendar_view_month, showText: false),
          SizedBox(height: 12),
          _buildButton('Agenda', CalendarView.schedule, Icons.view_agenda, showText: false),
        ],
      ),
    );
  }

  Widget _buildButton(String label, CalendarView view, IconData icon, {required bool showText}) {
    final isSelected = currentView == view;
    
    Widget buttonContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onViewChanged(view),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: showText ? 16 : 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [
                      Color(0xFF1976d2),
                      Color(0xFF1565c0),
                    ],
                  )
                : null,
            color: isSelected
                ? null
                : (isDark
                    ? const Color.fromRGBO(255, 255, 255, 0.03)
                    : const Color.fromRGBO(255, 255, 255, 0.5)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color.fromRGBO(25, 118, 210, 0.5)
                  : (isDark
                      ? const Color.fromRGBO(255, 255, 255, 0.1)
                      : const Color.fromRGBO(158, 158, 158, 0.2)),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(25, 118, 210, 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: showText
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected ? Colors.white : Color(0xFF1976d2),
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF1976d2),
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                )
              : Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Colors.white : Color(0xFF1976d2),
                ),
        ),
      ),
    );

    return showText ? Expanded(child: buttonContent) : buttonContent;
  }
}
