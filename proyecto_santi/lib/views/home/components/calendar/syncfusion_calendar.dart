import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../models/actividad.dart';
import '../../../../services/holidays_service.dart';
import '../../helpers/calendar_helpers.dart';
import '../../../../shared/constants/app_theme_constants.dart';
import 'calendar_view_buttons.dart';
import 'calendar_data_source.dart';
import 'calendar_builders.dart';
import 'calendar_config.dart';

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
  late ActivityDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _calendarController.displayDate = DateTime.now();
    _calendarController.view = _currentView;
    _dataSource = ActivityDataSource(_getAppointments());
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
      _dataSource = ActivityDataSource(_getAppointments());
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
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cambiar a layout vertical si el ancho es menor a 1200px
        final isNarrowScreen = constraints.maxWidth < 1200;
        
        if (isNarrowScreen) {
          // Layout vertical: botones a la izquierda, calendario a la derecha
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botones verticales usando el widget extraído
              CalendarViewButtons(
                currentView: _currentView,
                onViewChanged: _changeView,
                isDark: isDark,
                isVertical: true,
              ),
              SizedBox(width: 16),
              // Calendario expandido
              Expanded(
                child: _buildCalendarContainer(context, isDark, isNarrowScreen),
              ),
            ],
          );
        } else {
          // Layout horizontal original: botones arriba, calendario abajo
          return Column(
            children: [
              // Botones horizontales usando el widget extraído
              CalendarViewButtons(
                currentView: _currentView,
                onViewChanged: _changeView,
                isDark: isDark,
                isVertical: false,
              ),
              SizedBox(height: 16),
              Expanded(
                child: _buildCalendarContainer(context, isDark, isNarrowScreen),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildCalendarContainer(BuildContext context, bool isDark, bool isNarrowScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                  appointmentDisplayMode: MonthAppointmentDisplayMode.none,
                  showAgenda: false,
                  dayFormat: 'EEE',
                  numberOfWeeksInView: 6,
                  showTrailingAndLeadingDates: true,
                  monthCellStyle: MonthCellStyle(
                    backgroundColor: Colors.transparent,
                    textStyle: TextStyle(
                      fontSize: isSmallScreen ? 11 : 14,
                      color: isDark ? Color(0xFFE0E0E0) : Color(0xFF424242),
                      fontWeight: FontWeight.w600,
                    ),
                    trailingDatesTextStyle: TextStyle(
                      color: isDark ? Colors.white12 : Colors.black12,
                      fontSize: isSmallScreen ? 9 : 12,
                    ),
                    leadingDatesTextStyle: TextStyle(
                      color: isDark ? Colors.white12 : Colors.black12,
                      fontSize: isSmallScreen ? 9 : 12,
                    ),
                  ),
                  navigationDirection: MonthNavigationDirection.horizontal,
                ),
                monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                  return CalendarBuilders.monthCellBuilder(
                    context,
                    details,
                    isDark,
                    isSmallScreen,
                    _getHoliday,
                    _calendarController,
                  );
                },
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
                onTap: (CalendarTapDetails details) {
                  CalendarBuilders.handleAppointmentTap(
                    context,
                    details,
                    widget.activities,
                  );
                },
                appointmentBuilder: (context, calendarAppointmentDetails) {
                  return CalendarBuilders.appointmentBuilder(
                    context,
                    calendarAppointmentDetails,
                    _currentView,
                    isSmallScreen,
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
    );
  }

  void _changeView(CalendarView newView) {
    setState(() {
      _currentView = newView;
      _calendarController.view = newView;
      // Actualizar dataSource para reflejar el cambio de vista
      _updateDataSource();
    });
  }
}
