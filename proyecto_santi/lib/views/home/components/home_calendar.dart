import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
import 'package:proyecto_santi/services/holidays_service.dart';
import 'package:intl/intl.dart';

class ModernCalendar extends StatefulWidget {
  final List<Actividad> activities;
  final String countryCode;

  const ModernCalendar({
    super.key,
    required this.activities,
    this.countryCode = 'ES',
  });

  @override
  State<ModernCalendar> createState() => _ModernCalendarState();
}

class _ModernCalendarState extends State<ModernCalendar> with AutomaticKeepAliveClientMixin {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Holiday>> _holidays = {};
  bool _isLoadingHolidays = false;

  @override
  bool get wantKeepAlive => true; // Mantener el estado vivo

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadHolidays();
  }

  @override
  void didUpdateWidget(ModernCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryCode != widget.countryCode) {
      _holidays.clear();
      _loadHolidays();
    }
  }

  String _getCacheKey(int year) => '${widget.countryCode}_$year';

  Future<void> _loadHolidays() async {
    if (_isLoadingHolidays) return;
    
    setState(() => _isLoadingHolidays = true);

    try {
      final year = _focusedMonth.year;
      for (int y = year - 1; y <= year + 1; y++) {
        final key = _getCacheKey(y);
        if (!_holidays.containsKey(key)) {
          final holidays = await HolidaysService.getHolidays(y);
          if (mounted) {
            setState(() {
              _holidays[key] = holidays;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading holidays: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingHolidays = false);
      }
    }
  }

  List<Actividad> _getActivitiesForDay(DateTime day) {
    final result = widget.activities.where((actividad) {
      try {
        final start = DateTime.parse(actividad.fini);
        final end = DateTime.parse(actividad.ffin);

        final dayNormalized = DateTime(day.year, day.month, day.day);
        final startNormalized = DateTime(start.year, start.month, start.day);
        final endNormalized = DateTime(end.year, end.month, end.day);

        // Si la fecha de fin es anterior a la de inicio, usar solo la fecha de inicio
        final actualEndNormalized = endNormalized.isBefore(startNormalized) 
            ? startNormalized 
            : endNormalized;

        final isInRange = (dayNormalized.isAtSameMomentAs(startNormalized) ||
                dayNormalized.isAfter(startNormalized)) &&
            (dayNormalized.isAtSameMomentAs(actualEndNormalized) ||
                dayNormalized.isBefore(actualEndNormalized));
        
        return isInRange;
      } catch (e) {
        return false;
      }
    }).toList();
    
    return result;
  }

  // Filtrar solo actividades de un solo día (sin barras horizontales)
  List<Actividad> _getSingleDayActivities(DateTime day) {
    return _getActivitiesForDay(day).where((actividad) {
      try {
        final start = DateTime.parse(actividad.fini);
        final end = DateTime.parse(actividad.ffin);
        
        final startNormalized = DateTime(start.year, start.month, start.day);
        final endNormalized = DateTime(end.year, end.month, end.day);
        
        // Solo incluir si la duración es 0 días (mismo día)
        return endNormalized.difference(startNormalized).inDays == 0;
      } catch (e) {
        return true; // En caso de error, incluir la actividad
      }
    }).toList();
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xFF1976d2).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1976d2).withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildWeekDays(),
              Flexible(
                child: LayoutBuilder(
                  builder: (context, gridConstraints) {
                    return _buildCalendarGrid(constraints, gridConstraints.maxHeight);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final monthName = DateFormat('MMMM yyyy', 'es_ES').format(_focusedMonth);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1976d2).withOpacity(0.15),
            Color(0xFF1565c0).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderButton(
            icon: Icons.chevron_left,
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
                _loadHolidays();
              });
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                monthName[0].toUpperCase() + monthName.substring(1),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976d2),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          _buildHeaderButton(
            icon: Icons.chevron_right,
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
                _loadHolidays();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFF1976d2).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Color(0xFF1976d2),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: weekDays.map((day) {
          final isWeekend = day == 'S' || day == 'D';
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isWeekend
                      ? Colors.red.shade300
                      : Color(0xFF1976d2),
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Clase auxiliar para organizar las actividades por filas
  List<List<_ActivityBar>> _organizeActivityBars() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    int startingWeekday = firstDayOfMonth.weekday - 1;
    if (startingWeekday == -1) startingWeekday = 6;

    List<_ActivityBar> bars = [];

    // Crear barras para actividades multi-día
    for (var actividad in widget.activities) {
      try {
        final start = DateTime.parse(actividad.fini);
        final end = DateTime.parse(actividad.ffin);
        
        final startNormalized = DateTime(start.year, start.month, start.day);
        final endNormalized = DateTime(end.year, end.month, end.day);
        final actualEnd = endNormalized.isBefore(startNormalized) ? startNormalized : endNormalized;
        
        final duration = actualEnd.difference(startNormalized).inDays;
        
        // Solo crear barras para actividades que están en este mes y duran más de 1 día
        if (startNormalized.month == _focusedMonth.month || actualEnd.month == _focusedMonth.month) {
          if (duration > 0) { // Actividad multi-día
            // Calcular día de inicio y fin dentro del mes actual
            DateTime displayStart = startNormalized;
            DateTime displayEnd = actualEnd;
            
            if (startNormalized.month < _focusedMonth.month) {
              displayStart = firstDayOfMonth;
            }
            if (actualEnd.month > _focusedMonth.month) {
              displayEnd = lastDayOfMonth;
            }
            
            // Calcular posiciones en el grid
            final startDay = displayStart.day;
            final endDay = displayEnd.day;
            final startIndex = startDay - 1 + startingWeekday;
            final endIndex = endDay - 1 + startingWeekday;
            
            bars.add(_ActivityBar(
              actividad: actividad,
              startIndex: startIndex,
              endIndex: endIndex,
              startRow: startIndex ~/ 7,
              endRow: endIndex ~/ 7,
            ));
          }
        }
      } catch (e) {
        debugPrint('Error procesando actividad para barra: $e');
      }
    }

    // Organizar barras en filas sin superposición
    List<List<_ActivityBar>> rows = [];
    for (var bar in bars) {
      bool placed = false;
      
      for (var row in rows) {
        // Verificar si esta barra puede colocarse en esta fila sin superponerse
        bool canPlace = true;
        for (var existingBar in row) {
          if (_barsOverlap(bar, existingBar)) {
            canPlace = false;
            break;
          }
        }
        
        if (canPlace) {
          row.add(bar);
          placed = true;
          break;
        }
      }
      
      if (!placed) {
        rows.add([bar]);
      }
    }

    return rows;
  }

  bool _barsOverlap(_ActivityBar bar1, _ActivityBar bar2) {
    return !(bar1.endIndex < bar2.startIndex || bar2.endIndex < bar1.startIndex);
  }

  Widget _buildCalendarGrid(BoxConstraints constraints, double availableGridHeight) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    int startingWeekday = firstDayOfMonth.weekday - 1;
    if (startingWeekday == -1) startingWeekday = 6;

    final daysInMonth = lastDayOfMonth.day;
    final totalCells = ((daysInMonth + startingWeekday) / 7).ceil() * 7;

    // Usar la altura disponible pasada como parámetro
    final numberOfRows = (totalCells / 7).ceil();
    
    // Espaciado entre celdas
    final crossSpacing = 4.0;
    final mainSpacing = 4.0;
    final horizontalPadding = 12.0;
    final verticalPadding = 8.0;
    final totalMainSpacing = (numberOfRows - 1) * mainSpacing;
    
    // Altura neta disponible para las celdas - con margen de seguridad
    final safetyMargin = 10.0;
    final netHeight = availableGridHeight - verticalPadding - totalMainSpacing - safetyMargin;
    final cellHeight = netHeight / numberOfRows;
    
    // Validar que cellHeight sea positivo y razonable
    final validCellHeight = cellHeight > 15 ? cellHeight : 50.0;
    
    // Ancho de celda
    final totalCrossSpacing = 6 * crossSpacing;
    final cellWidth = (constraints.maxWidth - horizontalPadding - totalCrossSpacing) / 7;
    
    // Calcular aspect ratio con validación
    final aspectRatio = cellWidth / validCellHeight;
    final validAspectRatio = aspectRatio > 0.2 && aspectRatio < 4 ? aspectRatio : 1.0;

    // Calcular cuántas filas son realmente visibles en el espacio disponible
    final maxVisibleRows = (availableGridHeight / (validCellHeight + mainSpacing)).floor();
    final visibleRows = maxVisibleRows < numberOfRows ? maxVisibleRows : numberOfRows;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: LayoutBuilder(
        builder: (context, localConstraints) {
          // Recalcular las barras de actividades en cada cambio de layout
          final activityBarRows = _organizeActivityBars();
          
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Grid de días
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: validAspectRatio,
                  crossAxisSpacing: crossSpacing,
                  mainAxisSpacing: mainSpacing,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  if (index < startingWeekday) {
                    return SizedBox.shrink();
                  }

                  final dayNumber = index - startingWeekday + 1;
                  if (dayNumber > daysInMonth) {
                    return SizedBox.shrink();
                  }

                  final currentDay = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                  final isToday = _isSameDay(currentDay, DateTime.now());
                  final isSelected = _selectedDay != null && _isSameDay(currentDay, _selectedDay!);
                  final holiday = _getHoliday(currentDay);
                  final activities = _getActivitiesForDay(currentDay);
                  final singleDayActivities = _getSingleDayActivities(currentDay);
                  final isWeekend = currentDay.weekday == DateTime.saturday ||
                      currentDay.weekday == DateTime.sunday;

                  return _buildDayCell(
                    currentDay,
                    dayNumber,
                    isToday,
                    isSelected,
                    isWeekend,
                    holiday,
                    activities,
                    singleDayActivities,
                  );
                },
              ),
              // Barras de actividades multi-día
              ..._buildActivityBarsWidgets(
                context,
                activityBarRows,
                cellWidth,
                validCellHeight,
                crossSpacing,
                mainSpacing,
                totalCells,
                startingWeekday,
                daysInMonth,
                visibleRows,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    int dayNumber,
    bool isToday,
    bool isSelected,
    bool isWeekend,
    Holiday? holiday,
    List<Actividad> activities,
    List<Actividad> singleDayActivities, // Nuevo parámetro
  ) {
    final hasActivities = activities.isNotEmpty;
    final hasSingleDayActivities = singleDayActivities.isNotEmpty;
    final isHoliday = holiday != null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDay = day;
          });

          if (hasActivities) {
            _showActivitiesDialog(day, activities);
          } else if (isHoliday) {
            _showHolidayDialog(day, holiday);
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Color(0xFF1976d2).withOpacity(0.3),
                      Color(0xFF1565c0).withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : isToday
                    ? LinearGradient(
                        colors: [
                          Color(0xFF1976d2).withOpacity(0.15),
                          Color(0xFF1565c0).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : isHoliday
                        ? LinearGradient(
                            colors: [
                              Colors.red.withOpacity(0.1),
                              Colors.red.withOpacity(0.05),
                            ],
                          )
                        : null,
            color: isHoliday ? null : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isToday
                  ? Color(0xFF1976d2)
                  : isSelected
                      ? Color(0xFF1565c0)
                      : Colors.white.withOpacity(0.1),
              width: isToday ? 2.5 : 1,
            ),
            boxShadow: isSelected || isToday
                ? [
                    BoxShadow(
                      color: Color(0xFF1976d2).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: LayoutBuilder(
            builder: (context, cellConstraints) {
              // Calcular tamaño de fuente según el tamaño de la celda
              final cellSize = cellConstraints.maxHeight;
              final fontSize = cellSize > 60 ? 16.0 : cellSize > 40 ? 14.0 : 12.0;
              final iconSize = cellSize > 60 ? 12.0 : 10.0;
              
              return Stack(
                children: [
                  // Número del día
                  Positioned(
                    top: cellSize > 50 ? 8 : 4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isHoliday
                                ? Colors.red.shade400
                                : isWeekend
                                    ? Colors.red.shade300
                                    : isToday || isSelected
                                        ? Color(0xFF1976d2)
                                        : Colors.black54, // Mismo gris que las fechas de las activity cards
                            inherit: false,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Indicador de festivo
                  if (isHoliday && cellSize > 40)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Icon(
                        Icons.celebration,
                        size: iconSize,
                        color: Colors.red.shade400,
                      ),
                    ),

                  // Indicadores de actividades (puntos de colores) - solo para actividades de un día
                  if (hasSingleDayActivities && cellSize > 35)
                    Positioned(
                      bottom: cellSize > 50 ? 6 : 3,
                      left: 0,
                      right: 0,
                      child: _buildActivityIndicators(singleDayActivities, cellSize),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActivityIndicators(List<Actividad> activities, double cellSize) {
    final maxVisible = cellSize > 60 ? 3 : cellSize > 40 ? 2 : 1;
    final visibleActivities = activities.take(maxVisible).toList();
    final hasMore = activities.length > maxVisible;
    final dotSize = cellSize > 60 ? 10.0 : cellSize > 40 ? 9.0 : 8.0; // Aumentado más: de 8/7/6 a 10/9/8
    final fontSize = cellSize > 60 ? 10.0 : 8.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...visibleActivities.map((activity) {
          final color = _getActivityColor(activity.estado);
          return Container(
            width: dotSize,
            height: dotSize,
            margin: EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: cellSize > 50
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          );
        }).toList(),
        if (hasMore && cellSize > 50)
          Container(
            margin: EdgeInsets.only(left: 2),
            child: Text(
              '+${activities.length - maxVisible}',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976d2),
              ),
            ),
          ),
      ],
    );
  }

  Color _getActivityColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'planificada':
        return Color(0xFF2196F3);
      case 'en curso':
        return Color(0xFF4CAF50);
      case 'completada':
        return Color(0xFF9E9E9E);
      case 'cancelada':
        return Color(0xFFF44336);
      default:
        return Color(0xFF1976d2);
    }
  }

  void _showActivitiesDialog(DateTime day, List<Actividad> activities) {
    showDialog(
      context: context,
      builder: (context) => _ActivityDialog(
        day: day,
        activities: activities,
      ),
    );
  }

  void _showHolidayDialog(DateTime day, Holiday holiday) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.celebration, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Festivo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              holiday.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1976d2),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  DateFormat('d \'de\' MMMM \'de\' yyyy', 'es_ES').format(day),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Cerrar', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActivityBarsWidgets(
    BuildContext context,
    List<List<_ActivityBar>> activityBarRows,
    double cellWidth,
    double cellHeight,
    double crossSpacing,
    double mainSpacing,
    int totalCells,
    int startingWeekday,
    int daysInMonth,
    int visibleRows,
  ) {
    final List<Widget> bars = [];
    for (var entry in activityBarRows.asMap().entries) {
      final rowIndex = entry.key;
      final rowBars = entry.value;
      
      for (var bar in rowBars) {
        bars.add(_buildActivityBar(
          context,
          bar,
          rowIndex,
          cellWidth,
          cellHeight,
          crossSpacing,
          mainSpacing,
          totalCells,
          startingWeekday,
          daysInMonth,
          visibleRows,
        ));
      }
    }
    return bars;
  }

  Widget _buildActivityBar(
    BuildContext context,
    _ActivityBar bar,
    int rowIndex,
    double cellWidth,
    double cellHeight,
    double crossSpacing,
    double mainSpacing,
    int totalCells,
    int startingWeekday,
    int daysInMonth,
    int visibleRows,
  ) {
    final color = _getActivityColor(bar.actividad.estado);
    
    // El padding lo aplica el contenedor exterior, no el grid
    // Por lo tanto, las barras deben posicionarse relativo al grid (sin padding adicional)
    
    // Validar que los índices estén dentro del rango válido del grid
    if (bar.startIndex < 0 || bar.startIndex >= totalCells || 
        bar.endIndex < 0 || bar.endIndex >= totalCells) {
      return SizedBox.shrink();
    }
    
    // Validar que los días estén dentro del mes
    final startDay = bar.startIndex - startingWeekday + 1;
    final endDay = bar.endIndex - startingWeekday + 1;
    
    if (startDay < 1 || startDay > daysInMonth || endDay < 1 || endDay > daysInMonth) {
      return SizedBox.shrink();
    }
    
    // NUEVA VALIDACIÓN: Verificar que la fila de la barra esté dentro del área visible
    if (bar.startRow >= visibleRows) {
      return SizedBox.shrink();
    }
    
    // Calcular posición
    final startCol = bar.startIndex % 7;
    final startRow = bar.startRow;
    final endCol = bar.endIndex % 7;
    final endRow = bar.endRow;
    
    // Altura de la barra
    const barHeight = 22.0;
    
    // Calcular posición base - sin padding adicional porque el contenedor ya lo tiene
    final baseLeft = startCol * (cellWidth + crossSpacing);
    final baseTop = startRow * (cellHeight + mainSpacing);
    
    // Si la barra cruza múltiples semanas, dividirla
    if (startRow != endRow) {
      // Por ahora, solo mostrar la primera parte
      final visibleEndCol = 6; // Hasta el final de la semana
      final numCells = visibleEndCol - startCol + 1;
      final width = (numCells * cellWidth) + ((numCells - 1) * crossSpacing);
      
      if (width <= 0 || numCells <= 0) {
        return SizedBox.shrink();
      }
      
      return Positioned(
        key: ValueKey('bar_${bar.actividad.id}_$rowIndex'),
        left: baseLeft,
        top: baseTop + (cellHeight * 0.65) + (rowIndex * (barHeight + 2)),
        width: width,
        child: _buildBarWidget(context, bar.actividad, width, color),
      );
    }
    
    // Barra en una sola semana
    final numCells = endCol - startCol + 1;
    final width = (numCells * cellWidth) + ((numCells - 1) * crossSpacing);
    
    if (width <= 0 || numCells <= 0) {
      return SizedBox.shrink();
    }
    
    return Positioned(
      key: ValueKey('bar_${bar.actividad.id}_$rowIndex'),
      left: baseLeft,
      top: baseTop + (cellHeight * 0.65) + (rowIndex * (barHeight + 2)),
      width: width,
      child: _buildBarWidget(context, bar.actividad, width, color),
    );
  }

  Widget _buildBarWidget(BuildContext context, Actividad actividad, double width, Color color) {
    // Validar ancho mínimo
    if (width < 20) {
      return SizedBox.shrink();
    }
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Navegar al detalle de la actividad
          navigateToActivityDetailInShell(context, {'activity': actividad});
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Container(
            width: width,
            height: 22,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.85),
                  color.withOpacity(0.65),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      actividad.titulo,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Diálogo para mostrar actividades
class _ActivityDialog extends StatelessWidget {
  final DateTime day;
  final List<Actividad> activities;

  const _ActivityDialog({
    required this.day,
    required this.activities,
  });

  Color _getActivityColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'planificada':
        return Color(0xFF2196F3);
      case 'en curso':
        return Color(0xFF4CAF50);
      case 'completada':
        return Color(0xFF9E9E9E);
      case 'cancelada':
        return Color(0xFFF44336);
      default:
        return Color(0xFF1976d2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1976d2).withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(Icons.event, color: Colors.white, size: 28),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actividades',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976d2),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('d \'de\' MMMM', 'es_ES').format(day),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.1),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),
            Divider(thickness: 1),
            SizedBox(height: 16),

            // Lista de actividades
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final actividad = activities[index];
                  return _buildActivityCard(context, actividad);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Actividad actividad) {
    final color = _getActivityColor(actividad.estado);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(context);
            navigateToActivityDetailInShell(context, {'activity': actividad});
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        actividad.titulo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: color,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildChip(
                      actividad.estado,
                      color,
                      Icons.info_outline,
                    ),
                    if (actividad.tipo.isNotEmpty)
                      _buildChip(
                        actividad.tipo,
                        Colors.grey,
                        Icons.category_outlined,
                      ),
                  ],
                ),
                if (actividad.descripcion != null && actividad.descripcion!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    actividad.descripcion!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Clase auxiliar para representar una barra de actividad
class _ActivityBar {
  final Actividad actividad;
  final int startIndex;
  final int endIndex;
  final int startRow;
  final int endRow;

  _ActivityBar({
    required this.actividad,
    required this.startIndex,
    required this.endIndex,
    required this.startRow,
    required this.endRow,
  });
}
