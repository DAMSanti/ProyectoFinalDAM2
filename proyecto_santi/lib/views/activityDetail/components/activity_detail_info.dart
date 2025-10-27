import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/departamento.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/models/grupo.dart';
import 'package:proyecto_santi/models/grupo_participante.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'dart:ui' as ui;

class ActivityDetailInfo extends StatefulWidget {
  final Actividad actividad;
  final bool isAdminOrSolicitante;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final VoidCallback showImagePicker;
  final Function(int) removeSelectedImage;
  final Function(int)? removeApiImage; // Nueva función para eliminar fotos de la API
  final Function(Map<String, dynamic>)? onActivityDataChanged; // Callback para notificar cambios

  const ActivityDetailInfo({
    super.key,
    required this.actividad,
    required this.isAdminOrSolicitante,
    required this.imagesActividad,
    required this.selectedImages,
    required this.showImagePicker,
    required this.removeSelectedImage,
    this.removeApiImage, // Opcional
    this.onActivityDataChanged, // Opcional
  });

  @override
  State<ActivityDetailInfo> createState() => _ActivityDetailInfoState();
}

class _ActivityDetailInfoState extends State<ActivityDetailInfo> {
  final ApiService _apiService = ApiService();
  List<Profesor> _profesoresParticipantes = [];
  List<GrupoParticipante> _gruposParticipantes = [];
  List<Profesor> _profesoresParticipantesOriginales = [];
  List<GrupoParticipante> _gruposParticipantesOriginales = [];
  bool _loadingProfesores = false;
  bool _loadingGrupos = false;
  int? _editingGrupoId; // ID del grupo que se está editando
  
  // Variables para el folleto
  String? _folletoFileName;
  String? _folletoFilePath;
  bool _folletoChanged = false;
  bool _folletoMarkedForDeletion = false;

  int get _totalAlumnosParticipantes {
    return _gruposParticipantes.fold(0, (sum, gp) => sum + gp.numeroParticipantes);
  }
  
  @override
  void initState() {
    super.initState();
    // Cargar participantes desde la base de datos
    _loadParticipantes();
  }
  
  Future<void> _loadParticipantes() async {
    try {
      print('[PARTICIPANTES] Cargando participantes para actividad ${widget.actividad.id}');
      
      // Cargar profesores participantes
      final profesoresIds = await _apiService.fetchProfesoresParticipantes(widget.actividad.id);
      print('[PARTICIPANTES] IDs de profesores participantes: $profesoresIds');
      
      final todosLosProfesores = await _apiService.fetchProfesores();
      print('[PARTICIPANTES] Total profesores en sistema: ${todosLosProfesores.length}');
      
      // Cargar grupos participantes
      final gruposData = await _apiService.fetchGruposParticipantes(widget.actividad.id);
      print('[PARTICIPANTES] Grupos participantes data: $gruposData');
      
      final todosLosGrupos = await _apiService.fetchGrupos();
      print('[PARTICIPANTES] Total grupos en sistema: ${todosLosGrupos.length}');
      
      setState(() {
        // Filtrar profesores que participan - convertir UUIDs a lowercase para comparar
        _profesoresParticipantes = todosLosProfesores
            .where((p) => profesoresIds.any((id) => id.toLowerCase() == p.uuid.toLowerCase()))
            .toList();
        
        print('[PARTICIPANTES] Profesores participantes filtrados: ${_profesoresParticipantes.length}');
        
        // Construir lista de grupos participantes
        _gruposParticipantes = gruposData.map((data) {
          final grupoId = data['grupoId'] as int;
          final numParticipantes = data['numeroParticipantes'] as int;
          final grupo = todosLosGrupos.firstWhere((g) => g.id == grupoId);
          
          return GrupoParticipante(
            grupo: grupo,
            numeroParticipantes: numParticipantes,
          );
        }).toList();
        
        print('[PARTICIPANTES] Grupos participantes construidos: ${_gruposParticipantes.length}');
        
        // Guardar copias originales
        _profesoresParticipantesOriginales = List.from(_profesoresParticipantes);
        _gruposParticipantesOriginales = _gruposParticipantes.map((gp) => 
          GrupoParticipante(
            grupo: gp.grupo,
            numeroParticipantes: gp.numeroParticipantes,
          )
        ).toList();
      });
      
      print('[PARTICIPANTES] Participantes cargados exitosamente');
    } catch (e) {
      print('[ERROR] Error cargando participantes: $e');
      print('[ERROR] Stack trace: ${StackTrace.current}');
      // Inicializar listas vacías en caso de error
      setState(() {
        _profesoresParticipantesOriginales = [];
        _gruposParticipantesOriginales = [];
      });
    }
  }
  
  void _notifyChanges() {
    if (widget.onActivityDataChanged != null) {
      widget.onActivityDataChanged!({
        'profesoresParticipantes': _profesoresParticipantes,
        'gruposParticipantes': _gruposParticipantes,
      });
    }
  }

  Future<void> _selectFolleto() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb, // Importante para web
      );

      if (result != null) {
        final file = result.files.single;
        setState(() {
          _folletoFileName = file.name;
          // En web, usar bytes en lugar de path
          if (kIsWeb) {
            _folletoFilePath = null; // No disponible en web
            // Guardar bytes para subir después
            if (file.bytes != null) {
              // Notificar con los bytes directamente
              if (widget.onActivityDataChanged != null) {
                widget.onActivityDataChanged!({
                  'folletoFileName': file.name,
                  'folletoBytes': file.bytes,
                });
              }
            }
          } else {
            _folletoFilePath = file.path;
            if (widget.onActivityDataChanged != null) {
              widget.onActivityDataChanged!({
                'folletoFileName': file.name,
                'folletoFilePath': file.path,
              });
            }
          }
          _folletoChanged = true;
        });
      }
    } catch (e) {
      print('[ERROR] Error al seleccionar folleto: $e');
    }
  }

  void _deleteFolleto() {
    setState(() {
      _folletoMarkedForDeletion = true;
      _folletoFileName = null;
      _folletoFilePath = null;
      
      // Notificar el cambio para activar el botón guardar
      if (widget.onActivityDataChanged != null) {
        widget.onActivityDataChanged!({
          'deleteFolleto': true,
        });
      }
    });
  }

  String _extractFileName(String url) {
    // Extraer el nombre del archivo de la URL
    final parts = url.split('/');
    if (parts.isEmpty) return 'folleto.pdf';
    
    final fileName = parts.last;
    
    // Si el nombre tiene formato "timestamp_nombreOriginal.pdf", extraer solo el nombre original
    final timestampPattern = RegExp(r'^\d+_(.+)$');
    final match = timestampPattern.firstMatch(fileName);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              _buildHeader(context, constraints),
              SizedBox(height: 16),
              _buildImages(context, constraints),
              SizedBox(height: 16),
              _buildParticipantes(context, constraints),
              SizedBox(height: 16),
              _buildComentarios(context, constraints)
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints) {
    final isWeb =
        kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    // Parsear fechas y horas
    final DateTime fechaInicio = DateTime.parse(widget.actividad.fini);
    final DateTime fechaFin = DateTime.parse(widget.actividad.ffin);
    
    // Extraer solo la parte de fecha (sin hora) para comparar
    final fechaInicioSolo = DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day);
    final fechaFinSolo = DateTime(fechaFin.year, fechaFin.month, fechaFin.day);
    
    // Formatear fechas
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final String formattedStartDate = dateFormat.format(fechaInicio);
    final String formattedEndDate = dateFormat.format(fechaFin);
    
    // Formatear horas (hini y hfin vienen como "HH:mm" o "HH:mm:ss")
    String horaInicio = widget.actividad.hini;
    String horaFin = widget.actividad.hfin;
    
    // Si las horas tienen formato HH:mm:ss, quitar los segundos
    if (horaInicio.length > 5 && horaInicio.substring(5, 6) == ':') {
      horaInicio = horaInicio.substring(0, 5);
    }
    if (horaFin.length > 5 && horaFin.substring(5, 6) == ':') {
      horaFin = horaFin.substring(0, 5);
    }
    
    // Construir texto según si es el mismo día o días diferentes
    final String dateText = fechaInicioSolo == fechaFinSolo
        ? '$formattedStartDate $horaInicio'
        : '$formattedStartDate $horaInicio - $formattedEndDate $horaFin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.actividad.titulo,
                style: TextStyle(
                    fontSize: !isWeb ? 20.dg : 7.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF1976d2)),
              onPressed: () => _showEditDialog(context),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Descripción y Fecha en la misma línea
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción con icono (izquierda)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.description, color: Color(0xFF1976d2), size: !isWeb ? 16.dg : 5.sp),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.actividad.descripcion ?? 'Sin descripción',
                      style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Fecha con icono (derecha)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF1976d2), size: !isWeb ? 16.dg : 5.sp),
                SizedBox(width: 8),
                Text(
                  dateText,
                  style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        // Solicitante y Departamento
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Solicitante con icono (izquierda)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, color: Color(0xFF1976d2), size: !isWeb ? 16.dg : 5.sp),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.actividad.solicitante != null 
                          ? '${widget.actividad.solicitante!.nombre} ${widget.actividad.solicitante!.apellidos}'
                          : 'Sin solicitante',
                      style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Departamento con icono (derecha)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.business, color: Color(0xFF1976d2), size: !isWeb ? 16.dg : 5.sp),
                SizedBox(width: 8),
                Text(
                  widget.actividad.departamento?.nombre ?? 'Sin departamento',
                  style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        // Folleto (izquierda) y Estado (derecha)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Folleto con icono (izquierda)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.picture_as_pdf, color: Color(0xFF1976d2), size: !isWeb ? 16.dg : 5.sp),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      // Mostrar "Sin folleto" si está marcado para eliminación o no hay folleto
                      _folletoMarkedForDeletion 
                          ? 'Sin folleto' 
                          : (_folletoFileName ?? 
                              (widget.actividad.urlFolleto != null 
                                  ? _extractFileName(widget.actividad.urlFolleto!)
                                  : 'Sin folleto')),
                      style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.isAdminOrSolicitante) ...[
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.upload_file, color: Color(0xFF1976d2)),
                      iconSize: !isWeb ? 16.dg : 5.sp,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: _selectFolleto,
                      tooltip: 'Subir folleto PDF',
                    ),
                    // Botón X para eliminar folleto (solo si hay folleto)
                    if (!_folletoMarkedForDeletion && 
                        (_folletoFileName != null || widget.actividad.urlFolleto != null)) ...[
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        iconSize: !isWeb ? 16.dg : 5.sp,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: _deleteFolleto,
                        tooltip: 'Eliminar folleto',
                      ),
                    ],
                  ],
                ],
              ),
            ),
            SizedBox(width: 16),
            // Estado con icono (derecha)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF1976d2), size: !isWeb ? 16.dg : 5.sp),
                SizedBox(width: 8),
                Text(
                  widget.actividad.estado,
                  style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditActivityDialog(
          actividad: widget.actividad,
          onSave: (updatedData) {
            print('Datos actualizados: $updatedData');
            
            // Notificar al padre que hubo cambios
            if (widget.onActivityDataChanged != null) {
              widget.onActivityDataChanged!(updatedData);
            }
          },
        );
      },
    );
  }

  Widget _buildImages(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotos de la Actividad',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        _HorizontalImageScroller(
          constraints: constraints,
          isAdminOrSolicitante: widget.isAdminOrSolicitante,
          showImagePicker: widget.showImagePicker,
          imagesActividad: widget.imagesActividad,
          selectedImages: widget.selectedImages,
          onDeleteImage: (index) => _showDeleteConfirmationDialog(context, index),
          onDeleteApiImage: widget.removeApiImage, // Pasar la función
        ),
      ],
    );
  }

  Widget _buildParticipantes(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participantes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        // Layout responsivo: dos columnas en pantallas anchas, una columna en móvil
        constraints.maxWidth > 800
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildProfesoresParticipantes(context),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildGruposParticipantes(context),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildProfesoresParticipantes(context),
                  SizedBox(height: 16),
                  _buildGruposParticipantes(context),
                ],
              ),
      ],
    );
  }

  Widget _buildProfesoresParticipantes(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profesores Participantes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (widget.isAdminOrSolicitante)
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF1976d2)),
                  onPressed: _loadingProfesores ? null : () {
                    _showAddProfesorDialog(context);
                  },
                  tooltip: 'Agregar profesor',
                ),
            ],
          ),
          SizedBox(height: 12),
          // Lista de profesores participantes
          _profesoresParticipantes.isEmpty
              ? Text(
                  'Sin profesores participantes',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      children: _profesoresParticipantes.map((profesor) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF1976d2),
                          child: Text(
                            profesor.nombre.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text('${profesor.nombre} ${profesor.apellidos}'),
                        subtitle: Text(profesor.correo, style: TextStyle(fontSize: 12)),
                        trailing: widget.isAdminOrSolicitante
                            ? IconButton(
                                icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _profesoresParticipantes.removeWhere((p) => p.uuid == profesor.uuid);
                                  });
                                  _notifyChanges();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Profesor eliminado')),
                                  );
                                },
                                tooltip: 'Eliminar profesor',
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildGruposParticipantes(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grupos/Cursos Participantes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (_gruposParticipantes.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Total alumnos: $_totalAlumnosParticipantes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.isAdminOrSolicitante)
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF1976d2)),
                  onPressed: _loadingGrupos ? null : () {
                    _showAddGrupoDialog(context);
                  },
                  tooltip: 'Agregar grupo',
                ),
            ],
          ),
          SizedBox(height: 12),
          // Lista de grupos participantes
          _gruposParticipantes.isEmpty
              ? Text(
                  'Sin grupos participantes',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      children: _gruposParticipantes.map((grupoParticipante) {
                    final isEditing = _editingGrupoId == grupoParticipante.grupo.id;
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF1976d2),
                          child: Text(
                            grupoParticipante.grupo.nombre.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(grupoParticipante.grupo.nombre),
                        subtitle: isEditing
                            ? _buildEditableParticipantes(grupoParticipante)
                            : InkWell(
                                onTap: widget.isAdminOrSolicitante 
                                  ? () {
                                      setState(() {
                                        _editingGrupoId = grupoParticipante.grupo.id;
                                      });
                                    }
                                  : null,
                                child: Row(
                                  children: [
                                    Text(
                                      '${grupoParticipante.numeroParticipantes}/${grupoParticipante.grupo.numeroAlumnos} alumnos',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.isAdminOrSolicitante 
                                          ? Colors.blue 
                                          : null,
                                        decoration: widget.isAdminOrSolicitante 
                                          ? TextDecoration.underline 
                                          : null,
                                      ),
                                    ),
                                    if (widget.isAdminOrSolicitante)
                                      Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: Icon(Icons.edit, size: 14, color: Colors.blue),
                                      ),
                                  ],
                                ),
                              ),
                        trailing: widget.isAdminOrSolicitante
                            ? IconButton(
                                icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _gruposParticipantes.removeWhere(
                                      (gp) => gp.grupo.id == grupoParticipante.grupo.id
                                    );
                                  });
                                  _notifyChanges();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Grupo eliminado')),
                                  );
                                },
                                tooltip: 'Eliminar grupo',
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _showAddProfesorDialog(BuildContext context) async {
    setState(() => _loadingProfesores = true);
    
    try {
      // Cargar todos los profesores desde la API
      final profesores = await _apiService.fetchProfesores();
      
      if (!mounted) return;
      
      // Mostrar diálogo con selección múltiple
      final selectedProfesores = await showDialog<List<Profesor>>(
        context: context,
        builder: (BuildContext context) {
          return _MultiSelectProfesorDialog(
            profesores: profesores,
            profesoresYaSeleccionados: _profesoresParticipantes,
          );
        },
      );
      
      if (selectedProfesores != null && selectedProfesores.isNotEmpty) {
        setState(() {
          // Agregar solo los profesores que no están ya en la lista
          for (var profesor in selectedProfesores) {
            if (!_profesoresParticipantes.any((p) => p.uuid == profesor.uuid)) {
              _profesoresParticipantes.add(profesor);
            }
          }
        });
        
        _notifyChanges();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${selectedProfesores.length} profesor(es) agregado(s)')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar profesores: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingProfesores = false);
      }
    }
  }

  void _showAddGrupoDialog(BuildContext context) async {
    setState(() => _loadingGrupos = true);
    
    try {
      // Cargar todos los cursos y grupos desde la API
      final cursos = await _apiService.fetchCursos();
      final todosLosGrupos = await _apiService.fetchGrupos();
      
      if (!mounted) return;
      
      // Mostrar diálogo con selección de cursos/grupos
      final gruposSeleccionados = await showDialog<List<Grupo>>(
        context: context,
        builder: (BuildContext context) {
          return _MultiSelectGrupoDialog(
            cursos: cursos,
            grupos: todosLosGrupos,
            gruposYaSeleccionados: _gruposParticipantes.map((gp) => gp.grupo).toList(),
          );
        },
      );
      
      if (gruposSeleccionados != null && gruposSeleccionados.isNotEmpty) {
        setState(() {
          // Agregar los grupos seleccionados con el número total de alumnos por defecto
          for (var grupo in gruposSeleccionados) {
            if (!_gruposParticipantes.any((gp) => gp.grupo.id == grupo.id)) {
              _gruposParticipantes.add(GrupoParticipante(
                grupo: grupo,
                numeroParticipantes: grupo.numeroAlumnos, // Por defecto, todos los alumnos
              ));
            }
          }
        });
        
        _notifyChanges();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${gruposSeleccionados.length} grupo(s) agregado(s)')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar grupos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingGrupos = false);
      }
    }
  }

  Widget _buildEditableParticipantes(GrupoParticipante grupoParticipante) {
    final controller = TextEditingController(
      text: grupoParticipante.numeroParticipantes.toString(),
    );
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 12),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
        Text(
          '/${grupoParticipante.grupo.numeroAlumnos} alumnos',
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.check, color: Colors.green, size: 16),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          onPressed: () {
            _saveEditedParticipantes(grupoParticipante, controller.text);
          },
          tooltip: 'Guardar',
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.red, size: 16),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          onPressed: () {
            setState(() {
              _editingGrupoId = null;
            });
          },
          tooltip: 'Cancelar',
        ),
      ],
    );
  }

  void _saveEditedParticipantes(GrupoParticipante grupoParticipante, String value) {
    final nuevoNumero = int.tryParse(value);
    
    if (nuevoNumero == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingrese un número válido')),
      );
      return;
    }
    
    if (nuevoNumero <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El número debe ser mayor a 0')),
      );
      return;
    }
    
    if (nuevoNumero > grupoParticipante.grupo.numeroAlumnos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El número no puede ser mayor a ${grupoParticipante.grupo.numeroAlumnos}',
          ),
        ),
      );
      return;
    }
    
    setState(() {
      grupoParticipante.numeroParticipantes = nuevoNumero;
      _editingGrupoId = null;
    });
    
    _notifyChanges();
  }

  Widget _buildComentarios(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción de la Actividad',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(widget.actividad.comentarios ?? 'Sin comentarios'),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar imagen'),
          content: Text('¿Está seguro que quiere eliminar la imagen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                widget.removeSelectedImage(index); // Eliminar la imagen
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}

// Widget para mostrar la imagen con botón de eliminar en hover
class _ImageWithDeleteButton extends StatefulWidget {
  final XFile image;
  final double maxHeight;
  final VoidCallback onDelete;

  const _ImageWithDeleteButton({
    required this.image,
    required this.maxHeight,
    required this.onDelete,
  });

  @override
  _ImageWithDeleteButtonState createState() => _ImageWithDeleteButtonState();
}

class _ImageWithDeleteButtonState extends State<_ImageWithDeleteButton> {
  bool _isHovering = false;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    try {
      final bytes = await widget.image.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      setState(() {
        _aspectRatio = image.width / image.height;
      });
    } catch (e) {
      print('Error loading image dimensions: $e');
      setState(() {
        _aspectRatio = 1.0; // Default to square if error
      });
    }
  }

  Future<Widget> _buildImageWidget(XFile image) async {
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      return Image.memory(bytes, fit: BoxFit.contain);
    } else {
      return Image.file(File(image.path), fit: BoxFit.contain);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_aspectRatio == null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        width: widget.maxHeight, // Usar un ancho temporal
        height: widget.maxHeight,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final width = widget.maxHeight * _aspectRatio!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        width: width,
        height: widget.maxHeight,
        child: Stack(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: FutureBuilder<Widget>(
                future: _buildImageWidget(widget.image),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
            // Botón de eliminar (solo visible en hover)
            if (_isHovering)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget para mostrar imágenes de red con aspect ratio y botón de eliminar
class _NetworkImageWithDelete extends StatefulWidget {
  final String imageUrl;
  final double maxHeight;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const _NetworkImageWithDelete({
    required this.imageUrl,
    required this.maxHeight,
    this.onDelete,
    this.showDeleteButton = false,
  });

  @override
  _NetworkImageWithDeleteState createState() => _NetworkImageWithDeleteState();
}

class _NetworkImageWithDeleteState extends State<_NetworkImageWithDelete> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        height: widget.maxHeight,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                widget.imageUrl,
                key: ValueKey(widget.imageUrl),
                fit: BoxFit.contain,
                headers: {
                  'Access-Control-Allow-Origin': '*',
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
                    width: widget.maxHeight,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: widget.maxHeight,
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(height: 8),
                        Text(
                          'Error al cargar imagen',
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Botón de eliminar (solo visible en hover y si showDeleteButton es true)
            if (_isHovering && widget.showDeleteButton && widget.onDelete != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget con estado para scroll horizontal
class _HorizontalImageScroller extends StatefulWidget {
  final BoxConstraints constraints;
  final bool isAdminOrSolicitante;
  final VoidCallback showImagePicker;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final Function(int) onDeleteImage;
  final Function(int)? onDeleteApiImage; // Nueva función

  const _HorizontalImageScroller({
    required this.constraints,
    required this.isAdminOrSolicitante,
    required this.showImagePicker,
    required this.imagesActividad,
    required this.selectedImages,
    required this.onDeleteImage,
    this.onDeleteApiImage, // Opcional
  });

  @override
  _HorizontalImageScrollerState createState() => _HorizontalImageScrollerState();
}

class _HorizontalImageScrollerState extends State<_HorizontalImageScroller> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.constraints.maxWidth,
      height: 200.0,
      child: Row(
        children: [
          // Botón de cámara fijo (no hace scroll)
          if (widget.isAdminOrSolicitante)
            InkWell(
              onTap: widget.showImagePicker,
              child: Container(
                width: 80.0,
                height: 200.0,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.add_a_photo,
                  color: Color(0xFF1976d2),
                  size: 48,
                ),
              ),
            ),
          // Área con scroll para las imágenes
          Expanded(
            child: Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  // Capturar el scroll de la rueda del ratón y aplicarlo horizontalmente
                  final newOffset = _scrollController.offset + pointerSignal.scrollDelta.dy;
                  _scrollController.jumpTo(newOffset.clamp(
                    0.0,
                    _scrollController.position.maxScrollExtent,
                  ));
                }
              },
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...widget.imagesActividad.asMap().entries.map((entry) {
                        final index = entry.key;
                        final photo = entry.value;
                        return _NetworkImageWithDelete(
                          imageUrl: photo.urlFoto ?? '',
                          maxHeight: 200.0,
                          showDeleteButton: widget.isAdminOrSolicitante,
                          onDelete: widget.onDeleteApiImage != null 
                              ? () => widget.onDeleteApiImage!(index)
                              : null,
                        );
                      }),
                      ...widget.selectedImages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final image = entry.value;
                        return _ImageWithDeleteButton(
                          image: image,
                          maxHeight: 200.0,
                          onDelete: () => widget.onDeleteImage(index),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// EDIT ACTIVITY DIALOG
// ============================================

class EditActivityDialog extends StatefulWidget {
  final Actividad actividad;
  final Function(Map<String, dynamic>) onSave;

  const EditActivityDialog({
    Key? key,
    required this.actividad,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late DateTime _fechaInicio;
  late DateTime _fechaFin;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFin;
  String? _selectedProfesorId;
  int? _selectedDepartamentoId;
  bool _aprobada = false;
  
  // Variables para el folleto
  String? _folletoFileName;
  String? _folletoFilePath;
  bool _folletoChanged = false;
  
  List<Profesor> _profesores = [];
  List<Departamento> _departamentos = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores
    _nombreController = TextEditingController(text: widget.actividad.titulo);
    _descripcionController = TextEditingController(text: widget.actividad.descripcion ?? '');
    
    // Parsear fechas y horas
    _fechaInicio = DateTime.parse(widget.actividad.fini);
    _fechaFin = DateTime.parse(widget.actividad.ffin);
    
    // Parsear horas (formato HH:mm:ss o HH:mm)
    final horaIniParts = widget.actividad.hini.split(':');
    _horaInicio = TimeOfDay(
      hour: int.parse(horaIniParts[0]),
      minute: int.parse(horaIniParts[1]),
    );
    
    final horaFinParts = widget.actividad.hfin.split(':');
    _horaFin = TimeOfDay(
      hour: int.parse(horaFinParts[0]),
      minute: int.parse(horaFinParts[1]),
    );
    
    // Estado
    _aprobada = widget.actividad.estado.toLowerCase() == 'aprobada';
    
    // Cargar datos
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('[DEBUG] Iniciando carga de datos...');
      
      // Cargar profesores desde la API
      final profesores = await _apiService.fetchProfesores();
      print('[DEBUG] Profesores cargados: ${profesores.length}');
      for (var p in profesores) {
        print('[DEBUG] - Profesor: ${p.nombre} ${p.apellidos} (${p.uuid}) - ${p.correo}');
      }
      
      // Cargar departamentos desde la API
      final departamentos = await _apiService.fetchDepartamentos();
      print('[DEBUG] Departamentos cargados: ${departamentos.length}');
      for (var d in departamentos) {
        print('[DEBUG] - Departamento: ${d.nombre} (${d.id})');
      }
      
      setState(() {
        _profesores = profesores;
        _departamentos = departamentos;
        
        // Seleccionar valores actuales
        if (widget.actividad.solicitante != null) {
          // Buscar el profesor por correo electrónico ya que el UUID puede no coincidir
          final profesor = _profesores.firstWhere(
            (p) => p.correo.toLowerCase() == widget.actividad.solicitante!.correo.toLowerCase(),
            orElse: () => _profesores.first,
          );
          _selectedProfesorId = profesor.uuid;
          print('[DEBUG] Solicitante email: ${widget.actividad.solicitante!.correo}');
          print('[DEBUG] Profesor seleccionado: ${profesor.nombre} ${profesor.apellidos} (${profesor.uuid})');
        }
        if (widget.actividad.departamento != null) {
          _selectedDepartamentoId = widget.actividad.departamento!.id;
          print('[DEBUG] Departamento seleccionado: $_selectedDepartamentoId');
        }
        
        _isLoading = false;
      });
      
      print('[DEBUG] Estado actualizado, isLoading: $_isLoading');
    } catch (e, stackTrace) {
      print('[Error] Cargando datos: $e');
      print('[Error] StackTrace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _horaInicio : _horaFin,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _horaInicio = picked;
        } else {
          _horaFin = picked;
        }
      });
    }
  }

  void _handleSave() {
    // Validar campos
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }
    
    print('[DIALOG] ========== Verificando cambios en el diálogo ==========');
    
    // Verificar si hubo cambios reales antes de notificar
    bool hasChanges = false;
    
    // Comparar nombre
    print('[DIALOG] Comparando nombre: "${_nombreController.text.trim()}" vs "${widget.actividad.titulo.trim()}"');
    if (_nombreController.text.trim() != widget.actividad.titulo.trim()) {
      print('[DIALOG] CAMBIO en nombre detectado');
      hasChanges = true;
    }
    
    // Comparar descripción
    print('[DIALOG] Comparando descripción: "${_descripcionController.text.trim()}" vs "${(widget.actividad.descripcion ?? '').trim()}"');
    if (_descripcionController.text.trim() != (widget.actividad.descripcion ?? '').trim()) {
      print('[DIALOG] CAMBIO en descripción detectado');
      hasChanges = true;
    }
    
    // Comparar fechas (solo hasta segundos)
    final fechaInicioOriginal = DateTime.parse(widget.actividad.fini);
    final fechaInicioNormalizada = DateTime(_fechaInicio.year, _fechaInicio.month, _fechaInicio.day,
                                            _fechaInicio.hour, _fechaInicio.minute, _fechaInicio.second);
    final fechaOriginalNormalizada = DateTime(fechaInicioOriginal.year, fechaInicioOriginal.month, fechaInicioOriginal.day,
                                               fechaInicioOriginal.hour, fechaInicioOriginal.minute, fechaInicioOriginal.second);
    print('[DIALOG] Comparando fechaInicio: $fechaInicioNormalizada vs $fechaOriginalNormalizada');
    if (fechaInicioNormalizada != fechaOriginalNormalizada) {
      print('[DIALOG] CAMBIO en fechaInicio detectado');
      hasChanges = true;
    }
    
    final fechaFinOriginal = DateTime.parse(widget.actividad.ffin);
    final fechaFinNormalizada = DateTime(_fechaFin.year, _fechaFin.month, _fechaFin.day,
                                         _fechaFin.hour, _fechaFin.minute, _fechaFin.second);
    final fechaFinOriginalNormalizada = DateTime(fechaFinOriginal.year, fechaFinOriginal.month, fechaFinOriginal.day,
                                                  fechaFinOriginal.hour, fechaFinOriginal.minute, fechaFinOriginal.second);
    print('[DIALOG] Comparando fechaFin: $fechaFinNormalizada vs $fechaFinOriginalNormalizada');
    if (fechaFinNormalizada != fechaFinOriginalNormalizada) {
      print('[DIALOG] CAMBIO en fechaFin detectado');
      hasChanges = true;
    }
    
    // Comparar horas (normalizar a formato HH:mm)
    final hiniNueva = '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}';
    String hiniOriginal = widget.actividad.hini;
    // Si la hora original tiene formato HH:mm:ss, quitarle los segundos
    if (hiniOriginal.length > 5 && hiniOriginal.substring(5, 6) == ':') {
      hiniOriginal = hiniOriginal.substring(0, 5);
    }
    print('[DIALOG] Comparando hini: "$hiniNueva" vs "$hiniOriginal"');
    if (hiniNueva != hiniOriginal) {
      print('[DIALOG] CAMBIO en hini detectado');
      hasChanges = true;
    }
    
    final hfinNueva = '${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}';
    String hfinOriginal = widget.actividad.hfin;
    // Si la hora original tiene formato HH:mm:ss, quitarle los segundos
    if (hfinOriginal.length > 5 && hfinOriginal.substring(5, 6) == ':') {
      hfinOriginal = hfinOriginal.substring(0, 5);
    }
    print('[DIALOG] Comparando hfin: "$hfinNueva" vs "$hfinOriginal"');
    if (hfinNueva != hfinOriginal) {
      print('[DIALOG] CAMBIO en hfin detectado');
      hasChanges = true;
    }
    
    // Comparar profesor - buscar por email en lugar de UUID
    String? profesorOriginalId;
    if (widget.actividad.solicitante != null && _profesores.isNotEmpty) {
      final profesor = _profesores.firstWhere(
        (p) => p.correo.toLowerCase() == widget.actividad.solicitante!.correo.toLowerCase(),
        orElse: () => _profesores.first,
      );
      profesorOriginalId = profesor.uuid;
    }
    print('[DIALOG] Comparando profesorId: "$_selectedProfesorId" vs "$profesorOriginalId"');
    if (_selectedProfesorId != profesorOriginalId) {
      print('[DIALOG] CAMBIO en profesorId detectado');
      hasChanges = true;
    }
    
    print('[DIALOG] Comparando departamentoId: "$_selectedDepartamentoId" vs "${widget.actividad.departamento?.id}"');
    if (_selectedDepartamentoId != widget.actividad.departamento?.id) {
      print('[DIALOG] CAMBIO en departamentoId detectado');
      hasChanges = true;
    }
    
    // Comparar estado (aprobada se mapea a estado "Aprobada" o "Pendiente")
    final estadoOriginal = (widget.actividad.estado == 'Aprobada');
    print('[DIALOG] Comparando aprobada: "$_aprobada" vs "$estadoOriginal" (estado: "${widget.actividad.estado}")');
    if (_aprobada != estadoOriginal) {
      print('[DIALOG] CAMBIO en aprobada detectado');
      hasChanges = true;
    }
    
    // Comparar folleto
    if (_folletoChanged) {
      print('[DIALOG] CAMBIO en folleto detectado');
      hasChanges = true;
    }
    
    print('[DIALOG] ¿Hay cambios?: $hasChanges');
    
    // Solo notificar si hubo cambios
    if (hasChanges) {
      print('[DIALOG] Notificando cambios al padre');
      final data = {
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'fechaInicio': _fechaInicio.toIso8601String(),
        'fechaFin': _fechaFin.toIso8601String(),
        'hini': '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}:00',
        'hfin': '${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}:00',
        'profesorId': _selectedProfesorId,
        'departamentoId': _selectedDepartamentoId,
        'aprobada': _aprobada,
      };
      
      // Añadir folleto si cambió
      if (_folletoChanged && _folletoFilePath != null && _folletoFileName != null) {
        data['folletoFilePath'] = _folletoFilePath!;
        data['folletoFileName'] = _folletoFileName!;
      }
      
      widget.onSave(data);
    } else {
      print('[DIALOG] No hay cambios, no se notifica al padre');
    }
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1976d2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editar Actividad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre
                          TextField(
                            controller: _nombreController,
                            decoration: InputDecoration(
                              labelText: 'Nombre *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Descripción
                          TextField(
                            controller: _descripcionController,
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 16),
                          
                          // Fecha Inicio
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _selectDate(context, true),
                                  icon: Icon(Icons.calendar_today),
                                  label: Text(
                                    'Fecha Inicio: ${_fechaInicio.day.toString().padLeft(2, '0')}/${_fechaInicio.month.toString().padLeft(2, '0')}/${_fechaInicio.year}',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.all(12),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _selectTime(context, true),
                                  icon: Icon(Icons.access_time),
                                  label: Text(
                                    'Hora: ${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.all(12),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          
                          // Fecha Fin
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _selectDate(context, false),
                                  icon: Icon(Icons.calendar_today),
                                  label: Text(
                                    'Fecha Fin: ${_fechaFin.day.toString().padLeft(2, '0')}/${_fechaFin.month.toString().padLeft(2, '0')}/${_fechaFin.year}',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.all(12),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _selectTime(context, false),
                                  icon: Icon(Icons.access_time),
                                  label: Text(
                                    'Hora: ${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.all(12),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          
                          // Profesor Responsable
                          DropdownButtonFormField<String>(
                            value: _profesores.any((p) => p.uuid == _selectedProfesorId) 
                                ? _selectedProfesorId 
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Profesor Responsable',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text('Seleccionar profesor...'),
                              ),
                              ..._profesores.map((profesor) {
                                return DropdownMenuItem<String>(
                                  value: profesor.uuid,
                                  child: Text('${profesor.nombre} ${profesor.apellidos}'),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedProfesorId = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          
                          // Departamento
                          DropdownButtonFormField<int>(
                            value: _departamentos.any((d) => d.id == _selectedDepartamentoId) 
                                ? _selectedDepartamentoId 
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Departamento',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text('Seleccionar departamento...'),
                              ),
                              ..._departamentos.map((departamento) {
                                return DropdownMenuItem<int>(
                                  value: departamento.id,
                                  child: Text(departamento.nombre),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedDepartamentoId = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          
                          // Estado (Radio Buttons)
                          Text(
                            'Estado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: Text('Pendiente'),
                                  value: false,
                                  groupValue: _aprobada,
                                  onChanged: (value) {
                                    setState(() {
                                      _aprobada = value!;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: Text('Aprobada'),
                                  value: true,
                                  groupValue: _aprobada,
                                  onChanged: (value) {
                                    setState(() {
                                      _aprobada = value!;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
            
            // Actions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1976d2),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Guardar'),
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

// Widget de diálogo de selección múltiple de profesores
class _MultiSelectProfesorDialog extends StatefulWidget {
  final List<Profesor> profesores;
  final List<Profesor> profesoresYaSeleccionados;

  const _MultiSelectProfesorDialog({
    required this.profesores,
    required this.profesoresYaSeleccionados,
  });

  @override
  State<_MultiSelectProfesorDialog> createState() => _MultiSelectProfesorDialogState();
}

class _MultiSelectProfesorDialogState extends State<_MultiSelectProfesorDialog> {
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
    return AlertDialog(
      title: Text('Agregar Profesores Participantes'),
      content: Container(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            // Buscador
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar profesor...',
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
            if (_selectedProfesores.isNotEmpty)
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
                      '${_selectedProfesores.length} profesor(es) seleccionado(s)',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 8),
            
            // Lista de profesores con checkboxes
            Expanded(
              child: _filteredProfesores.isEmpty
                  ? Center(child: Text('No se encontraron profesores'))
                  : ListView.builder(
                      itemCount: _filteredProfesores.length,
                      itemBuilder: (context, index) {
                        final profesor = _filteredProfesores[index];
                        final yaParticipante = _isProfesorYaParticipante(profesor);
                        final isSelected = _selectedProfesores.any((p) => p.uuid == profesor.uuid);
                        
                        return CheckboxListTile(
                          title: Text('${profesor.nombre} ${profesor.apellidos}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profesor.correo, style: TextStyle(fontSize: 12)),
                              if (yaParticipante)
                                Text(
                                  'Ya participa',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                          value: isSelected,
                          enabled: !yaParticipante,
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
          onPressed: _selectedProfesores.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selectedProfesores),
          child: Text('Agregar (${_selectedProfesores.length})'),
        ),
      ],
    );
  }
}

// Widget de diálogo de selección múltiple de grupos/cursos
class _MultiSelectGrupoDialog extends StatefulWidget {
  final List<Curso> cursos;
  final List<Grupo> grupos;
  final List<Grupo> gruposYaSeleccionados;

  const _MultiSelectGrupoDialog({
    required this.cursos,
    required this.grupos,
    required this.gruposYaSeleccionados,
  });

  @override
  State<_MultiSelectGrupoDialog> createState() => _MultiSelectGrupoDialogState();
}

class _MultiSelectGrupoDialogState extends State<_MultiSelectGrupoDialog> {
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
