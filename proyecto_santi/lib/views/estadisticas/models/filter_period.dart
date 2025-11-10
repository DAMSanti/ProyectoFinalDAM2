/// Modelo para representar períodos de filtrado
enum FilterPeriodType {
  custom,
  last30Days,
  last90Days,
  currentMonth,
  currentYear,
  academicYear,
  quarter,
}

class FilterPeriod {
  final FilterPeriodType type;
  final DateTime startDate;
  final DateTime endDate;
  final String label;

  FilterPeriod({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.label,
  });

  factory FilterPeriod.custom(DateTime start, DateTime end) {
    return FilterPeriod(
      type: FilterPeriodType.custom,
      startDate: start,
      endDate: end,
      label: 'Personalizado',
    );
  }

  factory FilterPeriod.last30Days() {
    final now = DateTime.now();
    return FilterPeriod(
      type: FilterPeriodType.last30Days,
      startDate: now.subtract(Duration(days: 30)),
      endDate: now,
      label: 'Últimos 30 días',
    );
  }

  factory FilterPeriod.last90Days() {
    final now = DateTime.now();
    return FilterPeriod(
      type: FilterPeriodType.last90Days,
      startDate: now.subtract(Duration(days: 90)),
      endDate: now,
      label: 'Últimos 90 días',
    );
  }

  factory FilterPeriod.currentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return FilterPeriod(
      type: FilterPeriodType.currentMonth,
      startDate: startOfMonth,
      endDate: endOfMonth,
      label: 'Mes actual',
    );
  }

  factory FilterPeriod.currentYear() {
    final now = DateTime.now();
    return FilterPeriod(
      type: FilterPeriodType.currentYear,
      startDate: DateTime(now.year, 1, 1),
      endDate: DateTime(now.year, 12, 31),
      label: 'Año actual',
    );
  }

  factory FilterPeriod.academicYear() {
    final now = DateTime.now();
    // El año académico va de septiembre a junio del siguiente año
    final year = now.month >= 9 ? now.year : now.year - 1;
    return FilterPeriod(
      type: FilterPeriodType.academicYear,
      startDate: DateTime(year, 9, 1),
      endDate: DateTime(year + 1, 6, 30),
      label: 'Año académico ${year}/${year + 1}',
    );
  }

  factory FilterPeriod.quarter([int? quarter, int? year]) {
    final now = DateTime.now();
    final currentYear = year ?? now.year;
    final currentQuarter = quarter ?? ((now.month - 1) ~/ 3) + 1;
    final startMonth = (currentQuarter - 1) * 3 + 1;
    final endMonth = currentQuarter * 3;
    return FilterPeriod(
      type: FilterPeriodType.quarter,
      startDate: DateTime(currentYear, startMonth, 1),
      endDate: DateTime(currentYear, endMonth + 1, 0),
      label: 'Q$currentQuarter $currentYear',
    );
  }

  /// Obtiene el período anterior del mismo tipo para comparación de tendencias
  FilterPeriod getPreviousPeriod() {
    switch (type) {
      case FilterPeriodType.last30Days:
        return FilterPeriod(
          type: type,
          startDate: startDate.subtract(Duration(days: 30)),
          endDate: endDate.subtract(Duration(days: 30)),
          label: 'Período anterior',
        );
      case FilterPeriodType.last90Days:
        return FilterPeriod(
          type: type,
          startDate: startDate.subtract(Duration(days: 90)),
          endDate: endDate.subtract(Duration(days: 90)),
          label: 'Período anterior',
        );
      case FilterPeriodType.currentMonth:
        final prevMonth = DateTime(startDate.year, startDate.month - 1, 1);
        return FilterPeriod(
          type: type,
          startDate: prevMonth,
          endDate: DateTime(prevMonth.year, prevMonth.month + 1, 0),
          label: 'Mes anterior',
        );
      case FilterPeriodType.currentYear:
        return FilterPeriod(
          type: type,
          startDate: DateTime(startDate.year - 1, 1, 1),
          endDate: DateTime(startDate.year - 1, 12, 31),
          label: 'Año anterior',
        );
      case FilterPeriodType.academicYear:
        return FilterPeriod(
          type: type,
          startDate: DateTime(startDate.year - 1, 9, 1),
          endDate: DateTime(startDate.year, 6, 30),
          label: 'Año académico anterior',
        );
      case FilterPeriodType.quarter:
        // Trimestre anterior
        final prevQuarterStart = DateTime(startDate.year, startDate.month - 3, 1);
        return FilterPeriod(
          type: type,
          startDate: prevQuarterStart,
          endDate: DateTime(prevQuarterStart.year, prevQuarterStart.month + 3, 0),
          label: 'Trimestre anterior',
        );
      case FilterPeriodType.custom:
        // Para personalizado, usar el mismo rango de días pero desplazado atrás
        final duration = endDate.difference(startDate);
        return FilterPeriod(
          type: type,
          startDate: startDate.subtract(duration),
          endDate: startDate,
          label: 'Período anterior',
        );
    }
  }
}
