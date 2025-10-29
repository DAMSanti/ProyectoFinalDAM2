import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'package:proyecto_santi/services/holidays_service.dart';
import 'package:proyecto_santi/views/home/helpers/calendar_helpers.dart';
import 'package:proyecto_santi/views/home/widgets/calendar_appointment_widget.dart';
import 'package:proyecto_santi/shared/constants/app_theme_constants.dart';

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

  /// Carga festivos para 3 años (anterior, actual, siguiente)
  Future<void> _loadHolidays() async {
    if (_isLoadingHolidays) return;
    
    setState(() => _isLoadingHolidays = true);

    try {
      final displayDate = _calendarController.displayDate ?? DateTime.now();
      final year = displayDate.year;
      bool holidaysUpdated = false;
      
      for (int y = year - 1; y <= year + 1; y++) {
        final key = CalendarHelpers.getCacheKey(widget.countryCode, y);
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

  /// Obtiene el festivo para una fecha específica
  Holiday? _getHoliday(DateTime day) {
    final key = CalendarHelpers.getCacheKey(widget.countryCode, day.year);
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

  /// Genera lista de appointments (actividades + festivos)
  List<Appointment> _getAppointments() {
    List<Appointment> appointments = [];

    // Agregar actividades usando CalendarHelpers
    for (var actividad in widget.activities) {
      final appointment = CalendarHelpers.actividadToAppointment(actividad);
      if (appointment != null) {
        appointments.add(appointment);
      }
    }

    // Agregar festivos como appointments SOLO en vistas día/semana/agenda (NO en mes)
    if (_currentView != CalendarView.month) {
      final displayDate = _calendarController.displayDate ?? DateTime.now();
      for (int yearOffset = -1; yearOffset <= 1; yearOffset++) {
        final year = displayDate.year + yearOffset;
        final key = CalendarHelpers.getCacheKey(widget.countryCode, year);
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
                  blurRadius: 30,
                  offset: const Offset(0, 10),
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
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                  showAgenda: false,
                  dayFormat: 'EEE',
                  numberOfWeeksInView: isSmallScreen ? 4 : 6,
                  appointmentDisplayCount: isSmallScreen ? 3 : 6,
                  showTrailingAndLeadingDates: !isSmallScreen,
                  monthCellStyle: MonthCellStyle(
                    backgroundColor: Colors.transparent,
                    textStyle: TextStyle(
                      fontSize: isSmallScreen ? 12 : 15,
                      color: isDark ? Color(0xFFE0E0E0) : Color(0xFF424242),
                      fontWeight: FontWeight.w600,
                    ),
                    trailingDatesTextStyle: TextStyle(
                      color: isDark ? Colors.white12 : Colors.black12,
                      fontSize: isSmallScreen ? 10 : 14,
                    ),
                    leadingDatesTextStyle: TextStyle(
                      color: isDark ? Colors.white12 : Colors.black12,
                      fontSize: isSmallScreen ? 10 : 14,
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
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: AppThemeConstants.primaryBlue,
                    letterSpacing: 1.0,
                  ),
                ),
                headerHeight: isSmallScreen ? 50 : 60,
                viewHeaderHeight: isSmallScreen ? 35 : 45,
                viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: isDark 
                      ? Color.fromRGBO(
                          (AppThemeConstants.primaryBlue.r * 255.0).round(),
                          (AppThemeConstants.primaryBlue.g * 255.0).round(),
                          (AppThemeConstants.primaryBlue.b * 255.0).round(),
                          0.1,
                        )
                      : Color.fromRGBO(
                          (AppThemeConstants.primaryBlue.r * 255.0).round(),
                          (AppThemeConstants.primaryBlue.g * 255.0).round(),
                          (AppThemeConstants.primaryBlue.b * 255.0).round(),
                          0.05,
                        ),
                  dayTextStyle: TextStyle(
                    fontSize: isSmallScreen ? 11 : 14,
                    fontWeight: FontWeight.bold,
                    color: AppThemeConstants.primaryBlue,
                    letterSpacing: isSmallScreen ? 0.8 : 1.2,
                  ),
                ),
                todayHighlightColor: AppThemeConstants.primaryBlue,
                todayTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 10 : 15,
                ),
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: AppThemeConstants.primaryBlue,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                cellBorderColor: isDark 
                    ? const Color.fromRGBO(255, 255, 255, 0.03)
                    : const Color.fromRGBO(158, 158, 158, 0.08),
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
                          ? (isDark 
                              ? Color.fromRGBO(
                                  (AppThemeConstants.primaryBlue.r * 255.0).round(),
                                  (AppThemeConstants.primaryBlue.g * 255.0).round(),
                                  (AppThemeConstants.primaryBlue.b * 255.0).round(),
                                  0.25,
                                )
                              : Color.fromRGBO(
                                  (AppThemeConstants.primaryBlue.r * 255.0).round(),
                                  (AppThemeConstants.primaryBlue.g * 255.0).round(),
                                  (AppThemeConstants.primaryBlue.b * 255.0).round(),
                                  0.15,
                                ))
                          : isHoliday
                              ? (isDark 
                                  ? const Color.fromRGBO(244, 67, 54, 0.15)
                                  : const Color.fromRGBO(244, 67, 54, 0.08))
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      // Borde extra para el día de hoy
                      border: isToday
                          ? Border.all(
                              color: Color.fromRGBO(
                                (AppThemeConstants.primaryBlue.r * 255.0).round(),
                                (AppThemeConstants.primaryBlue.g * 255.0).round(),
                                (AppThemeConstants.primaryBlue.b * 255.0).round(),
                                0.5,
                              ),
                              width: 2,
                            )
                          : null,
                    ),
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(top: isSmallScreen ? 2 : 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 15,
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
                        if (!isSmallScreen && isHoliday && isCurrentMonth && !isToday)
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
                  final appointment = calendarAppointmentDetails.appointments.first as Appointment;
                  return CalendarAppointmentWidget(
                    appointment: appointment,
                    currentView: _currentView,
                    isSmallScreen: isSmallScreen,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? const Color.fromRGBO(255, 255, 255, 0.1)
                                : const Color.fromRGBO(255, 255, 255, 0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color.fromRGBO(25, 118, 210, 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? const Color.fromRGBO(255, 255, 255, 0.1)
                                : const Color.fromRGBO(255, 255, 255, 0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color.fromRGBO(25, 118, 210, 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
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
