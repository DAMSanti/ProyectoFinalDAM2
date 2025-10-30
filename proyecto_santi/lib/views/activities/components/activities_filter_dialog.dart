import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/services/services.dart';

/// Diálogo de filtros para la vista de actividades
class ActivitiesFilterDialog extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const ActivitiesFilterDialog({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<ActivitiesFilterDialog> createState() => _ActivitiesFilterDialogState();
}

class _ActivitiesFilterDialogState extends State<ActivitiesFilterDialog> {
  late Map<String, dynamic> _tempFilters;
  late final ApiService _apiService;
  late final ProfesorService _profesorService;
  
  // Opciones de filtros
  final List<String> _estados = ['Pendiente', 'Aprobada', 'Cancelada'];
  final List<String> _cursos = ['1º ESO', '2º ESO', '3º ESO', '4º ESO', '1º Bach', '2º Bach'];
  
  // Profesores cargados dinámicamente
  List<Profesor> _profesores = [];
  bool _isLoadingProfesores = true;

  @override
  void initState() {
    super.initState();
    _tempFilters = Map<String, dynamic>.from(widget.currentFilters);
    _apiService = ApiService();
    _profesorService = ProfesorService(_apiService);
    _loadProfesores();
  }

  Future<void> _loadProfesores() async {
    try {
      final profesores = await _profesorService.fetchProfesores();
      setState(() {
        _profesores = profesores;
        _isLoadingProfesores = false;
      });
    } catch (e) {
      print('[ERROR] Error cargando profesores: $e');
      setState(() {
        _isLoadingProfesores = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isMobileLandscape = isMobile && !isPortrait;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobileLandscape ? 12 : 16),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobileLandscape ? 20 : (isMobile ? 16 : 40),
        vertical: isMobileLandscape ? 12 : (isMobile ? 20 : 24),
      ),
      child: Container(
        width: isMobile ? double.infinity : 500,
        constraints: BoxConstraints(
          maxHeight: isMobileLandscape 
              ? screenHeight * 0.9 
              : (isMobile ? screenHeight * 0.85 : 700),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobileLandscape ? 12 : 16),
          gradient: LinearGradient(
            colors: isDark
                ? [Color(0xFF1a1a2e), Color(0xFF16213e)]
                : [Colors.white, Color(0xFFf5f5f5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header compacto
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobileLandscape ? 10 : (isMobile ? 12 : 20),
                vertical: isMobileLandscape ? 8 : (isMobile ? 12 : 16),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Color(0xFF1976d2), Color(0xFF1565c0)]
                      : [Color(0xFF1976d2), Color(0xFF2196f3)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobileLandscape ? 12 : 16),
                  topRight: Radius.circular(isMobileLandscape ? 12 : 16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_rounded,
                    color: Colors.white,
                    size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                  ),
                  SizedBox(width: isMobileLandscape ? 6 : 8),
                  Expanded(
                    child: Text(
                      'Filtros',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close, 
                      color: Colors.white, 
                      size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.all(isMobileLandscape ? 2 : 4),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Contenido
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filtro por fecha
                    _buildFilterSection(
                      context,
                      icon: Icons.calendar_today_rounded,
                      title: 'Fecha',
                      isDark: isDark,
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobileLandscape ? 8 : (isMobile ? 10 : 16),
                            vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 14),
                          ),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                            border: Border.all(
                              color: isDark 
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event,
                                color: isDark ? Colors.white70 : Color(0xFF1976d2),
                                size: isMobileLandscape ? 14 : (isMobile ? 16 : 20),
                              ),
                              SizedBox(width: isMobileLandscape ? 6 : 8),
                              Expanded(
                                child: Text(
                                  _tempFilters['fecha'] != null
                                      ? _formatDate(_tempFilters['fecha'])
                                      : 'Seleccionar fecha',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 15),
                                  ),
                                ),
                              ),
                              if (_tempFilters['fecha'] != null)
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _tempFilters['fecha'] = null;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(isMobileLandscape ? 2 : 4),
                                    child: Icon(
                                      Icons.clear, 
                                      size: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isMobileLandscape ? 10 : (isMobile ? 14 : 20)),

                    // Filtro por estado
                    _buildFilterSection(
                      context,
                      icon: Icons.flag_rounded,
                      title: 'Estado',
                      isDark: isDark,
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                      child: Wrap(
                        spacing: isMobileLandscape ? 4 : (isMobile ? 6 : 8),
                        runSpacing: isMobileLandscape ? 4 : (isMobile ? 6 : 8),
                        children: _estados.map((estado) {
                          final isSelected = _tempFilters['estado'] == estado;
                          return FilterChip(
                            label: Text(
                              estado,
                              style: TextStyle(fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 14)),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _tempFilters['estado'] = selected ? estado : null;
                              });
                            },
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobileLandscape ? 4 : (isMobile ? 6 : 8),
                              vertical: isMobileLandscape ? 0 : (isMobile ? 2 : 4),
                            ),
                            selectedColor: Color(0xFF1976d2).withOpacity(0.2),
                            checkmarkColor: Color(0xFF1976d2),
                            labelStyle: TextStyle(
                              color: isSelected 
                                  ? Color(0xFF1976d2)
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: isMobileLandscape ? 10 : (isMobile ? 14 : 20)),

                    // Filtro por curso
                    _buildFilterSection(
                      context,
                      icon: Icons.school_rounded,
                      title: 'Curso',
                      isDark: isDark,
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                      child: Wrap(
                        spacing: isMobileLandscape ? 4 : (isMobile ? 6 : 8),
                        runSpacing: isMobileLandscape ? 4 : (isMobile ? 6 : 8),
                        children: _cursos.map((curso) {
                          final isSelected = _tempFilters['curso'] == curso;
                          return FilterChip(
                            label: Text(
                              curso,
                              style: TextStyle(fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 14)),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _tempFilters['curso'] = selected ? curso : null;
                              });
                            },
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobileLandscape ? 4 : (isMobile ? 6 : 8),
                              vertical: isMobileLandscape ? 0 : (isMobile ? 2 : 4),
                            ),
                            selectedColor: Color(0xFF1976d2).withOpacity(0.2),
                            checkmarkColor: Color(0xFF1976d2),
                            labelStyle: TextStyle(
                              color: isSelected 
                                  ? Color(0xFF1976d2)
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: isMobileLandscape ? 10 : (isMobile ? 14 : 20)),

                    // Filtro por profesor
                    _buildFilterSection(
                      context,
                      icon: Icons.person_rounded,
                      title: 'Profesor',
                      isDark: isDark,
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                      child: _isLoadingProfesores
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(isMobileLandscape ? 8 : (isMobile ? 12 : 20)),
                                child: SizedBox(
                                  width: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                                  height: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976d2)),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobileLandscape ? 6 : (isMobile ? 8 : 12),
                                vertical: isMobileLandscape ? 2 : (isMobile ? 4 : 8),
                              ),
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                                border: Border.all(
                                  color: isDark 
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _tempFilters['profesorId'],
                                  hint: Text(
                                    'Seleccionar profesor',
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 15),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: isDark ? Colors.white70 : Color(0xFF1976d2),
                                    size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                                  ),
                                  dropdownColor: isDark ? Color(0xFF1a1a2e) : Colors.white,
                                  style: TextStyle(
                                    fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 15),
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text(
                                        'Todos los profesores',
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Colors.black87,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    ..._profesores.map((profesor) {
                                      return DropdownMenuItem<String>(
                                        value: profesor.uuid,
                                        child: Text(
                                          '${profesor.nombre} ${profesor.apellidos}',
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _tempFilters['profesorId'] = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer con botones
            Container(
              padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 20)),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isMobileLandscape ? 12 : 16),
                  bottomRight: Radius.circular(isMobileLandscape ? 12 : 16),
                ),
              ),
              child: Row(
                children: [
                  // Botón limpiar
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _tempFilters = {
                            'fecha': null,
                            'estado': null,
                            'curso': null,
                            'profesorId': null,
                          };
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 14),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.white30 : Color(0xFF1976d2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                        ),
                      ),
                      child: Text(
                        'Limpiar',
                        style: TextStyle(
                          color: isDark ? Colors.white : Color(0xFF1976d2),
                          fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isMobileLandscape ? 6 : (isMobile ? 8 : 12)),
                  // Botón aplicar
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApplyFilters(_tempFilters);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 14),
                        ),
                        backgroundColor: Color(0xFF1976d2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : 10),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Aplicar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildFilterSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
    required bool isMobile,
    required bool isMobileLandscape,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white70 : Color(0xFF1976d2),
              size: isMobileLandscape ? 14 : (isMobile ? 16 : 20),
            ),
            SizedBox(width: isMobileLandscape ? 4 : 6),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16),
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobileLandscape ? 6 : (isMobile ? 8 : 12)),
        child,
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tempFilters['fecha'] ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1976d2),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tempFilters['fecha'] = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
