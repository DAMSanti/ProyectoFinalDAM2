import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/app_colors.dart';
import 'package:proyecto_santi/views/estadisticas/models/filter_period.dart';

class FilterBar extends StatelessWidget {
  final FilterPeriod currentPeriod;
  final ValueChanged<FilterPeriod> onPeriodChanged;
  final VoidCallback onCustomDateRange;
  final bool isDark;
  final bool isMobile;

  const FilterBar({
    Key? key,
    required this.currentPeriod,
    required this.onPeriodChanged,
    required this.onCustomDateRange,
    required this.isDark,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileFilterBar(context);
    }
    return _buildDesktopFilterBar(context);
  }

  Widget _buildDesktopFilterBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.04),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.85),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            'Filtros:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(context, 'Últimos 30 días', FilterPeriod.last30Days()),
                _buildFilterChip(context, 'Últimos 90 días', FilterPeriod.last90Days()),
                _buildFilterChip(context, 'Mes actual', FilterPeriod.currentMonth()),
                _buildFilterChip(context, 'Año actual', FilterPeriod.currentYear()),
                _buildFilterChip(context, 'Año académico', FilterPeriod.academicYear()),
                _buildCustomRangeChip(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFilterBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.04),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.85),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Período:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildFilterChip(context, '30d', FilterPeriod.last30Days(), compact: true),
              _buildFilterChip(context, '90d', FilterPeriod.last90Days(), compact: true),
              _buildFilterChip(context, 'Mes', FilterPeriod.currentMonth(), compact: true),
              _buildFilterChip(context, 'Año', FilterPeriod.currentYear(), compact: true),
              _buildFilterChip(context, 'Acad.', FilterPeriod.academicYear(), compact: true),
              _buildCustomRangeChip(context, compact: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, FilterPeriod period, {bool compact = false}) {
    final isSelected = currentPeriod.type == period.type;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPeriodChanged(period),
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: AppColors.primaryGradient,
                  )
                : null,
            color: isSelected ? null : (isDark 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
            border: Border.all(
              color: isSelected 
                  ? Colors.transparent 
                  : (isDark 
                      ? Colors.white.withValues(alpha: 0.1) 
                      : Colors.black.withValues(alpha: 0.1)),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRangeChip(BuildContext context, {bool compact = false}) {
    final isSelected = currentPeriod.type == FilterPeriodType.custom;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCustomDateRange,
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: AppColors.primaryGradient,
                  )
                : null,
            color: isSelected ? null : (isDark 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
            border: Border.all(
              color: isSelected 
                  ? Colors.transparent 
                  : (isDark 
                      ? Colors.white.withValues(alpha: 0.1) 
                      : Colors.black.withValues(alpha: 0.1)),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: compact ? 14 : 16,
                color: isSelected 
                    ? Colors.white 
                    : AppColors.primary,
              ),
              SizedBox(width: compact ? 4 : 6),
              Text(
                compact ? 'Pers.' : 'Personalizado',
                style: TextStyle(
                  fontSize: compact ? 12 : 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected 
                      ? Colors.white 
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
