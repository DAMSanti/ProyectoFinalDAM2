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
    return AlertDialog(
      title: Text('Agregar Grupos/Cursos Participantes'),
      content: Container(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            // Buscador
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar curso o grupo...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16),
            
            // Contador de seleccionados
            if (_selectedGrupos.isNotEmpty)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '${_selectedGrupos.length} grupo(s) seleccionado(s)',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 8),
            
            // Lista de cursos con grupos expandibles
            Expanded(
              child: _filteredCursos.isEmpty
                  ? Center(child: Text('No se encontraron cursos'))
                  : ListView.builder(
                      itemCount: _filteredCursos.length,
                      itemBuilder: (context, index) {
                        final curso = _filteredCursos[index];
                        final grupos = _getGruposDeCurso(curso.id);
                        final isExpanded = _expandedCursos.contains(curso.id);
                        final todosGruposSeleccionados = grupos.isNotEmpty && grupos.every(
                          (g) => _selectedGrupos.any((sg) => sg.id == g.id) || _isGrupoYaParticipante(g)
                        );
                        
                        return Column(
                          children: [
                            // Curso con checkbox para seleccionar todos sus grupos
                            Card(
                              color: Colors.blue.withOpacity(0.1),
                              child: CheckboxListTile(
                                title: Text(
                                  curso.nombre,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('${grupos.length} grupo(s)'),
                                value: todosGruposSeleccionados,
                                tristate: true,
                                onChanged: (value) => _toggleCurso(curso.id),
                                secondary: IconButton(
                                  icon: Icon(
                                    isExpanded ? Icons.expand_less : Icons.expand_more,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedCursos.remove(curso.id);
                                      } else {
                                        _expandedCursos.add(curso.id);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            // Grupos del curso (expandibles)
                            if (isExpanded)
                              Padding(
                                padding: EdgeInsets.only(left: 32),
                                child: Column(
                                  children: grupos.map((grupo) {
                                    final yaParticipante = _isGrupoYaParticipante(grupo);
                                    final isSelected = _selectedGrupos.any((g) => g.id == grupo.id);
                                    
                                    return CheckboxListTile(
                                      title: Text(grupo.nombre),
                                      subtitle: Text(
                                        '${grupo.numeroAlumnos} alumnos${yaParticipante ? " - Ya participa" : ""}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: yaParticipante ? Colors.orange : null,
                                        ),
                                      ),
                                      value: isSelected,
                                      enabled: !yaParticipante,
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
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedGrupos.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selectedGrupos),
          child: Text('Agregar (${_selectedGrupos.length})'),
        ),
      ],
    );
  }
}
