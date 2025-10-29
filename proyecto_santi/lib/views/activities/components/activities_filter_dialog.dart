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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 500,
        constraints: BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Color(0xFF1976d2), Color(0xFF1565c0)]
                      : [Color(0xFF1976d2), Color(0xFF2196f3)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Filtros de Búsqueda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Contenido
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filtro por fecha
                    _buildFilterSection(
                      context,
                      icon: Icons.calendar_today_rounded,
                      title: 'Fecha',
                      isDark: isDark,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
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
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                _tempFilters['fecha'] != null
                                    ? _formatDate(_tempFilters['fecha'])
                                    : 'Seleccionar fecha',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              Spacer(),
                              if (_tempFilters['fecha'] != null)
                                IconButton(
                                  icon: Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _tempFilters['fecha'] = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Filtro por estado
                    _buildFilterSection(
                      context,
                      icon: Icons.flag_rounded,
                      title: 'Estado',
                      isDark: isDark,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _estados.map((estado) {
                          final isSelected = _tempFilters['estado'] == estado;
                          return FilterChip(
                            label: Text(estado),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _tempFilters['estado'] = selected ? estado : null;
                              });
                            },
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

                    SizedBox(height: 20),

                    // Filtro por curso
                    _buildFilterSection(
                      context,
                      icon: Icons.school_rounded,
                      title: 'Curso',
                      isDark: isDark,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _cursos.map((curso) {
                          final isSelected = _tempFilters['curso'] == curso;
                          return FilterChip(
                            label: Text(curso),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _tempFilters['curso'] = selected ? curso : null;
                              });
                            },
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

                    SizedBox(height: 20),

                    // Filtro por profesor
                    _buildFilterSection(
                      context,
                      icon: Icons.person_rounded,
                      title: 'Profesor (Responsable o Participante)',
                      isDark: isDark,
                      child: _isLoadingProfesores
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976d2)),
                                ),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
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
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: isDark ? Colors.white70 : Color(0xFF1976d2),
                                  ),
                                  dropdownColor: isDark ? Color(0xFF1a1a2e) : Colors.white,
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
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
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
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: isDark ? Colors.white30 : Color(0xFF1976d2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Limpiar',
                        style: TextStyle(
                          color: isDark ? Colors.white : Color(0xFF1976d2),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Botón aplicar
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApplyFilters(_tempFilters);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Color(0xFF1976d2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Aplicar Filtros',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
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
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
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
