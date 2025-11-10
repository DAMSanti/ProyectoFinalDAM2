import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/tema/tema.dart';
import 'package:proyecto_santi/views/estadisticas/models/filter_period.dart';
import 'package:proyecto_santi/views/estadisticas/models/trend_data.dart';
import 'package:proyecto_santi/views/estadisticas/models/chart_item.dart';
import 'package:proyecto_santi/views/estadisticas/widgets/filter_bar.dart';
import 'package:proyecto_santi/views/estadisticas/widgets/trend_stat_card.dart';
import 'package:proyecto_santi/views/estadisticas/views/pdf_editor_view.dart';
import 'package:proyecto_santi/views/estadisticas/services/pdf_export_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EstadisticasView extends StatefulWidget {
  const EstadisticasView({Key? key}) : super(key: key);

  @override
  State<EstadisticasView> createState() => _EstadisticasViewState();
}

class _EstadisticasViewState extends State<EstadisticasView> {
  final ApiService _apiService = ApiService();
  late final ActividadService _actividadService;
  
  List<Actividad> _actividades = [];
  List<Actividad> _actividadesFiltradas = [];
  List<Actividad> _actividadesPeriodoAnterior = [];
  bool _isLoading = false;
  bool _showFilters = false; // Filtros colapsados por defecto
  
  // Global keys para capturar widgets de gráficas
  final Map<ChartType, GlobalKey> _chartKeys = {
    ChartType.tendencias: GlobalKey(),
    ChartType.actividadesPorEstado: GlobalKey(),
    ChartType.actividadesPorTipo: GlobalKey(),
    ChartType.actividadesPorDepartamento: GlobalKey(),
    ChartType.actividadesPorMes: GlobalKey(),
    ChartType.presupuestoVsCosto: GlobalKey(),
  };
  
  // Filtros
  FilterPeriod _currentPeriod = FilterPeriod.currentMonth();

  @override
  void initState() {
    super.initState();
    _actividadService = ActividadService(_apiService);
    _loadSavedFilter();
    _loadActividades();
  }

  // Cargar filtro guardado
  Future<void> _loadSavedFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFilterType = prefs.getString('stats_filter_type');
    
    if (savedFilterType != null) {
      try {
        final filterType = FilterPeriodType.values.firstWhere(
          (e) => e.toString() == savedFilterType,
          orElse: () => FilterPeriodType.currentMonth,
        );
        
        // Si es custom, cargar fechas guardadas
        if (filterType == FilterPeriodType.custom) {
          final startStr = prefs.getString('stats_filter_start');
          final endStr = prefs.getString('stats_filter_end');
          if (startStr != null && endStr != null) {
            _currentPeriod = FilterPeriod.custom(
              DateTime.parse(startStr),
              DateTime.parse(endStr),
            );
          }
        } else {
          // Usar el factory correspondiente
          switch (filterType) {
            case FilterPeriodType.last30Days:
              _currentPeriod = FilterPeriod.last30Days();
              break;
            case FilterPeriodType.last90Days:
              _currentPeriod = FilterPeriod.last90Days();
              break;
            case FilterPeriodType.currentMonth:
              _currentPeriod = FilterPeriod.currentMonth();
              break;
            case FilterPeriodType.currentYear:
              _currentPeriod = FilterPeriod.currentYear();
              break;
            case FilterPeriodType.academicYear:
              _currentPeriod = FilterPeriod.academicYear();
              break;
            case FilterPeriodType.quarter:
              _currentPeriod = FilterPeriod.quarter();
              break;
            default:
              _currentPeriod = FilterPeriod.currentMonth();
          }
        }
      } catch (e) {
        print('[ERROR] Error al cargar filtro guardado: $e');
        _currentPeriod = FilterPeriod.currentMonth();
      }
    }
  }

  // Guardar filtro seleccionado
  Future<void> _saveFilter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stats_filter_type', _currentPeriod.type.toString());
    
    if (_currentPeriod.type == FilterPeriodType.custom) {
      await prefs.setString('stats_filter_start', _currentPeriod.startDate.toIso8601String());
      await prefs.setString('stats_filter_end', _currentPeriod.endDate.toIso8601String());
    }
  }

  Future<void> _loadActividades() async {
    setState(() => _isLoading = true);
    
    try {
      final actividades = await _actividadService.fetchActivities(pageSize: 100);
      setState(() {
        _actividades = actividades;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      print('[ERROR] Error al cargar actividades: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    // Filtrar actividades del período actual
    _actividadesFiltradas = _actividades.where((actividad) {
      try {
        final fecha = DateTime.parse(actividad.fini);
        return fecha.isAfter(_currentPeriod.startDate) && 
               fecha.isBefore(_currentPeriod.endDate.add(Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();

    // Filtrar actividades del período anterior para comparación
    final previousPeriod = _currentPeriod.getPreviousPeriod();
    _actividadesPeriodoAnterior = _actividades.where((actividad) {
      try {
        final fecha = DateTime.parse(actividad.fini);
        return fecha.isAfter(previousPeriod.startDate) && 
               fecha.isBefore(previousPeriod.endDate.add(Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  void _changePeriod(FilterPeriod newPeriod) {
    setState(() {
      _currentPeriod = newPeriod;
      _applyFilters();
    });
    _saveFilter(); // Guardar automáticamente
  }

  void _openPdfEditor() {
    showDialog(
      context: context,
      builder: (context) => PdfEditorView(
        onGeneratePdf: (selectedCharts) {
          PdfExportService.generateAndExport(
            context: context,
            charts: selectedCharts,
            filterPeriod: _currentPeriod,
            chartKeys: _chartKeys,
          );
        },
      ),
    );
  }

  void _showCustomDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: _currentPeriod.startDate,
        end: _currentPeriod.endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _changePeriod(FilterPeriod.custom(picked.start, picked.end));
    }
  }

  Map<String, int> _getActividadesPorEstado() {
    final Map<String, int> estadoCounts = {};
    for (var actividad in _actividadesFiltradas) {
      estadoCounts[actividad.estado] = (estadoCounts[actividad.estado] ?? 0) + 1;
    }
    return estadoCounts;
  }

  Map<String, int> _getActividadesPorTipo() {
    final Map<String, int> tipoCounts = {};
    for (var actividad in _actividadesFiltradas) {
      tipoCounts[actividad.tipo] = (tipoCounts[actividad.tipo] ?? 0) + 1;
    }
    return tipoCounts;
  }

  Map<String, int> _getActividadesPorDepartamento() {
    final Map<String, int> deptoCounts = {};
    for (var actividad in _actividadesFiltradas) {
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
    
    for (var actividad in _actividadesFiltradas) {
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
    return _actividadesFiltradas.fold(0.0, (sum, act) => sum + (act.presupuestoEstimado ?? 0.0));
  }

  double _getTotalCostoReal() {
    return _actividadesFiltradas.fold(0.0, (sum, act) => sum + (act.costoReal ?? 0.0));
  }

  int _getActividadesConTransporte() {
    return _actividadesFiltradas.where((act) => act.transporteReq == 1).length;
  }

  int _getActividadesConAlojamiento() {
    return _actividadesFiltradas.where((act) => act.alojamientoReq == 1).length;
  }

  // Métodos para cálculos del período anterior
  double _getTotalPresupuestoPrevio() {
    return _actividadesPeriodoAnterior.fold(0.0, (sum, act) => sum + (act.presupuestoEstimado ?? 0.0));
  }

  double _getTotalCostoRealPrevio() {
    return _actividadesPeriodoAnterior.fold(0.0, (sum, act) => sum + (act.costoReal ?? 0.0));
  }

  int _getActividadesConTransportePrevio() {
    return _actividadesPeriodoAnterior.where((act) => act.transporteReq == 1).length;
  }

  int _getActividadesConAlojamientoPrevio() {
    return _actividadesPeriodoAnterior.where((act) => act.alojamientoReq == 1).length;
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
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Espaciado superior compacto
                      SizedBox(height: isMobile ? 8 : 12),
                      
                      // Botones superiores: Filtro Global y Exportar PDF
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 4),
                        child: Row(
                          children: [
                            // Botón de Filtros Globales (estilo similar a activities)
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [Color(0xFF1976d2), Color(0xFF1565c0)]
                                            : [Color(0xFF1976d2), Color(0xFF2196f3)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF1976d2).withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          setState(() => _showFilters = !_showFilters);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isMobile ? 16 : 20,
                                            vertical: isMobile ? 12 : 14,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _showFilters ? Icons.filter_alt_off_rounded : Icons.tune_rounded,
                                                color: Colors.white,
                                                size: isMobile ? 20 : 22,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                _showFilters ? 'Ocultar Filtros' : 'Filtros Globales',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isMobile ? 14 : 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Indicador si hay filtros activos
                                  if (_currentPeriod.type != FilterPeriodType.currentMonth)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isDark ? Colors.black : Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                            SizedBox(width: 12),
                            
                            // Botón de Exportar PDF (solo icono)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.estadoAprobado,
                                    AppColors.estadoAprobado.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.estadoAprobado.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: _openPdfEditor,
                                  child: Container(
                                    padding: EdgeInsets.all(isMobile ? 12 : 14),
                                    child: Icon(
                                      Icons.picture_as_pdf_rounded,
                                      color: Colors.white,
                                      size: isMobile ? 20 : 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Barra de filtros globales colapsable
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: _showFilters ? null : 0,
                        child: _showFilters
                            ? Column(
                                children: [
                                  FilterBar(
                                    currentPeriod: _currentPeriod,
                                    onPeriodChanged: _changePeriod,
                                    onCustomDateRange: _showCustomDateRangePicker,
                                    isDark: isDark,
                                    isMobile: isMobile,
                                  ),
                                  SizedBox(height: 12),
                                ],
                              )
                            : SizedBox.shrink(),
                      ),
                      
                      // Cards de estadísticas generales con tendencias (más compacto)
                      RepaintBoundary(
                        key: _chartKeys[ChartType.tendencias],
                        child: _buildTrendStats(isMobile, isDark),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      
                      // Gráficas en dos columnas o una
                      if (MediaQuery.of(context).size.width > 800) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: RepaintBoundary(
                                key: _chartKeys[ChartType.actividadesPorEstado],
                                child: _buildActividadesPorEstadoChart(isMobile, isDark),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: RepaintBoundary(
                                key: _chartKeys[ChartType.actividadesPorTipo],
                                child: _buildActividadesPorTipoChart(isMobile, isDark),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: RepaintBoundary(
                                key: _chartKeys[ChartType.actividadesPorDepartamento],
                                child: _buildActividadesPorDepartamentoChart(isMobile, isDark),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: RepaintBoundary(
                                key: _chartKeys[ChartType.actividadesPorMes],
                                child: _buildActividadesPorMesChart(isMobile, isDark),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        RepaintBoundary(
                          key: _chartKeys[ChartType.presupuestoVsCosto],
                          child: _buildPresupuestoChart(isMobile, isDark),
                        ),
                      ] else ...[
                        RepaintBoundary(
                          key: _chartKeys[ChartType.actividadesPorEstado],
                          child: _buildActividadesPorEstadoChart(isMobile, isDark),
                        ),
                        SizedBox(height: 12),
                        RepaintBoundary(
                          key: _chartKeys[ChartType.actividadesPorTipo],
                          child: _buildActividadesPorTipoChart(isMobile, isDark),
                        ),
                        SizedBox(height: 12),
                        RepaintBoundary(
                          key: _chartKeys[ChartType.actividadesPorDepartamento],
                          child: _buildActividadesPorDepartamentoChart(isMobile, isDark),
                        ),
                        SizedBox(height: 12),
                        RepaintBoundary(
                          key: _chartKeys[ChartType.actividadesPorMes],
                          child: _buildActividadesPorMesChart(isMobile, isDark),
                        ),
                        SizedBox(height: 12),
                        RepaintBoundary(
                          key: _chartKeys[ChartType.presupuestoVsCosto],
                          child: _buildPresupuestoChart(isMobile, isDark),
                        ),
                      ],
                      
                      // Espaciado final
                      SizedBox(height: isMobile ? 60 : 40),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // Construir las estadísticas generales con indicadores de tendencia
  Widget _buildTrendStats(bool isMobile, bool isDark) {
    // Calcular estadísticas del período actual
    final totalActividades = _actividadesFiltradas.length;
    final totalPresupuesto = _getTotalPresupuesto();
    final totalCostoReal = _getTotalCostoReal();
    final actividadesConTransporte = _getActividadesConTransporte();
    final actividadesConAlojamiento = _getActividadesConAlojamiento();
    
    // Calcular estadísticas del período anterior
    final totalActividadesPrevio = _actividadesPeriodoAnterior.length;
    final totalPresupuestoPrevio = _getTotalPresupuestoPrevio();
    final totalCostoRealPrevio = _getTotalCostoRealPrevio();
    final actividadesConTransportePrevio = _getActividadesConTransportePrevio();
    final actividadesConAlojamientoPrevio = _getActividadesConAlojamientoPrevio();
    
    // Crear datos de tendencia
    final trendActividades = TrendData.fromValues(
      title: 'Total Actividades',
      currentValue: totalActividades.toDouble(),
      previousValue: totalActividadesPrevio.toDouble(),
      icon: Icons.event_available,
      color: AppColors.primary,
      subtitle: _currentPeriod.label,
      decimals: 0,
    );
    
    final trendPresupuesto = TrendData.fromValues(
      title: 'Presupuesto Total',
      currentValue: totalPresupuesto,
      previousValue: totalPresupuestoPrevio,
      icon: Icons.account_balance_wallet,
      color: AppColors.estadoAprobado,
      subtitle: 'Planificado',
      valuePrefix: '€',
      decimals: 2,
    );
    
    final trendCostoReal = TrendData.fromValues(
      title: 'Costo Real',
      currentValue: totalCostoReal,
      previousValue: totalCostoRealPrevio,
      icon: Icons.euro,
      color: AppColors.warning,
      subtitle: 'Ejecutado',
      valuePrefix: '€',
      decimals: 2,
    );
    
    final trendTransporte = TrendData.fromValues(
      title: 'Con Transporte',
      currentValue: actividadesConTransporte.toDouble(),
      previousValue: actividadesConTransportePrevio.toDouble(),
      icon: Icons.directions_bus,
      color: AppColors.presupuestoTransporte,
      subtitle: 'Actividades',
      decimals: 0,
    );
    
    final trendAlojamiento = TrendData.fromValues(
      title: 'Con Alojamiento',
      currentValue: actividadesConAlojamiento.toDouble(),
      previousValue: actividadesConAlojamientoPrevio.toDouble(),
      icon: Icons.hotel,
      color: AppColors.presupuestoAlojamiento,
      subtitle: 'Actividades',
      decimals: 0,
    );

    if (isMobile) {
      return Column(
        children: [
          TrendStatCard(
            data: trendActividades,
            isMobile: true,
            isDark: isDark,
            onTap: () {},
          ),
          SizedBox(height: 8),
          TrendStatCard(
            data: trendPresupuesto,
            isMobile: true,
            isDark: isDark,
            onTap: () {},
          ),
          SizedBox(height: 8),
          TrendStatCard(
            data: trendCostoReal,
            isMobile: true,
            isDark: isDark,
            onTap: () {},
          ),
          SizedBox(height: 8),
          TrendStatCard(
            data: trendTransporte,
            isMobile: true,
            isDark: isDark,
            onTap: () {},
          ),
          SizedBox(height: 8),
          TrendStatCard(
            data: trendAlojamiento,
            isMobile: true,
            isDark: isDark,
            onTap: () {},
          ),
        ],
      );
    }

    // Layout para desktop (grid de 3 columnas más compacto)
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: (MediaQuery.of(context).size.width - 72) / 3,
          child: TrendStatCard(
            data: trendActividades,
            isMobile: false,
            isDark: isDark,
            onTap: () {},
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 72) / 3,
          child: TrendStatCard(
            data: trendPresupuesto,
            isMobile: false,
            isDark: isDark,
            onTap: () {},
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 72) / 3,
          child: TrendStatCard(
            data: trendCostoReal,
            isMobile: false,
            isDark: isDark,
            onTap: () {},
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 72) / 3,
          child: TrendStatCard(
            data: trendTransporte,
            isMobile: false,
            isDark: isDark,
            onTap: () {},
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 72) / 3,
          child: TrendStatCard(
            data: trendAlojamiento,
            isMobile: false,
            isDark: isDark,
            onTap: () {},
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
            padding: EdgeInsets.all(isMobile ? 12 : 14),
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

  // Helper para construir el encabezado de gráfica con botón de filtro individual
  Widget _buildChartHeader({
    required String title,
    required IconData icon,
    required bool isMobile,
    required bool isDark,
    VoidCallback? onFilterTap,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 6 : 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: isMobile ? 18 : 20,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
        ),
        if (onFilterTap != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.tune,
                  size: isMobile ? 20 : 22,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Mostrar opciones de filtro específicas para una gráfica
  void _showChartFilterOptions({
    required BuildContext context,
    required String title,
    required List<String> options,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.grey[900]!,
                    Colors.grey[850]!,
                  ]
                : [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Título
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            // Opciones
            ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    Icons.circle,
                    size: 12,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  title: Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Filtro "${options[index]}" aplicado'),
                        backgroundColor: AppColors.primary,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    // TODO: Implementar lógica de filtro específica
                  },
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.3),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
          ],
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
      padding: EdgeInsets.all(isMobile ? 12 : 14),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(
            title: 'Actividades por Estado',
            icon: Icons.pie_chart_rounded,
            isMobile: isMobile,
            isDark: isDark,
            onFilterTap: () => _showChartFilterOptions(
              context: context,
              title: 'Filtrar por Estado',
              options: [
                'Mostrar todos',
                'Solo Aprobadas',
                'Solo Pendientes',
                'Solo Rechazadas',
                'Excluir Rechazadas',
              ],
              isDark: isDark,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 14),
          SizedBox(
            height: isMobile ? 200 : 240,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: isMobile ? 30 : 40,
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                SizedBox(width: 12),
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
      filterOptions: [
        'Mostrar todos',
        'Solo Complementarias',
        'Solo Extraescolares',
        'Ordenar por cantidad',
      ],
      child: SizedBox(
        height: isMobile ? 180 : 220,
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
    List<String>? filterOptions,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1) 
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(
            title: title,
            icon: icon,
            isMobile: isMobile,
            isDark: isDark,
            onFilterTap: filterOptions != null
                ? () => _showChartFilterOptions(
                      context: context,
                      title: 'Filtrar $title',
                      options: filterOptions,
                      isDark: isDark,
                    )
                : null,
          ),
          SizedBox(height: isMobile ? 10 : 12),
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
      filterOptions: [
        'Mostrar todos',
        'Top 5 departamentos',
        'Top 10 departamentos',
        'Excluir sin departamento',
        'Ordenar alfabéticamente',
      ],
      child: SizedBox(
        height: isMobile ? 180 : 220,
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
      filterOptions: [
        'Mostrar todos los meses',
        'Solo trimestre actual',
        'Solo semestre actual',
        'Año académico (Sep-Jun)',
        'Excluir meses sin actividades',
      ],
      child: SizedBox(
        height: isMobile ? 180 : 220,
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
      filterOptions: [
        'Mostrar ambos (Presupuesto y Costo)',
        'Solo Presupuesto estimado',
        'Solo Costo real',
        'Solo actividades completadas',
        'Ordenar por diferencia',
      ],
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
