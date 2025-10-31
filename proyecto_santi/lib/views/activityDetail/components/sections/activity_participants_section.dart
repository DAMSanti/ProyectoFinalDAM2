import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/grupo.dart';
import 'package:proyecto_santi/models/grupo_participante.dart';
import 'package:proyecto_santi/services/services.dart';
import '../dialogs/multi_select_profesor_dialog.dart';
import '../dialogs/multi_select_grupo_dialog.dart';
import '../widgets/profesor_list_widget.dart';
import '../widgets/grupo_list_widget.dart';

/// Widget que maneja toda la sección de participantes de una actividad.
/// 
/// Responsabilidades:
/// - Coordinar profesores y grupos participantes
/// - Gestionar diálogos de selección múltiple
/// - Layout responsivo (2 columnas en desktop, 1 columna en móvil)
/// - Delegar renderizado a widgets especializados
class ActivityParticipantsSection extends StatefulWidget {
  final List<Profesor> profesoresParticipantes;
  final List<GrupoParticipante> gruposParticipantes;
  final bool isAdminOrSolicitante;
  final Function(Map<String, dynamic>)? onDataChanged;
  final ProfesorService profesorService;
  final CatalogoService catalogoService;

  const ActivityParticipantsSection({
    super.key,
    required this.profesoresParticipantes,
    required this.gruposParticipantes,
    required this.isAdminOrSolicitante,
    required this.profesorService,
    required this.catalogoService,
    this.onDataChanged,
  });

  @override
  State<ActivityParticipantsSection> createState() => _ActivityParticipantsSectionState();
}

class _ActivityParticipantsSectionState extends State<ActivityParticipantsSection> {
  late List<Profesor> _profesoresParticipantes;
  late List<GrupoParticipante> _gruposParticipantes;
  bool _loadingProfesores = false;
  bool _loadingGrupos = false;

  @override
  void initState() {
    super.initState();
    _profesoresParticipantes = List.from(widget.profesoresParticipantes);
    _gruposParticipantes = List.from(widget.gruposParticipantes);
  }

  @override
  void didUpdateWidget(ActivityParticipantsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profesoresParticipantes != widget.profesoresParticipantes) {
      _profesoresParticipantes = List.from(widget.profesoresParticipantes);
    }
    if (oldWidget.gruposParticipantes != widget.gruposParticipantes) {
      _gruposParticipantes = List.from(widget.gruposParticipantes);
    }
  }

  void _notifyChanges() {
    if (widget.onDataChanged != null) {
      widget.onDataChanged!({
        'profesoresParticipantes': _profesoresParticipantes,
        'gruposParticipantes': _gruposParticipantes,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Layout responsivo: dos columnas en pantallas anchas, una columna en móvil
        return constraints.maxWidth > 800
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ProfesorListWidget(
                      profesores: _profesoresParticipantes,
                      isAdminOrSolicitante: widget.isAdminOrSolicitante,
                      isLoading: _loadingProfesores,
                      onAddProfesor: () => _showAddProfesorDialog(context),
                      onRemoveProfesor: (profesor) {
                        setState(() {
                          _profesoresParticipantes.removeWhere((p) => p.uuid == profesor.uuid);
                        });
                        _notifyChanges();
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GrupoListWidget(
                      grupos: _gruposParticipantes,
                      isAdminOrSolicitante: widget.isAdminOrSolicitante,
                      isLoading: _loadingGrupos,
                      onAddGrupo: () => _showAddGrupoDialog(context),
                      onRemoveGrupo: (grupoParticipante) {
                        setState(() {
                          _gruposParticipantes.removeWhere(
                            (gp) => gp.grupo.id == grupoParticipante.grupo.id
                          );
                        });
                        _notifyChanges();
                      },
                      onUpdateNumeroParticipantes: (grupoParticipante, nuevoNumero) {
                        setState(() {
                          grupoParticipante.numeroParticipantes = nuevoNumero;
                        });
                        _notifyChanges();
                      },
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  ProfesorListWidget(
                    profesores: _profesoresParticipantes,
                    isAdminOrSolicitante: widget.isAdminOrSolicitante,
                    isLoading: _loadingProfesores,
                    onAddProfesor: () => _showAddProfesorDialog(context),
                    onRemoveProfesor: (profesor) {
                      setState(() {
                        _profesoresParticipantes.removeWhere((p) => p.uuid == profesor.uuid);
                      });
                      _notifyChanges();
                    },
                  ),
                  SizedBox(height: 16),
                  GrupoListWidget(
                    grupos: _gruposParticipantes,
                    isAdminOrSolicitante: widget.isAdminOrSolicitante,
                    isLoading: _loadingGrupos,
                    onAddGrupo: () => _showAddGrupoDialog(context),
                    onRemoveGrupo: (grupoParticipante) {
                      setState(() {
                        _gruposParticipantes.removeWhere(
                          (gp) => gp.grupo.id == grupoParticipante.grupo.id
                        );
                      });
                      _notifyChanges();
                    },
                    onUpdateNumeroParticipantes: (grupoParticipante, nuevoNumero) {
                      setState(() {
                        grupoParticipante.numeroParticipantes = nuevoNumero;
                      });
                      _notifyChanges();
                    },
                  ),
                ],
              );
      },
    );
  }

  // Diálogo para agregar profesores
  void _showAddProfesorDialog(BuildContext context) async {
    setState(() => _loadingProfesores = true);
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final profesores = await widget.profesorService.fetchProfesores();
      
      if (!mounted) return;
      
      final selectedProfesores = await showDialog<List<Profesor>>(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectProfesorDialog(
            profesores: profesores,
            profesoresYaSeleccionados: _profesoresParticipantes,
          );
        },
      );
      
      if (selectedProfesores != null && selectedProfesores.isNotEmpty) {
        setState(() {
          for (var profesor in selectedProfesores) {
            if (!_profesoresParticipantes.any((p) => p.uuid == profesor.uuid)) {
              _profesoresParticipantes.add(profesor);
            }
          }
        });
        
        _notifyChanges();
        
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('${selectedProfesores.length} profesor(es) agregado(s)')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error al cargar profesores: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingProfesores = false);
      }
    }
  }

  // Diálogo para agregar grupos
  void _showAddGrupoDialog(BuildContext context) async {
    setState(() => _loadingGrupos = true);
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final cursos = await widget.catalogoService.fetchCursos();
      final todosLosGrupos = await widget.catalogoService.fetchGrupos();
      
      if (!mounted) return;
      
      final gruposSeleccionados = await showDialog<List<Grupo>>(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectGrupoDialog(
            cursos: cursos,
            grupos: todosLosGrupos,
            gruposYaSeleccionados: _gruposParticipantes.map((gp) => gp.grupo).toList(),
          );
        },
      );
      
      if (gruposSeleccionados != null && gruposSeleccionados.isNotEmpty) {
        setState(() {
          for (var grupo in gruposSeleccionados) {
            if (!_gruposParticipantes.any((gp) => gp.grupo.id == grupo.id)) {
              _gruposParticipantes.add(GrupoParticipante(
                grupo: grupo,
                numeroParticipantes: grupo.numeroAlumnos,
              ));
            }
          }
        });
        
        _notifyChanges();
        
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('${gruposSeleccionados.length} grupo(s) agregado(s)')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error al cargar grupos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingGrupos = false);
      }
    }
  }
}
