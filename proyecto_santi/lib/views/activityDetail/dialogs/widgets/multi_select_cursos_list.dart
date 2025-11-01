import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/models/grupo.dart';
import 'package:proyecto_santi/tema/tema.dart';

/// Widget para mostrar la lista de cursos y sus grupos en el multi-select
class MultiSelectCursosList extends StatelessWidget {
  final List<Curso> filteredCursos;
  final List<Grupo> allGrupos;
  final List<Grupo> selectedGrupos;
  final List<Grupo> gruposYaSeleccionados;
  final Set<int> expandedCursos;
  final bool isDark;
  final bool isMobile;
  final bool isCompact;
  final Function(int) onToggleCurso;
  final Function(int) onExpandCurso;
  final Function(Grupo, bool) onSelectGrupo;

  const MultiSelectCursosList({
    Key? key,
    required this.filteredCursos,
    required this.allGrupos,
    required this.selectedGrupos,
    required this.gruposYaSeleccionados,
    required this.expandedCursos,
    required this.isDark,
    required this.isMobile,
    this.isCompact = false,
    required this.onToggleCurso,
    required this.onExpandCurso,
    required this.onSelectGrupo,
  }) : super(key: key);

  List<Grupo> _getGruposDeCurso(int cursoId) {
    return allGrupos.where((g) => g.cursoId == cursoId).toList();
  }

  bool _isGrupoYaParticipante(Grupo grupo) {
    return gruposYaSeleccionados.any((g) => g.id == grupo.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
            ? Colors.white.withValues(alpha: 0.1) 
            : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: filteredCursos.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: EdgeInsets.all(isCompact ? 6 : 8),
            itemCount: filteredCursos.length,
            itemBuilder: (context, index) => _buildCursoItem(filteredCursos[index]),
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 12 : (isMobile ? 16 : 20)),
            decoration: BoxDecoration(
              color: AppColors.primaryOpacity10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: isCompact ? 32 : (isMobile ? 40 : 48),
              color: AppColors.primaryOpacity50,
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
    );
  }

  Widget _buildCursoItem(Curso curso) {
    final grupos = _getGruposDeCurso(curso.id);
    final isExpanded = expandedCursos.contains(curso.id);
    final todosGruposSeleccionados = grupos.isNotEmpty && grupos.every(
      (g) => selectedGrupos.any((sg) => sg.id == g.id) || _isGrupoYaParticipante(g)
    );
    final algunoSeleccionado = grupos.any(
      (g) => selectedGrupos.any((sg) => sg.id == g.id)
    );
    
    return Container(
      margin: EdgeInsets.only(bottom: isCompact ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
        border: Border.all(
          color: algunoSeleccionado
            ? AppColors.primaryOpacity50
            : Colors.transparent,
          width: algunoSeleccionado ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          _buildCursoHeader(curso, grupos, isExpanded, todosGruposSeleccionados),
          if (isExpanded) _buildGruposList(grupos),
        ],
      ),
    );
  }

  Widget _buildCursoHeader(
    Curso curso,
    List<Grupo> grupos,
    bool isExpanded,
    bool todosGruposSeleccionados,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOpacity15,
            AppColors.primaryDarkOpacity10,
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
          onTap: () => onExpandCurso(curso.id),
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
                    activeColor: AppColors.primary,
                    onChanged: (value) => onToggleCurso(curso.id),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(isCompact ? 6 : (isMobile ? 8 : 10)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
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
                          color: AppColors.primary,
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
                    color: AppColors.primaryOpacity10,
                    borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                  ),
                  child: Icon(
                    isExpanded 
                      ? Icons.expand_less_rounded 
                      : Icons.expand_more_rounded,
                    color: AppColors.primary,
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

  Widget _buildGruposList(List<Grupo> grupos) {
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
          final isSelected = selectedGrupos.any((g) => g.id == grupo.id);
          
          return Container(
            margin: EdgeInsets.only(top: isCompact ? 6 : 8),
            decoration: BoxDecoration(
              color: yaParticipante 
                ? Colors.grey.withValues(alpha: 0.1)
                : isSelected
                  ? AppColors.primaryOpacity10
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
              border: Border.all(
                color: yaParticipante
                  ? Colors.grey.withValues(alpha: 0.3)
                  : isSelected
                    ? AppColors.primaryOpacity40
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
                              colors: AppColors.primaryGradient,
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
                          color: AppColors.estadoPendiente.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.estadoPendiente.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: isCompact ? 8 : 10,
                              color: AppColors.estadoPendiente,
                            ),
                            SizedBox(width: isCompact ? 2 : 3),
                            Flexible(
                              child: Text(
                                'Ya participa',
                                style: TextStyle(
                                  fontSize: isCompact ? 9 : 10,
                                  color: AppColors.estadoPendiente,
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
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
              ),
              onChanged: yaParticipante
                  ? null
                  : (bool? value) => onSelectGrupo(grupo, value ?? false),
            ),
          );
        }).toList(),
      ),
    );
  }
}
