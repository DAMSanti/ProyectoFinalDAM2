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
              color: Colors.black.withOpacity(0.3),
              offset: Offset(0, isMobileLandscape ? 6 : 10),
              blurRadius: isMobileLandscape ? 20 : 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 20),
                vertical: isMobileLandscape ? 10 : (isMobile ? 14 : 20),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1976d2),
                    Color(0xFF1565c0),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                  topRight: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
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
                    padding: EdgeInsets.all(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
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
            
            // Content - Layout condicional
            Expanded(
              child: isMobileLandscape
                  ? _buildLandscapeMobileLayout(isDark, isMobile, isMobileLandscape)
                  : _buildPortraitLayout(isDark, isMobile, isMobileLandscape),
            ),
            
            // Actions - Footer adaptivo
            Container(
              padding: EdgeInsets.all(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey[850]!.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                  bottomRight: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
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
                mainAxisAlignment: isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
                children: [
                  // Botón Cancelar
                  Expanded(
                    flex: isMobile ? 1 : 0,
                    child: Container(
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
                  // Botón Agregar
                  Expanded(
                    flex: isMobile ? 1 : 0,
                    child: Opacity(
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
                                    isMobile && isMobileLandscape
                                      ? 'Agregar${_selectedGrupos.isEmpty ? '' : ' (${_selectedGrupos.length})'}'
                                      : 'Agregar${_selectedGrupos.isEmpty ? '' : ' (${_selectedGrupos.length})'}',
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

  // Layout vertical para portrait (móvil y escritorio)
  Widget _buildPortraitLayout(bool isDark, bool isMobile, bool isMobileLandscape) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                hintStyle: TextStyle(fontSize: isMobile ? 14 : 16),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF1976d2),
                  size: isMobile ? 20 : 24,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, 
                  vertical: isMobile ? 10 : 14,
                ),
              ),
              style: TextStyle(fontSize: isMobile ? 14 : 16),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          
          // Contador de seleccionados
          if (_selectedGrupos.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16, 
                vertical: isMobile ? 8 : 12,
              ),
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
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: isMobile ? 14 : 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Text(
                      '${_selectedGrupos.length} grupo(s) seleccionado(s) para agregar',
                      style: TextStyle(
                        color: Color(0xFF1976d2),
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: isMobile ? 8 : 12),
          
          // Lista de cursos con grupos
          Expanded(
            child: _buildCursosList(isDark, isMobile),
          ),
        ],
      ),
    );
  }

  // Layout horizontal para landscape móvil
  Widget _buildLandscapeMobileLayout(bool isDark, bool isMobile, bool isMobileLandscape) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: Buscador y contador
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Buscador moderno compacto
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFF1976d2).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(fontSize: 13),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF1976d2),
                        size: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      isDense: true,
                    ),
                    style: TextStyle(fontSize: 13),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                
                // Contador compacto
                if (_selectedGrupos.isNotEmpty) ...[
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1976d2).withOpacity(0.2),
                          Color(0xFF1565c0).withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFF1976d2).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${_selectedGrupos.length} seleccionado(s)',
                            style: TextStyle(
                              color: Color(0xFF1976d2),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          SizedBox(width: 12),
          
          // Columna derecha: Lista de cursos
          Expanded(
            flex: 5,
            child: _buildCursosList(isDark, isMobile, isCompact: true),
          ),
        ],
      ),
    );
  }

  // Widget común para la lista de cursos
  Widget _buildCursosList(bool isDark, bool isMobile, {bool isCompact = false}) {
    return Container(
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
                  padding: EdgeInsets.all(isCompact ? 12 : (isMobile ? 16 : 20)),
                  decoration: BoxDecoration(
                    color: Color(0xFF1976d2).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: isCompact ? 32 : (isMobile ? 40 : 48),
                    color: Color(0xFF1976d2).withOpacity(0.5),
                  ),
                ),
                SizedBox(height: isCompact ? 10 : (isMobile ? 12 : 16)),
                Text(
                  'No se encontraron cursos',
                  style: TextStyle(
                    fontSize: isCompact ? 13 : (isMobile ? 14 : 16),
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isCompact) ...[
                  SizedBox(height: 8),
                  Text(
                    'Intenta con otros términos de búsqueda',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color: isDark ? Colors.white54 : Colors.black38,
                    ),
                  ),
                ],
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(isCompact ? 6 : 8),
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
                margin: EdgeInsets.only(bottom: isCompact ? 6 : 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
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
                    _buildCursoHeader(
                      curso, 
                      grupos, 
                      isExpanded, 
                      todosGruposSeleccionados, 
                      isDark, 
                      isMobile, 
                      isCompact,
                    ),
                    
                    // Grupos expandibles
                    if (isExpanded)
                      _buildGruposList(grupos, isDark, isMobile, isCompact),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildCursoHeader(
    Curso curso,
    List<Grupo> grupos,
    bool isExpanded,
    bool todosGruposSeleccionados,
    bool isDark,
    bool isMobile,
    bool isCompact,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1976d2).withOpacity(0.15),
            Color(0xFF1565c0).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isCompact ? 10 : 12),
          topRight: Radius.circular(isCompact ? 10 : 12),
          bottomLeft: isExpanded ? Radius.zero : Radius.circular(isCompact ? 10 : 12),
          bottomRight: isExpanded ? Radius.zero : Radius.circular(isCompact ? 10 : 12),
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
            topLeft: Radius.circular(isCompact ? 10 : 12),
            topRight: Radius.circular(isCompact ? 10 : 12),
            bottomLeft: isExpanded ? Radius.zero : Radius.circular(isCompact ? 10 : 12),
            bottomRight: isExpanded ? Radius.zero : Radius.circular(isCompact ? 10 : 12),
          ),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 8 : (isMobile ? 10 : 12)),
            child: Row(
              children: [
                Transform.scale(
                  scale: isCompact ? 0.9 : 1.0,
                  child: Checkbox(
                    value: todosGruposSeleccionados,
                    tristate: true,
                    activeColor: Color(0xFF1976d2),
                    onChanged: (value) => _toggleCurso(curso.id),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(isCompact ? 6 : (isMobile ? 8 : 10)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                    ),
                    borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: isCompact ? 16 : (isMobile ? 18 : 20),
                  ),
                ),
                SizedBox(width: isCompact ? 8 : (isMobile ? 10 : 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curso.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isCompact ? 13 : (isMobile ? 14 : 15),
                          color: Color(0xFF1976d2),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${grupos.length} grupo(s)',
                        style: TextStyle(
                          fontSize: isCompact ? 11 : 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(isCompact ? 4 : 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF1976d2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                  ),
                  child: Icon(
                    isExpanded 
                      ? Icons.expand_less_rounded 
                      : Icons.expand_more_rounded,
                    color: Color(0xFF1976d2),
                    size: isCompact ? 20 : 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGruposList(List<Grupo> grupos, bool isDark, bool isMobile, bool isCompact) {
    return Container(
      padding: EdgeInsets.only(
        left: isCompact ? 12 : (isMobile ? 14 : 16), 
        right: isCompact ? 6 : 8, 
        bottom: isCompact ? 6 : 8, 
        top: 4,
      ),
      child: Column(
        children: grupos.map((grupo) {
          final yaParticipante = _isGrupoYaParticipante(grupo);
          final isSelected = _selectedGrupos.any((g) => g.id == grupo.id);
          
          return Container(
            margin: EdgeInsets.only(top: isCompact ? 6 : 8),
            decoration: BoxDecoration(
              color: yaParticipante 
                ? Colors.grey.withOpacity(0.1)
                : isSelected
                  ? Color(0xFF1976d2).withOpacity(0.1)
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
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
              dense: isCompact,
              title: Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 6 : 8, 
                        vertical: isCompact ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: yaParticipante
                          ? LinearGradient(
                              colors: [Colors.grey[400]!, Colors.grey[500]!],
                            )
                          : LinearGradient(
                              colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                            ),
                        borderRadius: BorderRadius.circular(isCompact ? 4 : 6),
                      ),
                      child: Text(
                        grupo.nombre,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: isCompact ? 11 : 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (yaParticipante) ...[
                    SizedBox(width: isCompact ? 4 : 6),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 4 : 5, 
                          vertical: 2,
                        ),
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
                              size: isCompact ? 8 : 10,
                              color: Colors.orange,
                            ),
                            SizedBox(width: isCompact ? 2 : 3),
                            Flexible(
                              child: Text(
                                'Ya participa',
                                style: TextStyle(
                                  fontSize: isCompact ? 9 : 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: isCompact ? 2 : 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: isCompact ? 12 : 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${grupo.numeroAlumnos} alumnos',
                      style: TextStyle(
                        fontSize: isCompact ? 11 : 12,
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
                borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
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
    );
  }
}

