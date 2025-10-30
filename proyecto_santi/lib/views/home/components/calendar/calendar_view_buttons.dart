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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Detectar si es móvil (menos de 600px)
        final isMobile = constraints.maxWidth < 600;
        
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 16,
            vertical: isMobile ? 6 : 12,
          ),
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
            borderRadius: BorderRadius.circular(isMobile ? 12 : 24),
            border: Border.all(
              color: Color.fromRGBO(
                (AppThemeConstants.primaryBlue.r * 255.0).round(),
                (AppThemeConstants.primaryBlue.g * 255.0).round(),
                (AppThemeConstants.primaryBlue.b * 255.0).round(),
                0.15,
              ),
              width: isMobile ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(
                  (AppThemeConstants.primaryBlue.r * 255.0).round(),
                  (AppThemeConstants.primaryBlue.g * 255.0).round(),
                  (AppThemeConstants.primaryBlue.b * 255.0).round(),
                  0.08,
                ),
                blurRadius: isMobile ? 10 : 20,
                offset: Offset(0, isMobile ? 2 : 5),
                spreadRadius: -3,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton('Día', CalendarView.day, Icons.view_day, showText: !isMobile, isMobile: isMobile),
              SizedBox(width: isMobile ? 4 : 8),
              _buildButton('Semana', CalendarView.week, Icons.view_week, showText: !isMobile, isMobile: isMobile),
              SizedBox(width: isMobile ? 4 : 8),
              _buildButton('Mes', CalendarView.month, Icons.calendar_view_month, showText: !isMobile, isMobile: isMobile),
              SizedBox(width: isMobile ? 4 : 8),
              _buildButton('Agenda', CalendarView.schedule, Icons.view_agenda, showText: !isMobile, isMobile: isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerticalButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ajustar el espaciado según la altura disponible
        final availableHeight = constraints.maxHeight;
        final spacing = availableHeight < 220 ? 4.0 : 8.0;
        final verticalPadding = availableHeight < 220 ? 8.0 : 12.0;
        
        return Container(
          width: 80,
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 8),
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: _buildButton('Día', CalendarView.day, Icons.view_day, showText: false)),
              SizedBox(height: spacing),
              Flexible(child: _buildButton('Semana', CalendarView.week, Icons.view_week, showText: false)),
              SizedBox(height: spacing),
              Flexible(child: _buildButton('Mes', CalendarView.month, Icons.calendar_view_month, showText: false)),
              SizedBox(height: spacing),
              Flexible(child: _buildButton('Agenda', CalendarView.schedule, Icons.view_agenda, showText: false)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(String label, CalendarView view, IconData icon, {required bool showText, bool isMobile = false}) {
    final isSelected = currentView == view;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ajustar tamaño del icono según el espacio disponible
        final iconSize = isMobile ? 18.0 : (constraints.maxHeight < 50 ? 20.0 : 24.0);
        final buttonPadding = isMobile ? 6.0 : (constraints.maxHeight < 50 ? 8.0 : 10.0);
        
        Widget buttonContent = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onViewChanged(view),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: showText ? (isMobile ? 10 : 16) : (isMobile ? 8 : 12),
                vertical: showText ? (isMobile ? 6 : 12) : buttonPadding,
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
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            border: Border.all(
              color: isSelected
                  ? const Color.fromRGBO(25, 118, 210, 0.5)
                  : (isDark
                      ? const Color.fromRGBO(255, 255, 255, 0.1)
                      : const Color.fromRGBO(158, 158, 158, 0.2)),
              width: isMobile ? 1 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color.fromRGBO(25, 118, 210, 0.3),
                      blurRadius: isMobile ? 4 : 8,
                      offset: Offset(0, isMobile ? 2 : 4),
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
                      size: isMobile ? 16 : 18,
                      color: isSelected ? Colors.white : const Color(0xFF1976d2),
                    ),
                    SizedBox(width: isMobile ? 4 : 6),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF1976d2),
                          fontSize: isMobile ? 11 : 13,
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
                  size: iconSize,
                  color: isSelected ? Colors.white : const Color(0xFF1976d2),
                ),
            ),
          ),
        );

        return showText ? Expanded(child: buttonContent) : buttonContent;
      },
    );
  }
}
