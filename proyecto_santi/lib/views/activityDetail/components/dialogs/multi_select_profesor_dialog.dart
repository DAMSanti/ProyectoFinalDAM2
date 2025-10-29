import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/profesor.dart';

/// Diálogo para seleccionar múltiples profesores participantes
class MultiSelectProfesorDialog extends StatefulWidget {
  final List<Profesor> profesores;
  final List<Profesor> profesoresYaSeleccionados;

  const MultiSelectProfesorDialog({
    Key? key,
    required this.profesores,
    required this.profesoresYaSeleccionados,
  }) : super(key: key);

  @override
  State<MultiSelectProfesorDialog> createState() => _MultiSelectProfesorDialogState();
}

class _MultiSelectProfesorDialogState extends State<MultiSelectProfesorDialog> {
  final List<Profesor> _selectedProfesores = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // No pre-seleccionamos ninguno, el usuario elegirá
  }

  List<Profesor> get _filteredProfesores {
    if (_searchQuery.isEmpty) {
      return widget.profesores;
    }
    
    return widget.profesores.where((profesor) {
      final fullName = '${profesor.nombre} ${profesor.apellidos}'.toLowerCase();
      final email = profesor.correo.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return fullName.contains(query) || email.contains(query);
    }).toList();
  }

  bool _isProfesorYaParticipante(Profesor profesor) {
    return widget.profesoresYaSeleccionados.any((p) => p.uuid == profesor.uuid);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
              ? const [
                  Color.fromRGBO(25, 118, 210, 0.25),
                  Color.fromRGBO(21, 101, 192, 0.20),
                ]
              : const [
                  Color.fromRGBO(187, 222, 251, 0.95),
                  Color.fromRGBO(144, 202, 249, 0.85),
                ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark 
              ? const Color.fromRGBO(255, 255, 255, 0.1) 
              : const Color.fromRGBO(0, 0, 0, 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1976d2),
                    Color(0xFF1565c0),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1976d2).withOpacity(0.3),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.group_add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Agregar Profesores Participantes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Buscador moderno
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF1976d2).withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF1976d2).withOpacity(0.1),
                            offset: Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar profesor por nombre o email...',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF1976d2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Contador de seleccionados
                    if (_selectedProfesores.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1976d2).withOpacity(0.2),
                              Color(0xFF1565c0).withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF1976d2).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_selectedProfesores.length} profesor(es) seleccionado(s) para agregar',
                                style: TextStyle(
                                  color: Color(0xFF1976d2),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 12),
                    
                    // Lista de profesores
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark 
                              ? Colors.white.withOpacity(0.1) 
                              : Colors.black.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                        child: _filteredProfesores.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1976d2).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.search_off_rounded,
                                      size: 48,
                                      color: Color(0xFF1976d2).withOpacity(0.5),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No se encontraron profesores',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Intenta con otros términos de búsqueda',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white54 : Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: _filteredProfesores.length,
                              itemBuilder: (context, index) {
                                final profesor = _filteredProfesores[index];
                                final yaParticipante = _isProfesorYaParticipante(profesor);
                                final isSelected = _selectedProfesores.any((p) => p.uuid == profesor.uuid);
                                
                                return Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: yaParticipante 
                                      ? Colors.grey.withOpacity(0.1)
                                      : isSelected
                                        ? Color(0xFF1976d2).withOpacity(0.15)
                                        : Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: yaParticipante
                                        ? Colors.grey.withOpacity(0.3)
                                        : isSelected
                                          ? Color(0xFF1976d2).withOpacity(0.5)
                                          : Colors.transparent,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: CheckboxListTile(
                                    title: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: yaParticipante
                                                ? [Colors.grey[400]!, Colors.grey[500]!]
                                                : [Color(0xFF1976d2), Color(0xFF1565c0)],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${profesor.nombre[0]}${profesor.apellidos[0]}'.toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${profesor.nombre} ${profesor.apellidos}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                profesor.correo,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark ? Colors.white70 : Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: yaParticipante
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 8, left: 52),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.orange.withOpacity(0.5),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 12,
                                                  color: Colors.orange,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Ya participa en esta actividad',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : null,
                                    value: isSelected,
                                    enabled: !yaParticipante,
                                    activeColor: Color(0xFF1976d2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onChanged: yaParticipante
                                        ? null
                                        : (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                _selectedProfesores.add(profesor);
                                              } else {
                                                _selectedProfesores.removeWhere((p) => p.uuid == profesor.uuid);
                                              }
                                            });
                                          },
                                  ),
                                );
                              },
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey[850]!.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(0, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón Cancelar
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[400]!,
                          Colors.grey[500]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Botón Agregar
                  Opacity(
                    opacity: _selectedProfesores.isEmpty ? 0.5 : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1976d2),
                            Color(0xFF1565c0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _selectedProfesores.isEmpty
                          ? []
                          : [
                              BoxShadow(
                                color: Color(0xFF1976d2).withOpacity(0.4),
                                offset: Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _selectedProfesores.isEmpty
                              ? null
                              : () => Navigator.of(context).pop(_selectedProfesores),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.group_add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Agregar${_selectedProfesores.isEmpty ? '' : ' (${_selectedProfesores.length})'}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
}
