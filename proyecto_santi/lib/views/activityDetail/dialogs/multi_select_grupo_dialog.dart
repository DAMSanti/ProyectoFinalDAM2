import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/tema.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/models/grupo.dart';
import 'layouts/multi_select_portrait_layout.dart';
import 'layouts/multi_select_landscape_layout.dart';

class MultiSelectGrupoDialog extends StatefulWidget {
  final List<Curso> cursos;
  final List<Grupo> grupos;
  final List<Grupo> gruposYaSeleccionados;

  const MultiSelectGrupoDialog({
    super.key,
    required this.cursos,
    required this.grupos,
    required this.gruposYaSeleccionados,
  });

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
        _selectedGrupos.removeWhere((g) => gruposCurso.any((gc) => gc.id == g.id));
      } else {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final isMobile = screenWidth < 600;
    final isMobileLandscape = (isMobile && !isPortrait) || (!isPortrait && screenHeight < 500);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: isMobileLandscape
          ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : (isMobile 
              ? EdgeInsets.symmetric(horizontal: 16, vertical: 40)
              : EdgeInsets.symmetric(horizontal: 40, vertical: 24)),
      child: Container(
        width: isMobile ? double.infinity : 650,
        constraints: BoxConstraints(
          maxHeight: isMobileLandscape
              ? screenHeight * 0.95
              : (isMobile ? screenHeight * 0.85 : screenHeight * 0.85),
        ),
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
          borderRadius: BorderRadius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
          border: Border.all(
            color: isDark 
              ? const Color.fromRGBO(255, 255, 255, 0.1) 
              : const Color.fromRGBO(0, 0, 0, 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: Offset(0, isMobileLandscape ? 6 : 10),
              blurRadius: isMobileLandscape ? 20 : 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 20),
                vertical: isMobileLandscape ? 10 : (isMobile ? 14 : 20),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                  topRight: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOpacity30,
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                    ),
                  ),
                  SizedBox(width: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                  Expanded(
                    child: Text(
                      isMobile ? 'Agregar Grupos/Cursos' : 'Agregar Grupos/Cursos Participantes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.white),
                    iconSize: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.all(isMobileLandscape ? 4 : (isMobile ? 4 : 8)),
                    constraints: BoxConstraints(),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
            Expanded(
              child: isMobileLandscape
                  ? MultiSelectLandscapeLayout(
                      isDark: isDark,
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                      filteredCursos: _filteredCursos,
                      allGrupos: widget.grupos,
                      selectedGrupos: _selectedGrupos,
                      gruposYaSeleccionados: widget.gruposYaSeleccionados,
                      expandedCursos: _expandedCursos,
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onToggleCurso: _toggleCurso,
                      onExpandCurso: (cursoId) {
                        setState(() {
                          if (_expandedCursos.contains(cursoId)) {
                            _expandedCursos.remove(cursoId);
                          } else {
                            _expandedCursos.add(cursoId);
                          }
                        });
                      },
                      onSelectGrupo: (grupo, value) {
                        setState(() {
                          if (value) {
                            _selectedGrupos.add(grupo);
                          } else {
                            _selectedGrupos.removeWhere((g) => g.id == grupo.id);
                          }
                        });
                      },
                    )
                  : MultiSelectPortraitLayout(
                      isDark: isDark,
                      isMobile: isMobile,
                      isMobileLandscape: isMobileLandscape,
                      filteredCursos: _filteredCursos,
                      allGrupos: widget.grupos,
                      selectedGrupos: _selectedGrupos,
                      gruposYaSeleccionados: widget.gruposYaSeleccionados,
                      expandedCursos: _expandedCursos,
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onToggleCurso: _toggleCurso,
                      onExpandCurso: (cursoId) {
                        setState(() {
                          if (_expandedCursos.contains(cursoId)) {
                            _expandedCursos.remove(cursoId);
                          } else {
                            _expandedCursos.add(cursoId);
                          }
                        });
                      },
                      onSelectGrupo: (grupo, value) {
                        setState(() {
                          if (value) {
                            _selectedGrupos.add(grupo);
                          } else {
                            _selectedGrupos.removeWhere((g) => g.id == grupo.id);
                          }
                        });
                      },
                    ),
            ),
            Container(
              padding: EdgeInsets.all(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey[850]!.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                  bottomRight: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: Offset(0, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
                children: [
                  Expanded(
                    flex: isMobile ? 1 : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[400]!, Colors.grey[500]!],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.3),
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
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 24), 
                              vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12),
                            ),
                            child: Row(
                              mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                                ),
                                SizedBox(width: isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
                                Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: isMobile ? 1 : 0,
                    child: Opacity(
                      opacity: _selectedGrupos.isEmpty ? 0.5 : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedGrupos.isEmpty
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.primaryOpacity40,
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
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 24),
                                vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12),
                              ),
                              child: Row(
                                mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.school_rounded,
                                    color: Colors.white,
                                    size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                                  ),
                                  SizedBox(width: isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
                                  Text(
                                    'Agregar${_selectedGrupos.isEmpty ? '' : ' (${_selectedGrupos.length})'}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16),
                                    ),
                                  ),
                                ],
                              ),
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
