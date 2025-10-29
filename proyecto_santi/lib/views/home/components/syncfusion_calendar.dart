import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'package:proyecto_santi/services/holidays_service.dart';
import 'package:intl/intl.dart';

class ModernSyncfusionCalendar extends StatefulWidget {
  final List<Actividad> activities;
  final String countryCode;

  const ModernSyncfusionCalendar({
    super.key,
    required this.activities,
    this.countryCode = 'ES',
  });

  @override
  State<ModernSyncfusionCalendar> createState() => _ModernSyncfusionCalendarState();
}

class _ModernSyncfusionCalendarState extends State<ModernSyncfusionCalendar> {
  late final CalendarController _calendarController;
  CalendarView _currentView = CalendarView.month;
  Map<String, List<Holiday>> _holidays = {};
  bool _isLoadingHolidays = false;
  late _ActivityDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _calendarController.displayDate = DateTime.now();
    _calendarController.view = _currentView;
    _dataSource = _ActivityDataSource(_getAppointments());
    _loadHolidays();
  }

  @override
  void didUpdateWidget(ModernSyncfusionCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryCode != widget.countryCode) {
      _holidays.clear();
      _loadHolidays();
    }
    // Actualizar dataSource si cambian las actividades
    if (oldWidget.activities != widget.activities) {
      _updateDataSource();
    }
  }

  void _updateDataSource() {
    setState(() {
      _dataSource = _ActivityDataSource(_getAppointments());
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  String _getCacheKey(int year) => '${widget.countryCode}_$year';

  Future<void> _loadHolidays() async {
    if (_isLoadingHolidays) return;
    
    setState(() => _isLoadingHolidays = true);

    try {
      final displayDate = _calendarController.displayDate ?? DateTime.now();
      final year = displayDate.year;
      bool holidaysUpdated = false;
      
      for (int y = year - 1; y <= year + 1; y++) {
        final key = _getCacheKey(y);
        if (!_holidays.containsKey(key)) {
          final holidays = await HolidaysService.getHolidays(y, countryCode: widget.countryCode);
          if (mounted) {
            setState(() {
              _holidays[key] = holidays;
            });
            holidaysUpdated = true;
          }
        }
      }
      
      // Actualizar dataSource si se cargaron nuevos festivos
      if (holidaysUpdated && mounted) {
        _updateDataSource();
      }
    } catch (e) {
      debugPrint('Error loading holidays: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingHolidays = false);
      }
    }
  }

  Holiday? _getHoliday(DateTime day) {
    final key = _getCacheKey(day.year);
    final yearHolidays = _holidays[key];
    if (yearHolidays == null) return null;

    try {
      return yearHolidays.firstWhere((h) =>
          h.date.year == day.year &&
          h.date.month == day.month &&
          h.date.day == day.day);
    } catch (e) {
      return null;
    }
  }

  Color _getColorByEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'planificada':
        return Color(0xFF2196F3); // Azul
      case 'en curso':
        return Color(0xFF4CAF50); // Verde
      case 'completada':
        return Color(0xFF9E9E9E); // Gris
      case 'cancelada':
        return Color(0xFFF44336); // Rojo
      default:
        return Color(0xFF1976d2); // Azul por defecto
    }
  }

  List<Appointment> _getAppointments() {
    List<Appointment> appointments = [];

    // Agregar actividades
    for (var actividad in widget.activities) {
      try {
        // Parsear fechas
        final startDate = DateTime.parse(actividad.fini);
        final endDate = DateTime.parse(actividad.ffin);

        // Parsear horas (formato "HH:mm:ss")
        DateTime startTime = startDate;
        DateTime endTime = endDate;

        if (actividad.hini.isNotEmpty && actividad.hini != '00:00:00') {
          final horaIniParts = actividad.hini.split(':');
          if (horaIniParts.length >= 2) {
            startTime = DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
              int.parse(horaIniParts[0]),
              int.parse(horaIniParts[1]),
              horaIniParts.length > 2 ? int.parse(horaIniParts[2]) : 0,
            );
          }
        }

        if (actividad.hfin.isNotEmpty && actividad.hfin != '00:00:00') {
          final horaFinParts = actividad.hfin.split(':');
          if (horaFinParts.length >= 2) {
            endTime = DateTime(
              endDate.year,
              endDate.month,
              endDate.day,
              int.parse(horaFinParts[0]),
              int.parse(horaFinParts[1]),
              horaFinParts.length > 2 ? int.parse(horaFinParts[2]) : 0,
            );
          }
        }

        // Si la hora de inicio y fin son iguales en el mismo día, agregar 1 hora
        if (startTime.isAtSameMomentAs(endTime) && 
            startDate.year == endDate.year && 
            startDate.month == endDate.month && 
            startDate.day == endDate.day) {
          endTime = endTime.add(Duration(hours: 1));
        }

        // Determinar si es un evento de todo el día
        // Si ambas horas son 00:00:00 o si dura más de un día, es isAllDay
        final isMultiDay = endDate.difference(startDate).inDays > 0;
        final hasSpecificHours = actividad.hini != '00:00:00' || actividad.hfin != '00:00:00';
        final isAllDay = isMultiDay || !hasSpecificHours;

        appointments.add(Appointment(
          startTime: startTime,
          endTime: endTime,
          subject: actividad.titulo,
          color: _getColorByEstado(actividad.estado),
          isAllDay: isAllDay,
          id: actividad.id,
        ));
      } catch (e) {
        debugPrint('Error al parsear fecha de actividad ${actividad.id}: $e');
      }
    }

    // Agregar festivos como appointments SOLO en vistas día/semana/agenda (NO en mes)
    if (_currentView != CalendarView.month) {
      final displayDate = _calendarController.displayDate ?? DateTime.now();
      for (int yearOffset = -1; yearOffset <= 1; yearOffset++) {
        final year = displayDate.year + yearOffset;
        final key = _getCacheKey(year);
        final yearHolidays = _holidays[key];
        
        if (yearHolidays != null) {
          for (var holiday in yearHolidays) {
            appointments.add(Appointment(
              startTime: holiday.date,
              endTime: holiday.date.add(Duration(hours: 23, minutes: 59)),
              subject: '🎉 ${holiday.name}',
              color: Colors.red.shade400,
              isAllDay: true,
              id: 'holiday_${holiday.date.millisecondsSinceEpoch}',
            ));
          }
        }
      }
    }

    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // Botones de selector de vista
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Color(0xFF1a237e).withOpacity(0.08),
                      Color(0xFF0d47a1).withOpacity(0.05),
                    ]
                  : [
                      Color(0xFFe3f2fd),
                      Color(0xFFbbdefb).withOpacity(0.3),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color(0xFF1976d2).withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1976d2).withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 5),
                spreadRadius: -3,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildViewButton(
                context,
                'Día',
                CalendarView.day,
                Icons.view_day,
                isDark,
              ),
              SizedBox(width: 8),
              _buildViewButton(
                context,
                'Semana',
                CalendarView.week,
                Icons.view_week,
                isDark,
              ),
              SizedBox(width: 8),
              _buildViewButton(
                context,
                'Mes',
                CalendarView.month,
                Icons.calendar_view_month,
                isDark,
              ),
              SizedBox(width: 8),
              _buildViewButton(
                context,
                'Agenda',
                CalendarView.schedule,
                Icons.view_agenda,
                isDark,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        // Calendario
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Detectar si la ventana es pequeña (ancho < 600px)
              final isSmallScreen = constraints.maxWidth < 600;
              
              return Container(
                decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Color(0xFF1a237e).withOpacity(0.08),
                        Color(0xFF0d47a1).withOpacity(0.05),
                      ]
                    : [
                        Color(0xFFe3f2fd),
                        Color(0xFFbbdefb).withOpacity(0.3),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Color(0xFF1976d2).withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976d2).withOpacity(0.08),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  SfCalendar(
                controller: _calendarController,
                view: _currentView,
                dataSource: _dataSource,
                firstDayOfWeek: 1, // Lunes como primer día
                showNavigationArrow: false, // Desactivamos las flechas predeterminadas
                showDatePickerButton: true,
                allowViewNavigation: true,
                onViewChanged: (ViewChangedDetails details) {
                  // Actualizar cuando el usuario navega en el calendario o cambia de vista
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      bool needsUpdate = false;
                      
                      // Actualizar el estado de la vista actual si cambió
                      if (_calendarController.view != null && _calendarController.view != _currentView) {
                        setState(() {
                          _currentView = _calendarController.view!;
                        });
                        needsUpdate = true;
                      }
                      
                      // Cargar festivos si cambió el período mostrado
                      if (_calendarController.displayDate != null) {
                        _loadHolidays();
                      }
                      
                      // Actualizar dataSource cuando cambia la vista para refrescar los festivos
                      if (needsUpdate) {
                        _updateDataSource();
                      }
                    }
                  });
                },
                monthViewSettings: MonthViewSettings(
                  // En pantallas pequeñas: indicators (puntos)
                  // En pantallas grandes: appointments (líneas horizontales)
                  appointmentDisplayMode: isSmallScreen 
                      ? MonthAppointmentDisplayMode.indicator 
                      : MonthAppointmentDisplayMode.appointment,
                  showAgenda: false,
                  dayFormat: 'EEE',
                  numberOfWeeksInView: 6,
                  appointmentDisplayCount: 6,
                  showTrailingAndLeadingDates: true,
                  monthCellStyle: MonthCellStyle(
                    backgroundColor: Colors.transparent,
                    textStyle: TextStyle(
                      fontSize: 15,
                      color: isDark ? Color(0xFFE0E0E0) : Color(0xFF424242),
                      fontWeight: FontWeight.w600,
                    ),
                    trailingDatesTextStyle: TextStyle(
                      color: isDark ? Colors.white12 : Colors.black12,
                      fontSize: 14,
                    ),
                    leadingDatesTextStyle: TextStyle(
                      color: isDark ? Colors.white12 : Colors.black12,
                      fontSize: 14,
                    ),
                  ),
                  navigationDirection: MonthNavigationDirection.horizontal,
                ),
                // Configuración para vista de día
                timeSlotViewSettings: TimeSlotViewSettings(
                  startHour: 7,
                  endHour: 22,
                  timeInterval: Duration(minutes: 30),
                  timeIntervalHeight: 60,
                  timeFormat: 'HH:mm',
                  dateFormat: 'd MMM',
                  dayFormat: 'EEE',
                  timeTextStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? Color(0xFFE0E0E0) : Color(0xFF424242),
                  ),
                ),
                headerStyle: CalendarHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor: Colors.transparent,
                  textStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976d2),
                    letterSpacing: 1.0,
                  ),
                ),
                headerHeight: 60,
                viewHeaderHeight: 45,
                viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: isDark 
                      ? Color(0xFF1976d2).withOpacity(0.1)
                      : Color(0xFF1976d2).withOpacity(0.05),
                  dayTextStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976d2),
                    letterSpacing: 1.2,
                  ),
                ),
                todayHighlightColor: Color(0xFF1976d2),
                todayTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: Color(0xFF1976d2),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                cellBorderColor: isDark 
                    ? Colors.white.withOpacity(0.03)
                    : Colors.grey.withOpacity(0.08),
                backgroundColor: Colors.transparent,
                monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                  final date = details.date;
                  final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
                  final holiday = _getHoliday(date);
                  final isHoliday = holiday != null;
                  final isCurrentMonth = date.month == _calendarController.displayDate?.month;
                  final today = DateTime.now();
                  final isToday = date.year == today.year && 
                                  date.month == today.month && 
                                  date.day == today.day;

                  return Container(
                    decoration: BoxDecoration(
                      // Prioridad: Hoy > Festivo > Transparente
                      color: isToday
                          ? Color(0xFF1976d2).withOpacity(isDark ? 0.25 : 0.15)
                          : isHoliday
                              ? Colors.red.withOpacity(isDark ? 0.15 : 0.08)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      // Borde extra para el día de hoy
                      border: isToday
                          ? Border.all(
                              color: Color(0xFF1976d2).withOpacity(0.5),
                              width: 2,
                            )
                          : null,
                    ),
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(top: 4),
                    child: Column(
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                            color: !isCurrentMonth
                                ? (isDark ? Colors.white12 : Colors.black12)
                                : isToday
                                    ? Colors.white
                                    : isHoliday || isWeekend
                                        ? Colors.red.shade400
                                        : (isDark ? Color(0xFFE0E0E0) : Color(0xFF424242)),
                          ),
                        ),
                        if (isHoliday && isCurrentMonth && !isToday)
                          Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.celebration,
                              size: 10,
                              color: Colors.red.shade400,
                            ),
                          ),
                      ],
                    ),
                  );
                },
                onTap: (CalendarTapDetails details) {
                  if (details.targetElement == CalendarElement.appointment) {
                    final Appointment appointment = details.appointments![0];
                    
                    // Solo navegar si es una actividad (no un festivo)
                    // Los festivos tienen id que empieza con 'holiday_'
                    if (appointment.id is int || (appointment.id is String && !appointment.id.toString().startsWith('holiday_'))) {
                      try {
                        final actividad = widget.activities.firstWhere(
                          (a) => a.id == appointment.id,
                        );
                        
                        navigateToActivityDetailInShell(
                          context,
                          {'activity': actividad},
                        );
                      } catch (e) {
                        // Si no se encuentra la actividad, no hacer nada
                        debugPrint('Actividad no encontrada: ${appointment.id}');
                      }
                    }
                  }
                },
                appointmentBuilder: (context, calendarAppointmentDetails) {
                  final Appointment appointment = calendarAppointmentDetails.appointments.first;
                  
                  // En pantallas pequeñas, usar un Container super simple sin decoración compleja
                  // Esto evita problemas de layout y errores de borderRadius
                  if (isSmallScreen) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 0.5, horizontal: 0.5),
                      decoration: BoxDecoration(
                        color: appointment.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: Text(
                          appointment.subject,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }
                  
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Protección: Si el tamaño es muy pequeño, usar widget super simple
                      if (constraints.maxHeight < 8 || constraints.maxWidth < 10) {
                        return Container(
                          color: appointment.color,
                        );
                      }
                      
                      // En vista día/semana/agenda
                      if (_currentView != CalendarView.month) {
                        final showFullText = constraints.maxHeight > 50;
                        final showTime = !appointment.isAllDay && constraints.maxHeight > 35;
                        
                        // Calcular borderRadius seguro
                        final maxRadius = constraints.maxHeight / 2;
                        final borderRadius = maxRadius > 6 ? 6.0 : (maxRadius > 1 ? maxRadius - 1 : 0.0);
                        
                        return Container(
                          constraints: BoxConstraints(minHeight: 16),
                          margin: EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                appointment.color,
                                appointment.color.withOpacity(0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(borderRadius),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: appointment.color.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Center(
                            child: Text(
                              showTime 
                                  ? '${DateFormat('HH:mm').format(appointment.startTime)} ${appointment.subject}'
                                  : appointment.subject,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: showFullText ? 11 : 9,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: showFullText ? 2 : 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      
                      // Vista mes: diseño compacto con protecciones EXTREMAS
                      final showText = constraints.maxHeight > 12;
                      final showDot = constraints.maxHeight > 8;
                      
                      // Calcular borderRadius ULTRA seguro para vista mes
                      // Tomar altura y ancho, usar el mínimo, restar márgenes y padding
                      final availableHeight = constraints.maxHeight - 1; // margen vertical 0.5 * 2
                      final availableWidth = constraints.maxWidth - 1; // margen horizontal 0.5 * 2
                      final minDimension = availableHeight < availableWidth ? availableHeight : availableWidth;
                      // El radio máximo es la mitad de la dimensión más pequeña, con margen extra
                      final maxSafeRadius = (minDimension / 2) - 1; // Restar 1px extra de seguridad
                      // Limitar a máximo 2px para ser ultra conservador
                      final borderRadius = maxSafeRadius > 2 ? 2.0 : (maxSafeRadius > 0.5 ? maxSafeRadius : 0.0);
                      
                      return Container(
                        constraints: BoxConstraints(minHeight: 6, minWidth: 10),
                        margin: EdgeInsets.symmetric(vertical: 0.5, horizontal: 0.5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              appointment.color,
                              appointment.color.withOpacity(0.85),
                              appointment.color.withOpacity(0.7),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [0.0, 0.5, 1.0],
                          ),
                          borderRadius: borderRadius > 0.5 ? BorderRadius.circular(borderRadius) : null,
                          boxShadow: borderRadius > 1 ? [
                            BoxShadow(
                              color: appointment.color.withOpacity(0.25),
                              blurRadius: 2,
                              offset: Offset(0, 0.5),
                              spreadRadius: 0,
                            ),
                          ] : null,
                          border: borderRadius > 0.5 ? Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.5,
                          ) : null,
                        ),
                        child: showText
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
                                child: Row(
                                  children: [
                                    if (showDot) ...[
                                      Container(
                                        width: 2.5,
                                        height: 2.5,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 2.5),
                                    ],
                                    Expanded(
                                      child: Text(
                                        appointment.subject,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.1,
                                          height: 1.0,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.4),
                                              offset: Offset(0, 0.5),
                                              blurRadius: 1,
                                            ),
                                          ],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                      );
                    },
                  );
                },
              ),
                  // Flechas de navegación personalizadas
                  Positioned(
                    top: 12,
                    left: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _calendarController.backward!();
                          _loadHolidays();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF1976d2).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: Color(0xFF1976d2),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _calendarController.forward!();
                          _loadHolidays();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF1976d2).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: Color(0xFF1976d2),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildViewButton(
    BuildContext context,
    String label,
    CalendarView view,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _currentView == view;
    
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Si el ancho es muy pequeño, mostrar solo el icono
          final showText = constraints.maxWidth > 70;
          
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentView = view;
                  _calendarController.view = view;
                  _updateDataSource(); // Actualizar dataSource al cambiar vista
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 12, 
                  horizontal: showText ? 8 : 4,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Color(0xFF1976d2),
                            Color(0xFF1565c0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected
                      ? null
                      : (isDark
                          ? Colors.white.withOpacity(0.03)
                          : Colors.white.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Color(0xFF1976d2).withOpacity(0.5)
                        : (isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.2)),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Color(0xFF1976d2).withOpacity(0.3),
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
                            color: isSelected
                                ? Colors.white
                                : Color(0xFF1976d2),
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Color(0xFF1976d2),
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
                        size: 20,
                        color: isSelected
                            ? Colors.white
                            : Color(0xFF1976d2),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActivityDataSource extends CalendarDataSource {
  _ActivityDataSource(List<Appointment> source) {
    appointments = source;
  }
}
