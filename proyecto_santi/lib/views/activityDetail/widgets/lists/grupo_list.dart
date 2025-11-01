import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/grupo_participante.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

/// Widget especializado para mostrar y gestionar la lista de grupos participantes.
/// 
/// Responsabilidades:
/// - Renderizar lista de grupos con avatares
/// - Mostrar n�mero de alumnos participantes por grupo
/// - Permitir editar inline el n�mero de participantes
/// - Permitir eliminar grupos (si isAdmin)
/// - Bot�n para agregar nuevos grupos
/// - Mostrar total de alumnos participantes
/// - Empty state cuando no hay grupos
class GrupoListWidget extends StatefulWidget {
  final List<GrupoParticipante> grupos;
  final bool isAdminOrSolicitante;
  final VoidCallback onAddGrupo;
  final Function(GrupoParticipante) onRemoveGrupo;
  final Function(GrupoParticipante, int) onUpdateNumeroParticipantes;
  final bool isLoading;

  const GrupoListWidget({
    super.key,
    required this.grupos,
    required this.isAdminOrSolicitante,
    required this.onAddGrupo,
    required this.onRemoveGrupo,
    required this.onUpdateNumeroParticipantes,
    this.isLoading = false,
  });

  @override
  State<GrupoListWidget> createState() => _GrupoListWidgetState();
}

class _GrupoListWidgetState extends State<GrupoListWidget> {
  int? _editingGrupoId;

  int get _totalAlumnosParticipantes {
    return widget.grupos.fold(0, (sum, gp) => sum + gp.numeroParticipantes);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color.fromRGBO(25, 118, 210, 0.25),
                  Color.fromRGBO(21, 101, 192, 0.20),
                ]
              : const [
                  Color.fromRGBO(187, 222, 251, 0.85),
                  Color.fromRGBO(144, 202, 249, 0.75),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? const Color.fromRGBO(0, 0, 0, 0.4) 
                : const Color.fromRGBO(0, 0, 0, 0.15),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
            spreadRadius: -1,
          ),
        ],
        border: Border.all(
          color: isDark 
              ? const Color.fromRGBO(255, 255, 255, 0.1) 
              : const Color.fromRGBO(0, 0, 0, 0.05),
          width: 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Patr�n decorativo de fondo
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: isDark ? 0.03 : 0.02,
              child: Icon(
                Icons.school_rounded,
                size: 120,
                color: Color(0xFF1976d2),
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con t�tulo y bot�n agregar
                _buildHeader(context, isDark, isWeb),
                SizedBox(height: 16),
                // Lista de grupos o empty state
                widget.grupos.isEmpty
                    ? _buildEmptyState(isWeb)
                    : _buildGrupoList(context, isDark, isWeb),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isWeb) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(25, 118, 210, 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: Color(0xFF1976d2),
                  size: isWeb ? 18 : 20.0,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grupos/Cursos Participantes',
                      style: TextStyle(
                        fontSize: isWeb ? 14 : 16.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Color(0xFF1976d2),
                      ),
                    ),
                    if (widget.grupos.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFF1976d2).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Total alumnos: $_totalAlumnosParticipantes',
                            style: TextStyle(
                              fontSize: isWeb ? 11 : 13.0,
                              color: Color(0xFF1976d2),
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
        if (widget.isAdminOrSolicitante)
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF1976d2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: Color(0xFF1976d2),
                size: 20,
              ),
              onPressed: widget.isLoading ? null : widget.onAddGrupo,
              tooltip: 'Agregar grupo',
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(bool isWeb) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            SizedBox(height: 8),
            Text(
              'Sin grupos participantes',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                fontSize: isWeb ? 12 : 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrupoList(BuildContext context, bool isDark, bool isWeb) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Column(
          children: widget.grupos.map((grupoParticipante) {
            return _buildGrupoCard(context, grupoParticipante, isDark, isWeb);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGrupoCard(BuildContext context, GrupoParticipante grupoParticipante, bool isDark, bool isWeb) {
    final isEditing = _editingGrupoId == grupoParticipante.grupo.id;
    
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _buildAvatar(grupoParticipante, isWeb),
        title: Text(
          grupoParticipante.grupo.nombre,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isWeb ? 13 : 15.0,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: isEditing
              ? _buildEditableParticipantes(grupoParticipante)
              : _buildParticipantesInfo(grupoParticipante),
        ),
        trailing: widget.isAdminOrSolicitante
            ? _buildDeleteButton(context, grupoParticipante)
            : null,
      ),
    );
  }

  Widget _buildAvatar(GrupoParticipante grupoParticipante, bool isWeb) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1976d2),
            Color(0xFF42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1976d2).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          grupoParticipante.grupo.nombre.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isWeb ? 16 : 18.0,
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantesInfo(GrupoParticipante grupoParticipante) {
    return InkWell(
      onTap: widget.isAdminOrSolicitante 
        ? () {
            setState(() {
              _editingGrupoId = grupoParticipante.grupo.id;
            });
          }
        : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: widget.isAdminOrSolicitante
              ? Color(0xFF1976d2).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_alt_rounded,
              size: 14,
              color: Color(0xFF1976d2),
            ),
            SizedBox(width: 4),
            Text(
              '${grupoParticipante.numeroParticipantes}/${grupoParticipante.grupo.numeroAlumnos} alumnos',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF1976d2),
                fontWeight: FontWeight.w500,
                decoration: widget.isAdminOrSolicitante 
                  ? TextDecoration.underline 
                  : null,
              ),
            ),
            if (widget.isAdminOrSolicitante)
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.edit_rounded,
                  size: 14,
                  color: Color(0xFF1976d2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableParticipantes(GrupoParticipante grupoParticipante) {
    final controller = TextEditingController(
      text: grupoParticipante.numeroParticipantes.toString(),
    );
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 11),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            onSubmitted: (value) {
              _saveEditedParticipantes(grupoParticipante, value);
            },
          ),
        ),
        SizedBox(width: 2),
        Flexible(
          child: Text(
            '/${grupoParticipante.grupo.numeroAlumnos} al',
            style: TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 4),
        InkWell(
          onTap: () {
            _saveEditedParticipantes(grupoParticipante, controller.text);
          },
          child: Icon(Icons.check, color: Colors.green, size: 16),
        ),
        SizedBox(width: 4),
        InkWell(
          onTap: () {
            setState(() {
              _editingGrupoId = null;
            });
          },
          child: Icon(Icons.close, color: Colors.red, size: 16),
        ),
      ],
    );
  }

  void _saveEditedParticipantes(GrupoParticipante grupoParticipante, String value) {
    final nuevoNumero = int.tryParse(value);
    
    if (nuevoNumero == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingrese un n�mero v�lido')),
      );
      return;
    }
    
    if (nuevoNumero <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El n�mero debe ser mayor a 0')),
      );
      return;
    }
    
    if (nuevoNumero > grupoParticipante.grupo.numeroAlumnos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El n�mero no puede ser mayor a ${grupoParticipante.grupo.numeroAlumnos}',
          ),
        ),
      );
      return;
    }
    
    setState(() {
      _editingGrupoId = null;
    });
    
    widget.onUpdateNumeroParticipantes(grupoParticipante, nuevoNumero);
  }

  Widget _buildDeleteButton(BuildContext context, GrupoParticipante grupoParticipante) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: Colors.red,
          size: 18,
        ),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Confirmar eliminación'),
                  ],
                ),
                content: Text(
                  '¿Estás seguro de que deseas eliminar el grupo "${grupoParticipante.grupo.nombre}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.estadoRechazado,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Eliminar'),
                  ),
                ],
              );
            },
          );

          if (confirmed == true) {
            widget.onRemoveGrupo(grupoParticipante);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Grupo eliminado'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        tooltip: 'Eliminar grupo',
      ),
    );
  }
}
