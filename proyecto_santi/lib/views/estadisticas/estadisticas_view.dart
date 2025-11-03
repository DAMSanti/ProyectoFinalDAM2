import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/tema/tema.dart';

class EstadisticasView extends StatefulWidget {
  const EstadisticasView({Key? key}) : super(key: key);

  @override
  State<EstadisticasView> createState() => _EstadisticasViewState();
}

class _EstadisticasViewState extends State<EstadisticasView> {
  final ApiService _apiService = ApiService();
  late final ActividadService _actividadService;
  
  List<Actividad> _actividades = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _actividadService = ActividadService(_apiService);
    _loadActividades();
  }

  Future<void> _loadActividades() async {
    setState(() => _isLoading = true);
    
    try {
      final actividades = await _actividadService.fetchActivities(pageSize: 100);
      setState(() {
        _actividades = actividades;
        _isLoading = false;
      });
    } catch (e) {
      print('[ERROR] Error al cargar actividades: $e');
      setState(() => _isLoading = false);
    }
  }

  Map<String, int> _getActividadesPorEstado() {
    final Map<String, int> estadoCounts = {};
    for (var actividad in _actividades) {
      estadoCounts[actividad.estado] = (estadoCounts[actividad.estado] ?? 0) + 1;
    }
    return estadoCounts;
  }

  Map<String, int> _getActividadesPorTipo() {
    final Map<String, int> tipoCounts = {};
    for (var actividad in _actividades) {
      tipoCounts[actividad.tipo] = (tipoCounts[actividad.tipo] ?? 0) + 1;
    }
    return tipoCounts;
  }

  Map<String, int> _getActividadesPorDepartamento() {
    final Map<String, int> deptoCounts = {};
    for (var actividad in _actividades) {
      final deptoNombre = actividad.responsable != null 
          ? '${actividad.responsable!.nombre} ${actividad.responsable!.apellidos}'
          : 'Sin Responsable';
      deptoCounts[deptoNombre] = (deptoCounts[deptoNombre] ?? 0) + 1;
    }
    return deptoCounts;
  }

  Map<String, int> _getActividadesPorMes() {
    final Map<String, int> mesCounts = {};
    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    
    for (var actividad in _actividades) {
      try {
        final fecha = DateTime.parse(actividad.fini);
        final mesNombre = meses[fecha.month - 1];
        mesCounts[mesNombre] = (mesCounts[mesNombre] ?? 0) + 1;
      } catch (e) {
        print('[ERROR] Error al parsear fecha: $e');
      }
    }
    return mesCounts;
  }

  double _getTotalPresupuesto() {
    return _actividades.fold(0.0, (sum, act) => sum + (act.presupuestoEstimado ?? 0.0));
  }

  double _getTotalCostoReal() {
    return _actividades.fold(0.0, (sum, act) => sum + (act.costoReal ?? 0.0));
  }

  int _getActividadesConTransporte() {
    return _actividades.where((act) => act.transporteReq == 1).length;
  }

  int _getActividadesConAlojamiento() {
    return _actividades.where((act) => act.alojamientoReq == 1).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Stack(
      children: [
        // Fondo con degradado
        isDark 
          ? GradientBackgroundDark(child: Container()) 
          : GradientBackgroundLight(child: Container()),
        // Contenido
        Scaffold(
          backgroundColor: Colors.transparent,
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Espaciado superior
                      SizedBox(height: isMobile ? 16 : 24),
                      
                      // Cards de estadísticas generales
                      _buildGeneralStats(isMobile, isDark),
                      SizedBox(height: isMobile ? 16 : 24),
                      
                      // Gráficas en dos columnas o una
                      if (MediaQuery.of(context).size.width > 800) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildActividadesPorEstadoChart(isMobile, isDark)),
                            SizedBox(width: 16),
                            Expanded(child: _buildActividadesPorTipoChart(isMobile, isDark)),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildActividadesPorDepartamentoChart(isMobile, isDark)),
                            SizedBox(width: 16),
                            Expanded(child: _buildActividadesPorMesChart(isMobile, isDark)),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildPresupuestoChart(isMobile, isDark),
                      ] else ...[
                        _buildActividadesPorEstadoChart(isMobile, isDark),
                        SizedBox(height: 16),
                        _buildActividadesPorTipoChart(isMobile, isDark),
                        SizedBox(height: 16),
                        _buildActividadesPorDepartamentoChart(isMobile, isDark),
                        SizedBox(height: 16),
                        _buildActividadesPorMesChart(isMobile, isDark),
                        SizedBox(height: 16),
                        _buildPresupuestoChart(isMobile, isDark),
                      ],
                      
                      // Espaciado final
                      SizedBox(height: isMobile ? 80 : 40),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildGeneralStats(bool isMobile, bool isDark) {
    final totalActividades = _actividades.length;
    final totalPresupuesto = _getTotalPresupuesto();
    final totalCostoReal = _getTotalCostoReal();
    final conTransporte = _getActividadesConTransporte();
    final conAlojamiento = _getActividadesConAlojamiento();

    final stats = [
      _StatData('Total Actividades', totalActividades.toString(), Icons.event_rounded, AppColors.primary),
      _StatData('Presupuesto Total', '€${totalPresupuesto.toStringAsFixed(0)}', Icons.euro_rounded, AppColors.estadoAprobado),
      _StatData('Costo Real', '€${totalCostoReal.toStringAsFixed(0)}', Icons.euro_symbol_rounded, AppColors.estadoRechazado),
      _StatData('Con Transporte', conTransporte.toString(), Icons.directions_bus_rounded, AppColors.presupuestoTransporte),
      _StatData('Con Alojamiento', conAlojamiento.toString(), Icons.hotel_rounded, AppColors.presupuestoAlojamiento),
    ];

    if (isMobile) {
      return Column(
        children: stats.map((stat) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _buildModernStatCard(stat, isMobile, isDark),
        )).toList(),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats.map((stat) => SizedBox(
        width: (MediaQuery.of(context).size.width - 64) / 3,
        child: _buildModernStatCard(stat, isMobile, isDark),
      )).toList(),
    );
  }

  Widget _buildModernStatCard(_StatData stat, bool isMobile, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: stat.color.withValues(alpha: 0.1),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        stat.color,
                        stat.color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: stat.color.withValues(alpha: 0.3),
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    stat.icon,
                    color: Colors.white,
                    size: isMobile ? 24 : 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.value,
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: stat.color,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        stat.title,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: isDark 
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.black.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActividadesPorEstadoChart(bool isMobile, bool isDark) {
    final data = _getActividadesPorEstado();
    if (data.isEmpty) return SizedBox.shrink();

    final colors = [
      AppColors.estadoAprobado,
      AppColors.estadoPendiente,
      AppColors.estadoRechazado,
      AppColors.primary,
      AppColors.presupuestoAlojamiento,
    ];

    int colorIndex = 0;
    final sections = data.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        color: color,
        radius: isMobile ? 45 : 55,
        titleStyle: TextStyle(
          fontSize: isMobile ? 12 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Actividades por Estado',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          SizedBox(
            height: isMobile ? 220 : 260,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: isMobile ? 35 : 45,
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.entries.toList().asMap().entries.map((mapEntry) {
                      final index = mapEntry.key;
                      final entry = mapEntry.value;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colors[index % colors.length].withValues(alpha: 0.4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadesPorTipoChart(bool isMobile, bool isDark) {
    final data = _getActividadesPorTipo();
    if (data.isEmpty) return SizedBox.shrink();

    final maxValue = data.values.reduce((a, b) => a > b ? a : b).toDouble();

    return _buildChartContainer(
      title: 'Actividades por Tipo',
      icon: Icons.category_rounded,
      isMobile: isMobile,
      isDark: isDark,
      child: SizedBox(
        height: isMobile ? 220 : 260,
        child: BarChart(
          BarChartData(
            maxY: maxValue + 2,
            barGroups: data.entries.toList().asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value.toDouble(),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: isMobile ? 14 : 18,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true, 
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < data.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          data.keys.toList()[value.toInt()],
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      );
                    }
                    return Text('');
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true, 
              horizontalInterval: 1,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.1) 
                      : Colors.black.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartContainer({
    required String title,
    required IconData icon,
    required bool isMobile,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isMobile ? 20 : 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          child,
        ],
      ),
    );
  }

  Widget _buildActividadesPorDepartamentoChart(bool isMobile, bool isDark) {
    final data = _getActividadesPorDepartamento();
    if (data.isEmpty) return SizedBox.shrink();

    final maxValue = data.values.reduce((a, b) => a > b ? a : b).toDouble();

    return _buildChartContainer(
      title: 'Actividades por Departamento',
      icon: Icons.business_rounded,
      isMobile: isMobile,
      isDark: isDark,
      child: SizedBox(
        height: isMobile ? 220 : 260,
        child: BarChart(
          BarChartData(
            maxY: maxValue + 2,
            barGroups: data.entries.toList().asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value.toDouble(),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.estadoAprobado,
                        AppColors.estadoAprobado.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: isMobile ? 14 : 18,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true, 
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < data.length) {
                      final departamento = data.keys.toList()[value.toInt()];
                      final shortName = departamento.length > 8 
                          ? '${departamento.substring(0, 6)}...' 
                          : departamento;
                      return Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          shortName,
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 11,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      );
                    }
                    return Text('');
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true, 
              horizontalInterval: 1,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.1) 
                      : Colors.black.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActividadesPorMesChart(bool isMobile, bool isDark) {
    final data = _getActividadesPorMes();
    if (data.isEmpty) return SizedBox.shrink();

    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final maxValue = data.values.isNotEmpty 
        ? data.values.reduce((a, b) => a > b ? a : b).toDouble() 
        : 10.0;

    return _buildChartContainer(
      title: 'Actividades por Mes',
      icon: Icons.calendar_month_rounded,
      isMobile: isMobile,
      isDark: isDark,
      child: SizedBox(
        height: isMobile ? 220 : 260,
        child: BarChart(
          BarChartData(
            maxY: maxValue + 2,
            barGroups: meses.asMap().entries.map((entry) {
              final mes = entry.value;
              final count = data[mes] ?? 0;
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: count.toDouble(),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.presupuestoTransporte,
                        AppColors.presupuestoTransporte.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: isMobile ? 10 : 14,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true, 
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < meses.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          meses[value.toInt()],
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 11,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      );
                    }
                    return Text('');
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true, 
              horizontalInterval: 1,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.1) 
                      : Colors.black.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresupuestoChart(bool isMobile, bool isDark) {
    if (_actividades.isEmpty) return SizedBox.shrink();

    final actividades = _actividades.where((a) => 
      a.presupuestoEstimado != null || a.costoReal != null
    ).toList();

    if (actividades.isEmpty) return SizedBox.shrink();

    return _buildChartContainer(
      title: 'Presupuesto vs Costo Real',
      icon: Icons.trending_up_rounded,
      isMobile: isMobile,
      isDark: isDark,
      child: Column(
        children: [
          SizedBox(
            height: isMobile ? 240 : 300,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  // Línea de Presupuesto Estimado
                  LineChartBarData(
                    spots: actividades.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.presupuestoEstimado ?? 0.0,
                      );
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Línea de Costo Real
                  LineChartBarData(
                    spots: actividades.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.costoReal ?? 0.0,
                      );
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.estadoRechazado,
                        AppColors.estadoRechazado.withValues(alpha: 0.7),
                      ],
                    ),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.estadoRechazado,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '€${value.toInt()}',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < actividades.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'A${actividades[value.toInt()].id}',
                              style: TextStyle(
                                fontSize: isMobile ? 9 : 11,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.1) 
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.1) 
                          : Colors.black.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Presupuesto Estimado', AppColors.primary, isMobile, isDark),
              SizedBox(width: 24),
              _buildLegendItem('Costo Real', AppColors.estadoRechazado, isMobile, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isMobile, bool isDark) {
    return Row(
      children: [
        Container(
          width: isMobile ? 14 : 16,
          height: isMobile ? 14 : 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
          ),
        ),
      ],
    );
  }
}

// Clase helper para datos de estadísticas
class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatData(this.title, this.value, this.icon, this.color);
}
