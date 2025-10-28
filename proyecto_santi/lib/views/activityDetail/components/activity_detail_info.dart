import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/departamento.dart';
import 'package:proyecto_santi/models/curso.dart';
import 'package:proyecto_santi/models/grupo.dart';
import 'package:proyecto_santi/models/grupo_participante.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/widgets/localizaciones_map_widget.dart';
import 'package:proyecto_santi/utils/icon_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'localizaciones/add_localizacion_dialog.dart';
import 'localizaciones/edit_localizacion_dialog.dart';
import 'localizaciones/localizacion_card.dart';
import 'dialogs/edit_activity_dialog.dart';
import 'dialogs/multi_select_profesor_dialog.dart';
import 'dialogs/multi_select_grupo_dialog.dart';
import 'images/network_image_with_delete.dart';
import 'images/image_with_delete_button.dart';
import 'activity_budget_section.dart';

class ActivityDetailInfo extends StatefulWidget {
  final Actividad actividad;
  final bool isAdminOrSolicitante;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final VoidCallback showImagePicker;
  final Function(int) removeSelectedImage;
  final Function(int)? removeApiImage; // Nueva funci�n para eliminar fotos de la API
  final Function(Map<String, dynamic>)? onActivityDataChanged; // Callback para notificar cambios
  final int reloadTrigger; // N�mero que cambia cuando se debe recargar

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
    this.reloadTrigger = 0, // Por defecto 0
  });

  @override
  State<ActivityDetailInfo> createState() => _ActivityDetailInfoState();
}

class _ActivityDetailInfoState extends State<ActivityDetailInfo> {
  late final ApiService _apiService;
  late final ProfesorService _profesorService;
  late final CatalogoService _catalogoService;
  late final LocalizacionService _localizacionService;
  late final ActividadService _actividadService;
  List<Profesor> _profesoresParticipantes = [];
  List<GrupoParticipante> _gruposParticipantes = [];
  List<Profesor> _profesoresParticipantesOriginales = [];
  List<GrupoParticipante> _gruposParticipantesOriginales = [];
  List<Localizacion> _localizaciones = [];
  Map<int, IconData> _iconosLocalizaciones = {}; // Mapa de iconos por ID de localizaci�n
  bool _loadingProfesores = false;
  bool _loadingGrupos = false;
  bool _loadingLocalizaciones = false;
  int? _editingGrupoId; // ID del grupo que se est� editando
  
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
    _apiService = ApiService();
    _profesorService = ProfesorService(_apiService);
    _catalogoService = CatalogoService(_apiService);
    _localizacionService = LocalizacionService(_apiService);
    _actividadService = ActividadService(_apiService);
    // Cargar participantes desde la base de datos
    _loadParticipantes();
    // Cargar localizaciones
    _loadLocalizaciones();
  }
  
  @override
  void didUpdateWidget(ActivityDetailInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reloadTrigger != oldWidget.reloadTrigger) {
      reloadData();
    }
  }
  
  Future<void> _loadLocalizaciones() async {
    setState(() {
      _loadingLocalizaciones = true;
    });
    
    try {

      final localizacionesData = await _localizacionService.fetchLocalizaciones(widget.actividad.id);

      
      // Debug: imprimir datos recibidos del API

      for (var data in localizacionesData) {

      }
      
      setState(() {
        _localizaciones = localizacionesData.map((data) => Localizacion.fromJson(data)).toList();
        
        // Inicializar iconos desde la base de datos o usar por defecto
        for (var loc in _localizaciones) {

          
          if (!_iconosLocalizaciones.containsKey(loc.id)) {
            // Si la localizaci�n tiene un icono guardado en la BD, usarlo
            if (loc.icono != null && loc.icono!.isNotEmpty) {
              final iconData = IconHelper.getIcon(
                loc.icono,
                defaultIcon: loc.esPrincipal ? Icons.location_pin : Icons.location_on,
              );
              _iconosLocalizaciones[loc.id] = iconData;

            } else {
              // Si no tiene icono guardado, usar el icono por defecto seg�n si es principal
              _iconosLocalizaciones[loc.id] = loc.esPrincipal ? Icons.location_pin : Icons.location_on;

            }
          }
        }
        
        _loadingLocalizaciones = false;
      });
    } catch (e) {
      print('[LOCALIZACIONES ERROR] Error al cargar localizaciones: $e');
      setState(() {
        _loadingLocalizaciones = false;
      });
    }
  }
  
  Future<void> _loadParticipantes() async {
    try {
      // Cargar profesores participantes
      final profesoresIds = await _profesorService.fetchProfesoresParticipantes(widget.actividad.id);
      
      final todosLosProfesores = await _profesorService.fetchProfesores();
      
      // Cargar grupos participantes
      final gruposData = await _catalogoService.fetchGruposParticipantes(widget.actividad.id);
      
      final todosLosGrupos = await _catalogoService.fetchGrupos();
      
      setState(() {
        // Filtrar profesores que participan - convertir UUIDs a lowercase para comparar
        _profesoresParticipantes = todosLosProfesores
            .where((p) => profesoresIds.any((id) => id.toLowerCase() == p.uuid.toLowerCase()))
            .toList();
        
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
        
        // Guardar copias originales
        _profesoresParticipantesOriginales = List.from(_profesoresParticipantes);
        _gruposParticipantesOriginales = _gruposParticipantes.map((gp) => 
          GrupoParticipante(
            grupo: gp.grupo,
            numeroParticipantes: gp.numeroParticipantes,
          )
        ).toList();
      });
    } catch (e) {
      print('[ERROR] Error cargando participantes: $e');
      print('[ERROR] Stack trace: ${StackTrace.current}');
      // Inicializar listas vac�as en caso de error
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
  
  // M�todo p�blico para recargar datos desde el padre (al revertir)
  Future<void> reloadData() async {
    print('[ACTIVITY_DETAIL_INFO] Recargando datos...');
    setState(() {
      // Limpiar estado del folleto
      _folletoFileName = null;
      _folletoFilePath = null;
      _folletoChanged = false;
      _folletoMarkedForDeletion = false;
    });
    // Solo recargar participantes, no localizaciones (no se modifican en esta vista)
    await _loadParticipantes();
    print('[ACTIVITY_DETAIL_INFO] Datos recargados correctamente');
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
            // Guardar bytes para subir despu�s
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
      
      // Notificar el cambio para activar el bot�n guardar
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
              _buildPresupuestoYLocalizacion(context, constraints),
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
    
    // Construir texto seg�n si es el mismo d�a o d�as diferentes
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
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976d2),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF1976d2)),
              onPressed: () => _showEditDialog(context),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Descripci�n y Fecha en la misma l�nea
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripci�n con icono (izquierda)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.description, color: Color(0xFF1976d2), size: !isWeb ? 16.dg : 5.sp),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.actividad.descripcion ?? 'Sin descripci�n',
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
                      // Mostrar "Sin folleto" si est� marcado para eliminaci�n o no hay folleto
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
                    // Bot�n X para eliminar folleto (solo si hay folleto)
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fotos de la Actividad',
              style: TextStyle(
                fontSize: kIsWeb ? 5.sp : 14.dg,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976d2),
              ),
            ),
            SizedBox(height: 8),
            _HorizontalImageScroller(
              constraints: constraints,
              isAdminOrSolicitante: widget.isAdminOrSolicitante,
              showImagePicker: widget.showImagePicker,
              imagesActividad: widget.imagesActividad,
              selectedImages: widget.selectedImages,
              onDeleteImage: (index) => widget.removeSelectedImage(index),
              onDeleteApiImage: (index) async {
                // Llamar a la función del padre que maneja la eliminación
                if (widget.removeApiImage != null) {
                  await widget.removeApiImage!(index);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantes(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                style: TextStyle(
                  fontSize: kIsWeb ? 5.sp : 14.dg,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976d2),
                ),
              ),
              if (widget.isAdminOrSolicitante)
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF1976d2)),
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
                    style: TextStyle(
                      fontSize: kIsWeb ? 5.sp : 14.dg,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976d2),
                    ),
                  ),
                  if (_gruposParticipantes.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Total alumnos: $_totalAlumnosParticipantes',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.isAdminOrSolicitante)
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF1976d2)),
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
      final profesores = await _profesorService.fetchProfesores();
      
      if (!mounted) return;
      
      // Mostrar di�logo con selecci�n m�ltiple
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
          // Agregar solo los profesores que no est�n ya en la lista
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
      final cursos = await _catalogoService.fetchCursos();
      final todosLosGrupos = await _catalogoService.fetchGrupos();
      
      if (!mounted) return;
      
      // Mostrar di�logo con selecci�n de cursos/grupos
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
          // Agregar los grupos seleccionados con el n�mero total de alumnos por defecto
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
      grupoParticipante.numeroParticipantes = nuevoNumero;
      _editingGrupoId = null;
    });
    
    _notifyChanges();
  }

  Widget _buildPresupuestoYLocalizacion(BuildContext context, BoxConstraints constraints) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    // En pantallas peque�as (< 800px), mostrar en columna
    // En pantallas grandes, mostrar en fila (50/50)
    if (constraints.maxWidth < 800) {
      return Column(
        children: [
          ActivityBudgetSection(
            key: ValueKey('budget_${widget.reloadTrigger}'), // Forzar reconstrucci�n al revertir
            actividad: widget.actividad,
            isAdminOrSolicitante: widget.isAdminOrSolicitante,
            totalAlumnosParticipantes: _totalAlumnosParticipantes,
            actividadService: _actividadService,
            onBudgetChanged: (budgetData) {
              // Callback cuando cambia el presupuesto o switches de transporte/alojamiento
              setState(() {});
              // Notificar al padre que hubo cambios para activar el bot�n guardar
              if (widget.onActivityDataChanged != null) {
                widget.onActivityDataChanged!({
                  'budgetChanged': true,
                  ...budgetData, // Incluir transporteReq y alojamientoReq
                });
              }
            },
          ),
          SizedBox(height: 16),
          _buildLocalizacion(context, constraints),
        ],
      );
    }
    
    // Layout horizontal para pantallas grandes
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ActivityBudgetSection(
            key: ValueKey('budget_${widget.reloadTrigger}'), // Forzar reconstrucci�n al revertir
            actividad: widget.actividad,
            isAdminOrSolicitante: widget.isAdminOrSolicitante,
            totalAlumnosParticipantes: _totalAlumnosParticipantes,
            actividadService: _actividadService,
            onBudgetChanged: (budgetData) {
              // Callback cuando cambia el presupuesto o switches de transporte/alojamiento
              setState(() {});
              // Notificar al padre que hubo cambios para activar el bot�n guardar
              if (widget.onActivityDataChanged != null) {
                widget.onActivityDataChanged!({
                  'budgetChanged': true,
                  ...budgetData, // Incluir transporteReq y alojamientoReq
                });
              }
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildLocalizacion(context, constraints),
        ),
      ],
    );
  }

  Widget _buildLocalizacion(BuildContext context, BoxConstraints constraints) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    return Container(
      constraints: BoxConstraints(minHeight: 500), // Altura m�nima igual al contenedor de presupuesto
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Color(0xFF1976d2),
                    size: !isWeb ? 18.dg : 6.sp,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Localizaciones',
                    style: TextStyle(
                      fontSize: !isWeb ? 14.dg : 5.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976d2),
                    ),
                  ),
                  if (_localizaciones.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF1976d2).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_localizaciones.length}',
                        style: TextStyle(
                          fontSize: !isWeb ? 12.dg : 4.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976d2),
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.isAdminOrSolicitante)
                ElevatedButton.icon(
                  onPressed: _loadingLocalizaciones ? null : () {
                    _showAddLocalizacionDialog(context);
                  },
                  icon: Icon(
                    Icons.add_location,
                    size: !isWeb ? 16.dg : 5.sp,
                  ),
                  label: Text(
                    'Añadir',
                    style: TextStyle(fontSize: !isWeb ? 12.dg : 4.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976d2),
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          
          // Loading state
          if (_loadingLocalizaciones)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          // Siempre mostrar el mapa
          else ...[
            // Mapa interactivo
            Container(
              height: 600,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              clipBehavior: Clip.antiAlias,
              child: LocalizacionesMapWidget(
                localizaciones: _localizaciones,
                iconosLocalizaciones: _iconosLocalizaciones,
                onLocalizacionTapped: (localizacion) {
                  print('[MAP] Localizaci�n seleccionada: ${localizacion.nombre}');
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Método para mostrar el diálogo de añadir localización
  void _showAddLocalizacionDialog(BuildContext context) async {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddLocalizacionDialog(
          actividadId: widget.actividad.id,
          localizacionesExistentes: _localizaciones,
          onLocalizacionAdded: () {
            if (widget.onActivityDataChanged != null) {
              widget.onActivityDataChanged!({'localizaciones_changed': true});
            }
          },
        );
      },
    );

    // Si hay cambios, actualizar el estado local
    if (result != null && result['hasChanges'] == true) {
      final localizacionesRecibidas = List<Localizacion>.from(result['localizaciones']);
      print('[DEBUG SAVE ICONOS] Localizaciones recibidas del di�logo: ${localizacionesRecibidas.length}');
      
      for (var loc in localizacionesRecibidas) {
        print('[DEBUG SAVE ICONOS] Loc ID: ${loc.id}, Nombre: ${loc.nombre}, Icono: ${loc.icono}');
      }
      
      setState(() {
        _localizaciones = localizacionesRecibidas;
        
        if (result.containsKey('iconos')) {
          final iconosDelDialogo = result['iconos'] as Map<int, IconData>;
          _iconosLocalizaciones = Map<int, IconData>.from(iconosDelDialogo);
          print('[DEBUG SAVE ICONOS] Iconos recibidos del di�logo: ${_iconosLocalizaciones.length}');
          for (var entry in _iconosLocalizaciones.entries) {
            print('[DEBUG SAVE ICONOS] ID: ${entry.key}, IconData codePoint: ${entry.value.codePoint}');
          }
        }
      });
      
      if (widget.onActivityDataChanged != null) {
        widget.onActivityDataChanged!({
          'localizaciones_changed': true,
          'localizaciones_modificadas': _localizaciones,
        });
      }
    }
  }

  // M�todo para mostrar confirmaci�n de eliminaci�n de imagen
  Future<void> _showDeleteConfirmationDialog(BuildContext context, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar foto'),
          content: Text('�Est�s seguro de que deseas eliminar esta foto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true && widget.removeApiImage != null) {
      widget.removeApiImage!(index);
    }
  }

  // M�todo para construir secci�n de comentarios
  Widget _buildComentarios(BuildContext context, BoxConstraints constraints) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    if (widget.actividad.comentarios == null || widget.actividad.comentarios!.isEmpty) {
      return SizedBox.shrink();
    }

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
            children: [
              Icon(
                Icons.comment,
                color: Color(0xFF1976d2),
                size: !isWeb ? 24.dg : 7.sp,
              ),
              SizedBox(width: 8),
              Text(
                'Comentarios',
                style: TextStyle(
                  fontSize: !isWeb ? 18.dg : 6.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976d2),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            widget.actividad.comentarios!,
            style: TextStyle(
              fontSize: !isWeb ? 14.dg : 4.5.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para scroll horizontal de im�genes
class _HorizontalImageScroller extends StatefulWidget {
  final BoxConstraints constraints;
  final bool isAdminOrSolicitante;
  final VoidCallback showImagePicker;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final Function(int) onDeleteImage;
  final Function(int)? onDeleteApiImage;

  const _HorizontalImageScroller({
    required this.constraints,
    required this.isAdminOrSolicitante,
    required this.showImagePicker,
    required this.imagesActividad,
    required this.selectedImages,
    required this.onDeleteImage,
    this.onDeleteApiImage,
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
          // Bot�n de c�mara fijo (no hace scroll)
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
          // �rea con scroll para las im�genes
          Expanded(
            child: Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
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
                        return NetworkImageWithDelete(
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
                        return ImageWithDeleteButton(
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

