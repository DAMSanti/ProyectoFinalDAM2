import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/models/grupo.dart';
import '../widgets/multi_select_cursos_list.dart';

/// Layout portrait para el diálogo de multi-select de grupos
class MultiSelectPortraitLayout extends StatelessWidget {
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

  const MultiSelectPortraitLayout({
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
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        children: [
          _buildSearchField(),
          SizedBox(height: isMobile ? 12 : 16),
          
          if (selectedGrupos.isNotEmpty) _buildSelectedCounter(),
          SizedBox(height: isMobile ? 8 : 12),
          
          Expanded(
            child: MultiSelectCursosList(
              filteredCursos: filteredCursos,
              allGrupos: allGrupos,
              selectedGrupos: selectedGrupos,
              gruposYaSeleccionados: gruposYaSeleccionados,
              expandedCursos: expandedCursos,
              isDark: isDark,
              isMobile: isMobile,
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
        onChanged: onSearchChanged,
      ),
    );
  }

  Widget _buildSelectedCounter() {
    return Container(
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
              '${selectedGrupos.length} grupo(s) seleccionado(s) para agregar',
              style: TextStyle(
                color: Color(0xFF1976d2),
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 13 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
