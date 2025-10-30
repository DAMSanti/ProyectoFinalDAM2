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
import 'images/image_preview_dialog.dart';
import 'activity_budget_section.dart';
import 'header/activity_detail_header.dart';

class ActivityDetailInfo extends StatefulWidget {
  final Actividad actividad;
  final bool isAdminOrSolicitante;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final Map<String, String> selectedImagesDescriptions;
  final VoidCallback showImagePicker;
  final Function(int) removeSelectedImage;
  final Function(int)? removeApiImage; // Nueva funci?n para eliminar fotos de la API
  final Function(int)? editLocalImage; // Nueva funci�n para editar im�genes locales
  final Function(Map<String, dynamic>)? onActivityDataChanged; // Callback para notificar cambios
  final int reloadTrigger; // N?mero que cambia cuando se debe recargar

  const ActivityDetailInfo({
    super.key,
    required this.actividad,
    required this.isAdminOrSolicitante,
    required this.imagesActividad,
    required this.selectedImages,
    required this.selectedImagesDescriptions,
    required this.showImagePicker,
    required this.removeSelectedImage,
    this.removeApiImage, // Opcional
    this.editLocalImage, // Opcional
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
  late final PhotoService _photoService;
  List<Profesor> _profesoresParticipantes = [];
  List<GrupoParticipante> _gruposParticipantes = [];
  List<Profesor> _profesoresParticipantesOriginales = [];
  List<GrupoParticipante> _gruposParticipantesOriginales = [];
  List<Localizacion> _localizaciones = [];
  Map<int, IconData> _iconosLocalizaciones = {}; // Mapa de iconos por ID de localizaci?n
  Map<int, String> _photoDescriptionChanges = {}; // Mapa: photoId -> nueva descripci�n
  bool _loadingProfesores = false;
  bool _loadingGrupos = false;
  bool _loadingLocalizaciones = false;
  int? _editingGrupoId; // ID del grupo que se est? editando
  
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
    _photoService = PhotoService(_apiService);
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
            // Si la localizaci?n tiene un icono guardado en la BD, usarlo
            if (loc.icono != null && loc.icono!.isNotEmpty) {
              final iconData = IconHelper.getIcon(
                loc.icono,
                defaultIcon: loc.esPrincipal ? Icons.location_pin : Icons.location_on,
              );
              _iconosLocalizaciones[loc.id] = iconData;

            } else {
              // Si no tiene icono guardado, usar el icono por defecto seg?n si es principal
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
      // Inicializar listas vac?as en caso de error
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
  
  // M?todo p?blico para recargar datos desde el padre (al revertir)
  Future<void> reloadData() async {
    print('[ACTIVITY_DETAIL_INFO] Recargando datos...');
    setState(() {
      // Limpiar estado del folleto
      _folletoFileName = null;
      _folletoFilePath = null;
      _folletoChanged = false;
      _folletoMarkedForDeletion = false;
      // Limpiar cambios pendientes de descripciones de fotos
      _photoDescriptionChanges.clear();
    });
    // Solo recargar participantes, no localizaciones (no se modifican en esta vista)
    await _loadParticipantes();
    print('[ACTIVITY_DETAIL_INFO] Datos recargados correctamente');
  }

  // M�todo p�blico para guardar las descripciones de fotos pendientes
  Future<bool> savePhotoDescriptions() async {
    if (_photoDescriptionChanges.isEmpty) {
      print('[ACTIVITY_DETAIL_INFO] No hay cambios de descripciones de fotos para guardar');
      return true;
    }

    print('[ACTIVITY_DETAIL_INFO] Guardando ${_photoDescriptionChanges.length} descripciones de fotos...');
    bool allSuccess = true;

    for (var entry in _photoDescriptionChanges.entries) {
      try {
        final photoId = entry.key;
        final newDescription = entry.value;
        
        await _photoService.updatePhotoDescription(photoId, newDescription);
        print('[ACTIVITY_DETAIL_INFO] Descripción de foto $photoId actualizada correctamente');
      } catch (e) {
        print('[ERROR] Error actualizando descripción de foto ${entry.key}: $e');
        allSuccess = false;
      }
    }

    if (allSuccess) {
      setState(() {
        _photoDescriptionChanges.clear();
      });
      print('[ACTIVITY_DETAIL_INFO] Todas las descripciones de fotos guardadas correctamente');
    }

    return allSuccess;
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
            // Guardar bytes para subir despu?s
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
      
      // Notificar el cambio para activar el bot?n guardar
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
              ActivityDetailHeader(
                actividad: widget.actividad,
                isAdminOrSolicitante: widget.isAdminOrSolicitante,
                folletoFileName: _folletoFileName,
                folletoMarkedForDeletion: _folletoMarkedForDeletion,
                onEditPressed: () => _showEditDialog(context),
                onSelectFolleto: _selectFolleto,
                onDeleteFolleto: _deleteFolleto,
              ),
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
                Icons.photo_library_rounded,
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
                // T�tulo con icono
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(25, 118, 210, 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: Color(0xFF1976d2),
                        size: isWeb ? 18 : 20.0,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Fotos de la Actividad',
                      style: TextStyle(
                        fontSize: isWeb ? 14 : 16.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Color(0xFF1976d2),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _HorizontalImageScroller(
                  constraints: constraints,
                  isAdminOrSolicitante: widget.isAdminOrSolicitante,
                  showImagePicker: widget.showImagePicker,
                  imagesActividad: widget.imagesActividad,
                  selectedImages: widget.selectedImages,
                  selectedImagesDescriptions: widget.selectedImagesDescriptions,
                  onDeleteImage: (index) => widget.removeSelectedImage(index),
                  onDeleteApiImage: (index) async {
                    if (widget.removeApiImage != null) {
                      await widget.removeApiImage!(index);
                    }
                  },
                  onImageTap: (photo) => _showImageEditDialog(context, photo),
                  onLocalImageTap: (index) {
                    if (widget.editLocalImage != null) {
                      widget.editLocalImage!(index);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantes(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Layout responsivo: dos columnas en pantallas anchas, una columna en m�vil
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
                Icons.people_rounded,
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
                // T�tulo con icono y bot�n agregar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(25, 118, 210, 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.people_rounded,
                            color: Color(0xFF1976d2),
                            size: isWeb ? 18 : 20.0,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Profesores Participantes',
                          style: TextStyle(
                            fontSize: isWeb ? 14 : 16.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Color(0xFF1976d2),
                          ),
                        ),
                      ],
                    ),
                    if (widget.isAdminOrSolicitante)
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF1976d2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.add_circle_outline_rounded,
                            color: Color(0xFF1976d2),
                            size: 20,
                          ),
                          onPressed: _loadingProfesores ? null : () {
                            _showAddProfesorDialog(context);
                          },
                          tooltip: 'Agregar profesor',
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                // Lista de profesores participantes
                _profesoresParticipantes.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: 48,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Sin profesores participantes',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: isWeb ? 12 : 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 300),
                        child: SingleChildScrollView(
                          child: Column(
                            children: _profesoresParticipantes.map((profesor) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  leading: Container(
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
                                          color: Color(0xFF1976d2).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        profesor.nombre.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isWeb ? 16 : 18.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    '${profesor.nombre} ${profesor.apellidos}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isWeb ? 13 : 15.0,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.email_outlined,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            profesor.correo,
                                            style: TextStyle(
                                              fontSize: isWeb ? 11 : 13.0,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: widget.isAdminOrSolicitante
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _profesoresParticipantes.removeWhere((p) => p.uuid == profesor.uuid);
                                              });
                                              _notifyChanges();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(Icons.check_circle, color: Colors.white),
                                                      SizedBox(width: 8),
                                                      Text('Profesor eliminado'),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            tooltip: 'Eliminar profesor',
                                          ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildGruposParticipantes(BuildContext context) {
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
                // T�tulo con icono y bot�n agregar
                Row(
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
                                if (_gruposParticipantes.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1976d2).withOpacity(0.15),
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
                          color: Color(0xFF1976d2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.add_circle_outline_rounded,
                            color: Color(0xFF1976d2),
                            size: 20,
                          ),
                          onPressed: _loadingGrupos ? null : () {
                            _showAddGrupoDialog(context);
                          },
                          tooltip: 'Agregar grupo',
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                // Lista de grupos participantes
                _gruposParticipantes.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 48,
                                color: Colors.grey.withOpacity(0.5),
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
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 300),
                        child: SingleChildScrollView(
                          child: Column(
                            children: _gruposParticipantes.map((grupoParticipante) {
                              final isEditing = _editingGrupoId == grupoParticipante.grupo.id;
                              
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  leading: Container(
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
                                          color: Color(0xFF1976d2).withOpacity(0.3),
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
                                  ),
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
                                        : InkWell(
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
                                                    ? Color(0xFF1976d2).withOpacity(0.1)
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
                                          ),
                                  ),
                                  trailing: widget.isAdminOrSolicitante
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _gruposParticipantes.removeWhere(
                                                  (gp) => gp.grupo.id == grupoParticipante.grupo.id
                                                );
                                              });
                                              _notifyChanges();
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
                                            },
                                            tooltip: 'Eliminar grupo',
                                          ),
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
          ),
        ],
      ),
    );
  }

  /// Muestra el di�logo para editar la descripci�n de una foto existente
  void _showImageEditDialog(BuildContext context, Photo photo) async {
    // Obtener la descripci�n actual (puede haber cambios pendientes)
    final currentDescription = _photoDescriptionChanges.containsKey(photo.id)
        ? _photoDescriptionChanges[photo.id]
        : photo.descripcion;
    
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ImagePreviewDialog(
          imageUrl: photo.urlFoto ?? '',
          initialDescription: currentDescription?.isNotEmpty == true ? currentDescription : null,
          isEditing: true,
          onConfirm: (description) {
            // Solo retornar el valor, no guardar a�n
            Navigator.of(dialogContext).pop(description);
          },
        );
      },
    );
    
    // Si se confirm� (result no es null), guardar cambio localmente
    if (result != null && mounted) {
      setState(() {
        // Guardar el cambio en el mapa temporal
        _photoDescriptionChanges[photo.id] = result;
        
        // Actualizar visualmente
        photo.descripcion = result;
      });
      
      // Notificar que hay cambios pendientes, pasar el mapa completo
      if (widget.onActivityDataChanged != null) {
        widget.onActivityDataChanged!({
          'photoDescriptionChanges': Map<int, String>.from(_photoDescriptionChanges),
        });
      }
      
      // Mostrar feedback al usuario usando el contexto del widget montado
      try {
        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              content: Text('Descripción actualizada (pendiente de guardar)'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Si falla el SnackBar, al menos registramos el cambio
        print('[INFO] Descripción actualizada para foto ${photo.id} (SnackBar no disponible)');
      }
    }
  }

  void _showAddProfesorDialog(BuildContext context) async {
    setState(() => _loadingProfesores = true);
    
    // Capturar el ScaffoldMessenger antes del di�logo async
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Cargar todos los profesores desde la API
      final profesores = await _profesorService.fetchProfesores();
      
      if (!mounted) return;
      
      // Mostrar di?logo con selecci?n m?ltiple
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
          // Agregar solo los profesores que no est?n ya en la lista
          for (var profesor in selectedProfesores) {
            if (!_profesoresParticipantes.any((p) => p.uuid == profesor.uuid)) {
              _profesoresParticipantes.add(profesor);
            }
          }
        });
        
        _notifyChanges();
        
        if (mounted) {
          try {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('${selectedProfesores.length} profesor(es) agregado(s)')),
            );
          } catch (e) {
            print('[INFO] ${selectedProfesores.length} profesor(es) agregado(s) (SnackBar no disponible)');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        try {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error al cargar profesores: $e')),
          );
        } catch (snackbarError) {
          print('[ERROR] Error al cargar profesores: $e (SnackBar no disponible)');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _loadingProfesores = false);
      }
    }
  }

  void _showAddGrupoDialog(BuildContext context) async {
    setState(() => _loadingGrupos = true);
    
    // Capturar el ScaffoldMessenger antes del di�logo async
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Cargar todos los cursos y grupos desde la API
      final cursos = await _catalogoService.fetchCursos();
      final todosLosGrupos = await _catalogoService.fetchGrupos();
      
      if (!mounted) return;
      
      // Mostrar di?logo con selecci?n de cursos/grupos
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
          // Agregar los grupos seleccionados con el n?mero total de alumnos por defecto
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
          try {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('${gruposSeleccionados.length} grupo(s) agregado(s)')),
            );
          } catch (e) {
            print('[INFO] ${gruposSeleccionados.length} grupo(s) agregado(s) (SnackBar no disponible)');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        try {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error al cargar grupos: $e')),
          );
        } catch (snackbarError) {
          print('[ERROR] Error al cargar grupos: $e (SnackBar no disponible)');
        }
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

  Widget _buildPresupuestoYLocalizacion(BuildContext context, BoxConstraints constraints) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    // En pantallas peque?as (< 800px), mostrar en columna
    // En pantallas grandes, mostrar en fila (50/50)
    if (constraints.maxWidth < 800) {
      return Column(
        children: [
          ActivityBudgetSection(
            key: ValueKey('budget_${widget.reloadTrigger}'), // Forzar reconstrucci?n al revertir
            actividad: widget.actividad,
            isAdminOrSolicitante: widget.isAdminOrSolicitante,
            totalAlumnosParticipantes: _totalAlumnosParticipantes,
            actividadService: _actividadService,
            onBudgetChanged: (budgetData) {
              // Callback cuando cambia el presupuesto o switches de transporte/alojamiento
              setState(() {});
              // Notificar al padre que hubo cambios para activar el bot?n guardar
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
            key: ValueKey('budget_${widget.reloadTrigger}'), // Forzar reconstrucci?n al revertir
            actividad: widget.actividad,
            isAdminOrSolicitante: widget.isAdminOrSolicitante,
            totalAlumnosParticipantes: _totalAlumnosParticipantes,
            actividadService: _actividadService,
            onBudgetChanged: (budgetData) {
              // Callback cuando cambia el presupuesto o switches de transporte/alojamiento
              setState(() {});
              // Notificar al padre que hubo cambios para activar el bot?n guardar
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    return Container(
      constraints: BoxConstraints(minHeight: 500),
      padding: EdgeInsets.all(20),
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
                Color.fromRGBO(187, 222, 251, 0.85),
                Color.fromRGBO(144, 202, 249, 0.75),
              ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
            ? const Color.fromRGBO(255, 255, 255, 0.1) 
            : const Color.fromRGBO(0, 0, 0, 0.05),
          width: 1,
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
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(25, 118, 210, 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF1976d2),
                      size: isWeb ? 18 : 20.0,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Localizaciones',
                    style: TextStyle(
                      fontSize: isWeb ? 14 : 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976d2),
                    ),
                  ),
                  if (_localizaciones.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(left: 12),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1976d2).withOpacity(0.8),
                            Color(0xFF1565c0).withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF1976d2).withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${_localizaciones.length}',
                        style: TextStyle(
                          fontSize: isWeb ? 12 : 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.isAdminOrSolicitante)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1976d2).withOpacity(0.8),
                        Color(0xFF1565c0).withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1976d2).withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _loadingLocalizaciones ? null : () {
                        _showAddLocalizacionDialog(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_location_rounded,
                              color: Colors.white,
                              size: isWeb ? 18 : 20.0,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Añadir',
                              style: TextStyle(
                                fontSize: isWeb ? 13 : 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                  print('[MAP] Localización seleccionada: ${localizacion.nombre}');
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // M�todo para mostrar el di�logo de a�adir localizaci�n
  void _showAddLocalizacionDialog(BuildContext context) async {
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
      print('[DEBUG SAVE ICONOS] Localizaciones recibidas del diálogo: ${localizacionesRecibidas.length}');
      
      for (var loc in localizacionesRecibidas) {
        print('[DEBUG SAVE ICONOS] Loc ID: ${loc.id}, Nombre: ${loc.nombre}, Icono: ${loc.icono}');
      }
      
      setState(() {
        _localizaciones = localizacionesRecibidas;
        
        if (result.containsKey('iconos')) {
          final iconosDelDialogo = result['iconos'] as Map<int, IconData>;
          _iconosLocalizaciones = Map<int, IconData>.from(iconosDelDialogo);
          print('[DEBUG SAVE ICONOS] Iconos recibidos del diálogo: ${_iconosLocalizaciones.length}');
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

  // M?todo para mostrar confirmaci?n de eliminaci?n de imagen
  Future<void> _showDeleteConfirmationDialog(BuildContext context, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar foto'),
          content: Text('¿Estás seguro de que deseas eliminar esta foto?'),
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

  // M?todo para construir secci?n de comentarios
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
                size: isWeb ? 16 : 18.0,
              ),
              SizedBox(width: 8),
              Text(
                'Comentarios',
                style: TextStyle(
                  fontSize: isWeb ? 14 : 16.0,
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
              fontSize: isWeb ? 13 : 15.0,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para scroll horizontal de im?genes
class _HorizontalImageScroller extends StatefulWidget {
  final BoxConstraints constraints;
  final bool isAdminOrSolicitante;
  final VoidCallback showImagePicker;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final Map<String, String> selectedImagesDescriptions;
  final Function(int) onDeleteImage;
  final Function(int)? onDeleteApiImage;
  final Function(Photo)? onImageTap;
  final Function(int)? onLocalImageTap;

  const _HorizontalImageScroller({
    required this.constraints,
    required this.isAdminOrSolicitante,
    required this.showImagePicker,
    required this.imagesActividad,
    required this.selectedImages,
    required this.selectedImagesDescriptions,
    required this.onDeleteImage,
    this.onDeleteApiImage,
    this.onImageTap,
    this.onLocalImageTap,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: widget.constraints.maxWidth,
      height: 200.0,
      child: Row(
        children: [
          // Bot�n de c�mara fijo (no hace scroll) - Modernizado
          if (widget.isAdminOrSolicitante)
            Container(
              width: 160.0,
              height: 200.0,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Color.fromRGBO(25, 118, 210, 0.2),
                          Color.fromRGBO(21, 101, 192, 0.15),
                        ]
                      : [
                          Color.fromRGBO(187, 222, 251, 0.6),
                          Color.fromRGBO(144, 202, 249, 0.5),
                        ],
                ),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Color(0xFF1976d2).withOpacity(0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1976d2).withOpacity(0.2),
                    offset: Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.showImagePicker,
                  borderRadius: BorderRadius.circular(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF1976d2).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_rounded,
                          color: Color(0xFF1976d2),
                          size: 48,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Añadir Foto',
                        style: TextStyle(
                          color: Color(0xFF1976d2),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // ?rea con scroll para las im?genes
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
                          onTap: widget.onImageTap != null
                              ? () => widget.onImageTap!(photo)
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
                          onTap: widget.onLocalImageTap != null
                              ? () => widget.onLocalImageTap!(index)
                              : null,
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

