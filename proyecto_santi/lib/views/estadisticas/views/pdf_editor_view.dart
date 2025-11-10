import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/app_colors.dart';
import 'package:proyecto_santi/views/estadisticas/models/chart_item.dart';

class PdfEditorView extends StatefulWidget {
  final Function(List<ChartItem>) onGeneratePdf;

  const PdfEditorView({
    Key? key,
    required this.onGeneratePdf,
  }) : super(key: key);

  @override
  State<PdfEditorView> createState() => _PdfEditorViewState();
}

class _PdfEditorViewState extends State<PdfEditorView> {
  List<ChartItem> _charts = [];
  
  @override
  void initState() {
    super.initState();
    _charts = ChartItem.getDefaultCharts();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCharts = _charts.where((c) => c.isSelected).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Editor de PDF',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Selecciona y ordena las gráficas a exportar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Row(
                children: [
                  // Lista de gráficas disponibles
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.dashboard_customize_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Gráficas Disponibles',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.primary,
                                ),
                              ),
                              Spacer(),
                              TextButton.icon(
                                onPressed: _selectAll,
                                icon: Icon(Icons.select_all, size: 18),
                                label: Text('Seleccionar todo'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _charts.length,
                              itemBuilder: (context, index) {
                                return _buildChartTile(_charts[index], isDark);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Container(
                    width: 1,
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                  ),

                  // Preview de gráficas seleccionadas
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.preview_rounded,
                                color: AppColors.estadoAprobado,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Vista Previa (${selectedCharts.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.primary,
                                ),
                              ),
                              Spacer(),
                              if (selectedCharts.isNotEmpty)
                                TextButton.icon(
                                  onPressed: _clearSelection,
                                  icon: Icon(Icons.clear_all, size: 18),
                                  label: Text('Limpiar'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.estadoRechazado,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 16),
                          if (selectedCharts.isEmpty)
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_rounded,
                                      size: 64,
                                      color: isDark 
                                          ? Colors.white.withValues(alpha: 0.3)
                                          : Colors.black.withValues(alpha: 0.2),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Ninguna gráfica seleccionada',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark 
                                            ? Colors.white.withValues(alpha: 0.5)
                                            : Colors.black.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ReorderableListView.builder(
                                itemCount: selectedCharts.length,
                                onReorder: _onReorder,
                                itemBuilder: (context, index) {
                                  return _buildSelectedChartCard(
                                    selectedCharts[index],
                                    index + 1,
                                    isDark,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer con botones
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.black54,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: selectedCharts.isEmpty
                        ? null
                        : () {
                            widget.onGeneratePdf(selectedCharts);
                            Navigator.pop(context);
                          },
                    icon: Icon(Icons.download_rounded),
                    label: Text('Generar PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.estadoAprobado,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTile(ChartItem chart, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: chart.isSelected
              ? AppColors.primary
              : (isDark 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05)),
          width: chart.isSelected ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: chart.isSelected,
        onChanged: (value) => _toggleChart(chart),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(chart.icon, color: Colors.white, size: 18),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chart.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    chart.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        activeColor: AppColors.primary,
        checkColor: Colors.white,
      ),
    );
  }

  Widget _buildSelectedChartCard(ChartItem chart, int position, bool isDark) {
    return Container(
      key: ValueKey(chart.type),
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.primary.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Icon(chart.icon, color: AppColors.primary, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              chart.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Icon(
            Icons.drag_indicator_rounded,
            color: isDark 
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  void _toggleChart(ChartItem chart) {
    setState(() {
      final index = _charts.indexWhere((c) => c.type == chart.type);
      if (index != -1) {
        _charts[index].isSelected = !_charts[index].isSelected;
        if (_charts[index].isSelected) {
          // Asignar orden basado en cuántos ya están seleccionados
          final selectedCount = _charts.where((c) => c.isSelected).length;
          _charts[index].order = selectedCount - 1;
        } else {
          _charts[index].order = 0;
          // Reordenar los demás
          _reorderAfterRemoval();
        }
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final selectedCharts = _charts.where((c) => c.isSelected).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      
      final item = selectedCharts.removeAt(oldIndex);
      selectedCharts.insert(newIndex, item);
      
      // Actualizar orden
      for (int i = 0; i < selectedCharts.length; i++) {
        selectedCharts[i].order = i;
      }
    });
  }

  void _reorderAfterRemoval() {
    final selectedCharts = _charts.where((c) => c.isSelected).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    for (int i = 0; i < selectedCharts.length; i++) {
      selectedCharts[i].order = i;
    }
  }

  void _selectAll() {
    setState(() {
      for (int i = 0; i < _charts.length; i++) {
        _charts[i].isSelected = true;
        _charts[i].order = i;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      for (var chart in _charts) {
        chart.isSelected = false;
        chart.order = 0;
      }
    });
  }
}
