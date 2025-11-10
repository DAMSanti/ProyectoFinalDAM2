import 'package:flutter/material.dart';

enum ChartType {
  actividadesPorEstado,
  actividadesPorTipo,
  actividadesPorDepartamento,
  actividadesPorMes,
  presupuestoVsCosto,
  tendencias,
}

class ChartItem {
  final ChartType type;
  final String title;
  final String description;
  final IconData icon;
  bool isSelected;
  int order;

  ChartItem({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.isSelected = false,
    this.order = 0,
  });

  ChartItem copyWith({
    ChartType? type,
    String? title,
    String? description,
    IconData? icon,
    bool? isSelected,
    int? order,
  }) {
    return ChartItem(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
      order: order ?? this.order,
    );
  }

  static List<ChartItem> getDefaultCharts() {
    return [
      ChartItem(
        type: ChartType.tendencias,
        title: 'Tendencias',
        description: 'Resumen con indicadores de cambio',
        icon: Icons.trending_up,
      ),
      ChartItem(
        type: ChartType.actividadesPorEstado,
        title: 'Actividades por Estado',
        description: 'Distribución según estado (Aprobado, Pendiente, Rechazado)',
        icon: Icons.pie_chart_rounded,
      ),
      ChartItem(
        type: ChartType.actividadesPorTipo,
        title: 'Actividades por Tipo',
        description: 'Comparación entre tipos de actividades',
        icon: Icons.category_rounded,
      ),
      ChartItem(
        type: ChartType.actividadesPorDepartamento,
        title: 'Actividades por Departamento',
        description: 'Distribución por responsable/departamento',
        icon: Icons.business_rounded,
      ),
      ChartItem(
        type: ChartType.actividadesPorMes,
        title: 'Actividades por Mes',
        description: 'Evolución temporal mensual',
        icon: Icons.calendar_month_rounded,
      ),
      ChartItem(
        type: ChartType.presupuestoVsCosto,
        title: 'Presupuesto vs Costo Real',
        description: 'Comparación de presupuesto planificado y costo ejecutado',
        icon: Icons.attach_money_rounded,
      ),
    ];
  }
}
