import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';

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
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Estadísticas de Actividades',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976d2),
                          ),
                        ),
                      ),
                      
                      // Cards de estadísticas generales
                      _buildGeneralStats(),
                      SizedBox(height: 16),
                      
                      // Gráficas en dos columnas
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildActividadesPorEstadoChart()),
                                    SizedBox(width: 16),
                                    Expanded(child: _buildActividadesPorTipoChart()),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildActividadesPorDepartamentoChart()),
                                    SizedBox(width: 16),
                                    Expanded(child: _buildActividadesPorMesChart()),
                                  ],
                                ),
                                SizedBox(height: 16),
                                _buildPresupuestoChart(),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                _buildActividadesPorEstadoChart(),
                                SizedBox(height: 16),
                                _buildActividadesPorTipoChart(),
                                SizedBox(height: 16),
                                _buildActividadesPorDepartamentoChart(),
                                SizedBox(height: 16),
                                _buildActividadesPorMesChart(),
                                SizedBox(height: 16),
                                _buildPresupuestoChart(),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildGeneralStats() {
    final totalActividades = _actividades.length;
    final totalPresupuesto = _getTotalPresupuesto();
    final totalCostoReal = _getTotalCostoReal();
    final conTransporte = _getActividadesConTransporte();
    final conAlojamiento = _getActividadesConAlojamiento();

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Actividades', totalActividades.toString(), Icons.event, Colors.blue)),
            SizedBox(width: 8),
            Expanded(child: _buildStatCard('Presupuesto Total', '${totalPresupuesto.toStringAsFixed(2)}€', Icons.euro, Colors.green)),
            SizedBox(width: 8),
            Expanded(child: _buildStatCard('Costo Real Total', '${totalCostoReal.toStringAsFixed(2)}€', Icons.euro_symbol, Colors.red)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildStatCard('Con Transporte', conTransporte.toString(), Icons.directions_bus, Colors.orange)),
            SizedBox(width: 8),
            Expanded(child: _buildStatCard('Con Alojamiento', conAlojamiento.toString(), Icons.hotel, Colors.purple)),
            SizedBox(width: 8),
            Expanded(child: SizedBox.shrink()), // Espaciador vacío
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActividadesPorEstadoChart() {
    final data = _getActividadesPorEstado();
    if (data.isEmpty) return SizedBox.shrink();

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];

    int colorIndex = 0;
    final sections = data.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        color: color,
        radius: 50,
        titleStyle: TextStyle(
          fontSize: kIsWeb ? 3.sp : 12.dg,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: EdgeInsets.all(kIsWeb ? 4.sp : 16.dg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividades por Estado',
            style: TextStyle(
              fontSize: kIsWeb ? 5.sp : 18.dg,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976d2),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
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
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(fontSize: kIsWeb ? 3.sp : 11.dg),
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

  Widget _buildActividadesPorTipoChart() {
    final data = _getActividadesPorTipo();
    if (data.isEmpty) return SizedBox.shrink();

    final maxValue = data.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: EdgeInsets.all(kIsWeb ? 4.sp : 16.dg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividades por Tipo',
            style: TextStyle(
              fontSize: kIsWeb ? 5.sp : 18.dg,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976d2),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                maxY: maxValue + 2,
                barGroups: data.entries.toList().asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        color: Colors.blue,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
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
                              style: TextStyle(fontSize: kIsWeb ? 2.5.sp : 10.dg),
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
                gridData: FlGridData(show: true, horizontalInterval: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadesPorDepartamentoChart() {
    final data = _getActividadesPorDepartamento();
    if (data.isEmpty) return SizedBox.shrink();

    final maxValue = data.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: EdgeInsets.all(kIsWeb ? 4.sp : 16.dg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividades por Departamento',
            style: TextStyle(
              fontSize: kIsWeb ? 5.sp : 18.dg,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976d2),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                maxY: maxValue + 2,
                barGroups: data.entries.toList().asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        color: Colors.green,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          final departamento = data.keys.toList()[value.toInt()];
                          // Truncar nombre largo
                          final shortName = departamento.length > 8 
                              ? '${departamento.substring(0, 6)}...' 
                              : departamento;
                          return Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              shortName,
                              style: TextStyle(fontSize: kIsWeb ? 2.5.sp : 10.dg),
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
                gridData: FlGridData(show: true, horizontalInterval: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadesPorMesChart() {
    final data = _getActividadesPorMes();
    if (data.isEmpty) return SizedBox.shrink();

    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final maxValue = data.values.isNotEmpty 
        ? data.values.reduce((a, b) => a > b ? a : b).toDouble() 
        : 10.0;

    return Container(
      padding: EdgeInsets.all(kIsWeb ? 4.sp : 16.dg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividades por Mes',
            style: TextStyle(
              fontSize: kIsWeb ? 5.sp : 18.dg,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976d2),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 250,
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
                        color: Colors.orange,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
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
                              style: TextStyle(fontSize: kIsWeb ? 2.5.sp : 10.dg),
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
                gridData: FlGridData(show: true, horizontalInterval: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresupuestoChart() {
    if (_actividades.isEmpty) return SizedBox.shrink();

    final actividades = _actividades.where((a) => 
      a.presupuestoEstimado != null || a.costoReal != null
    ).toList();

    if (actividades.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(kIsWeb ? 4.sp : 16.dg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Presupuesto vs Costo Real',
            style: TextStyle(
              fontSize: kIsWeb ? 5.sp : 18.dg,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976d2),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 300,
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
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
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
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}€',
                          style: TextStyle(fontSize: kIsWeb ? 2.5.sp : 10.dg),
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
                              style: TextStyle(fontSize: kIsWeb ? 2.5.sp : 10.dg),
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
                borderData: FlBorderData(show: true),
                gridData: FlGridData(show: true),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Presupuesto Estimado', Colors.blue),
              SizedBox(width: 24),
              _buildLegendItem('Costo Real', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: kIsWeb ? 3.sp : 12.dg),
        ),
      ],
    );
  }
}
