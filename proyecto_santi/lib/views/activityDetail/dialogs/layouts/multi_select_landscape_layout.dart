import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/models/grupo.dart';
import '../widgets/multi_select_cursos_list.dart';

/// Layout landscape para el diálogo de multi-select de grupos
class MultiSelectLandscapeLayout extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final bool isMobileLandscape;
  final List<Curso> filteredCursos;
  final List<Grupo> allGrupos;
  final List<Grupo> selectedGrupos;
  final List<Grupo> gruposYaSeleccionados;
  final Set<int> expandedCursos;
  final ValueChanged<String> onSearchChanged;
  final Function(int) onToggleCurso;
  final Function(int) onExpandCurso;
  final Function(Grupo, bool) onSelectGrupo;

  const MultiSelectLandscapeLayout({
    Key? key,
    required this.isDark,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.filteredCursos,
    required this.allGrupos,
    required this.selectedGrupos,
    required this.gruposYaSeleccionados,
    required this.expandedCursos,
    required this.onSearchChanged,
    required this.onToggleCurso,
    required this.onExpandCurso,
    required this.onSelectGrupo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                _buildSearchField(),
                if (selectedGrupos.isNotEmpty) ...[
                  SizedBox(height: 10),
                  _buildSelectedCounter(),
                ],
              ],
            ),
          ),
          
          SizedBox(width: 12),
          
          // Columna derecha: Lista de cursos
          Expanded(
            flex: 5,
            child: MultiSelectCursosList(
              filteredCursos: filteredCursos,
              allGrupos: allGrupos,
              selectedGrupos: selectedGrupos,
              gruposYaSeleccionados: gruposYaSeleccionados,
              expandedCursos: expandedCursos,
              isDark: isDark,
              isMobile: isMobile,
              isCompact: true,
              onToggleCurso: onToggleCurso,
              onExpandCurso: onExpandCurso,
              onSelectGrupo: onSelectGrupo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
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
        onChanged: onSearchChanged,
      ),
    );
  }

  Widget _buildSelectedCounter() {
    return Container(
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
              '${selectedGrupos.length} seleccionado(s)',
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
    );
  }
}
