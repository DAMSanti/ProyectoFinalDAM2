import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/models/grupo.dart';

/// Diálogo para seleccionar múltiples grupos/cursos participantes
class MultiSelectGrupoDialog extends StatefulWidget {
  final List<Curso> cursos;
  final List<Grupo> grupos;
  final List<Grupo> gruposYaSeleccionados;

  const MultiSelectGrupoDialog({
    Key? key,
    required this.cursos,
    required this.grupos,
    required this.gruposYaSeleccionados,
  }) : super(key: key);

  @override
  State<MultiSelectGrupoDialog> createState() => _MultiSelectGrupoDialogState();
}

class _MultiSelectGrupoDialogState extends State<MultiSelectGrupoDialog> {
  final List<Grupo> _selectedGrupos = [];
  final Set<int> _expandedCursos = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  List<Curso> get _filteredCursos {
    if (_searchQuery.isEmpty) {
      return widget.cursos;
    }
    
    return widget.cursos.where((curso) {
      final cursoName = curso.nombre.toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      // Incluir el curso si su nombre coincide o si alguno de sus grupos coincide
      final coincideCurso = cursoName.contains(query);
      final algunGrupoCoincide = _getGruposDeCurso(curso.id).any(
        (grupo) => grupo.nombre.toLowerCase().contains(query)
      );
      
      return coincideCurso || algunGrupoCoincide;
    }).toList();
  }

  List<Grupo> _getGruposDeCurso(int cursoId) {
    return widget.grupos.where((g) => g.cursoId == cursoId).toList();
  }

  bool _isGrupoYaParticipante(Grupo grupo) {
    return widget.gruposYaSeleccionados.any((g) => g.id == grupo.id);
  }

  void _toggleCurso(int cursoId) {
    final gruposCurso = _getGruposDeCurso(cursoId);
    final todosSeleccionados = gruposCurso.every(
      (g) => _selectedGrupos.any((sg) => sg.id == g.id) || _isGrupoYaParticipante(g)
    );
    
    setState(() {
      if (todosSeleccionados) {
        // Deseleccionar todos los grupos del curso
        _selectedGrupos.removeWhere((g) => gruposCurso.any((gc) => gc.id == g.id));
      } else {
        // Seleccionar todos los grupos del curso que no estén ya participando
        for (var grupo in gruposCurso) {
          if (!_isGrupoYaParticipante(grupo) && !_selectedGrupos.any((g) => g.id == grupo.id)) {
            _selectedGrupos.add(grupo);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 650,
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
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Agregar Grupos/Cursos Participantes',
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
                          hintText: 'Buscar curso o grupo...',
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
                    if (_selectedGrupos.isNotEmpty)
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
                                '${_selectedGrupos.length} grupo(s) seleccionado(s) para agregar',
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
                    
                    // Lista de cursos con grupos
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
                        child: _filteredCursos.isEmpty
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
                                    'No se encontraron cursos',
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
                              itemCount: _filteredCursos.length,
                              itemBuilder: (context, index) {
                                final curso = _filteredCursos[index];
                                final grupos = _getGruposDeCurso(curso.id);
                                final isExpanded = _expandedCursos.contains(curso.id);
                                final todosGruposSeleccionados = grupos.isNotEmpty && grupos.every(
                                  (g) => _selectedGrupos.any((sg) => sg.id == g.id) || _isGrupoYaParticipante(g)
                                );
                                final algunoSeleccionado = grupos.any(
                                  (g) => _selectedGrupos.any((sg) => sg.id == g.id)
                                );
                                
                                return Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: algunoSeleccionado
                                      ? Color(0xFF1976d2).withOpacity(0.5)
                                      : Colors.transparent,
                                    width: algunoSeleccionado ? 2 : 1,
                                  ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Curso header
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF1976d2).withOpacity(0.15),
                                              Color(0xFF1565c0).withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                            bottomLeft: isExpanded ? Radius.zero : Radius.circular(12),
                                            bottomRight: isExpanded ? Radius.zero : Radius.circular(12),
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (isExpanded) {
                                                  _expandedCursos.remove(curso.id);
                                                } else {
                                                  _expandedCursos.add(curso.id);
                                                }
                                              });
                                            },
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                              bottomLeft: isExpanded ? Radius.zero : Radius.circular(12),
                                              bottomRight: isExpanded ? Radius.zero : Radius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: todosGruposSeleccionados,
                                                    tristate: true,
                                                    activeColor: Color(0xFF1976d2),
                                                    onChanged: (value) => _toggleCurso(curso.id),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                                                      ),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      Icons.school_rounded,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          curso.nombre,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                            color: Color(0xFF1976d2),
                                                          ),
                                                        ),
                                                        SizedBox(height: 2),
                                                        Text(
                                                          '${grupos.length} grupo(s)',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isDark ? Colors.white70 : Colors.black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF1976d2).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      isExpanded 
                                                        ? Icons.expand_less_rounded 
                                                        : Icons.expand_more_rounded,
                                                      color: Color(0xFF1976d2),
                                                      size: 24,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Grupos expandibles
                                      if (isExpanded)
                                        Container(
                                          padding: EdgeInsets.only(left: 16, right: 8, bottom: 8, top: 4),
                                          child: Column(
                                            children: grupos.map((grupo) {
                                              final yaParticipante = _isGrupoYaParticipante(grupo);
                                              final isSelected = _selectedGrupos.any((g) => g.id == grupo.id);
                                              
                                              return Container(
                                                margin: EdgeInsets.only(top: 8),
                                                decoration: BoxDecoration(
                                                  color: yaParticipante 
                                                    ? Colors.grey.withOpacity(0.1)
                                                    : isSelected
                                                      ? Color(0xFF1976d2).withOpacity(0.1)
                                                      : Colors.white.withOpacity(0.5),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: yaParticipante
                                                      ? Colors.grey.withOpacity(0.3)
                                                      : isSelected
                                                        ? Color(0xFF1976d2).withOpacity(0.4)
                                                        : Colors.transparent,
                                                    width: isSelected ? 1.5 : 1,
                                                  ),
                                                ),
                                                child: CheckboxListTile(
                                                  title: Row(
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          gradient: yaParticipante
                                                            ? LinearGradient(
                                                                colors: [Colors.grey[400]!, Colors.grey[500]!],
                                                              )
                                                            : LinearGradient(
                                                                colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                                                              ),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          grupo.nombre,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                      if (yaParticipante) ...[
                                                        SizedBox(width: 8),
                                                        Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: Colors.orange.withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(4),
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
                                                                size: 10,
                                                                color: Colors.orange,
                                                              ),
                                                              SizedBox(width: 4),
                                                              Text(
                                                                'Ya participa',
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors.orange,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  subtitle: Padding(
                                                    padding: EdgeInsets.only(top: 4),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.people_rounded,
                                                          size: 14,
                                                          color: isDark ? Colors.white70 : Colors.black54,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          '${grupo.numeroAlumnos} alumnos',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isDark ? Colors.white70 : Colors.black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  value: isSelected,
                                                  enabled: !yaParticipante,
                                                  activeColor: Color(0xFF1976d2),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  onChanged: yaParticipante
                                                      ? null
                                                      : (bool? value) {
                                                          setState(() {
                                                            if (value == true) {
                                                              _selectedGrupos.add(grupo);
                                                            } else {
                                                              _selectedGrupos.removeWhere((g) => g.id == grupo.id);
                                                            }
                                                          });
                                                        },
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                    ],
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
                    opacity: _selectedGrupos.isEmpty ? 0.5 : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1976d2),
                            Color(0xFF1565c0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _selectedGrupos.isEmpty
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
                          onTap: _selectedGrupos.isEmpty
                              ? null
                              : () => Navigator.of(context).pop(_selectedGrupos),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Agregar${_selectedGrupos.isEmpty ? '' : ' (${_selectedGrupos.length})'}',
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
