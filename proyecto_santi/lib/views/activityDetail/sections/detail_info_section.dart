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
import '../dialogs/add_localizacion_dialog.dart';
import '../dialogs/edit_localizacion_dialog.dart';
import '../widgets/locations/localizacion_card.dart';
import '../dialogs/edit_activity_dialog.dart';
import '../dialogs/multi_select_profesor_dialog.dart';
import '../dialogs/multi_select_grupo_dialog.dart';
import '../widgets/images/network_image_with_delete.dart';
import '../widgets/images/image_with_delete.dart';
import '../dialogs/image_preview_dialog.dart';
import 'budget_section.dart';
import 'header_section.dart';
import 'images_section.dart';
import 'participants_section.dart';
import 'locations_section.dart';

class ActivityDetailInfo extends StatefulWidget {
  final Actividad actividad;
  final bool isAdminOrSolicitante;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final Map<String, String> selectedImagesDescriptions;
  final VoidCallback showImagePicker;
  final Function(int) removeSelectedImage;
  final Function(int)? removeApiImage; // Nueva funci?n para eliminar fotos de la API
  final Function(int)? removeApiImageConfirmed; // Para eliminación ya confirmada
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
    this.removeApiImageConfirmed, // Opcional
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
  }

  // M�todo p�blico para guardar las descripciones de fotos pendientes
  Future<bool> savePhotoDescriptions() async {
    if (_photoDescriptionChanges.isEmpty) {
      return true;
    }

    bool allSuccess = true;

    for (var entry in _photoDescriptionChanges.entries) {
      try {
        final photoId = entry.key;
        final newDescription = entry.value;
        
        await _photoService.updatePhotoDescription(photoId, newDescription);
      } catch (e) {
        allSuccess = false;
      }
    }

    if (allSuccess) {
      setState(() {
        _photoDescriptionChanges.clear();
      });
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
              // Sección de imágenes (refactorizada)
              ActivityImagesSection(
                imagesActividad: widget.imagesActividad,
                selectedImages: widget.selectedImages,
                selectedImagesDescriptions: widget.selectedImagesDescriptions,
                isAdminOrSolicitante: widget.isAdminOrSolicitante,
                showImagePicker: widget.showImagePicker,
                removeSelectedImage: widget.removeSelectedImage,
                removeApiImage: widget.removeApiImage,
                removeApiImageConfirmed: widget.removeApiImageConfirmed,
                editLocalImage: widget.editLocalImage,
                onDataChanged: widget.onActivityDataChanged,
              ),
              SizedBox(height: 16),
              // Sección de participantes (refactorizada)
              ActivityParticipantsSection(
                profesoresParticipantes: _profesoresParticipantes,
                gruposParticipantes: _gruposParticipantes,
                isAdminOrSolicitante: widget.isAdminOrSolicitante,
                profesorService: _profesorService,
                catalogoService: _catalogoService,
                onDataChanged: (data) {
                  setState(() {
                    if (data.containsKey('profesoresParticipantes')) {
                      _profesoresParticipantes = data['profesoresParticipantes'];
                    }
                    if (data.containsKey('gruposParticipantes')) {
                      _gruposParticipantes = data['gruposParticipantes'];
                    }
                  });
                  _notifyChanges();
                },
              ),
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
            
            // Notificar al padre que hubo cambios
            if (widget.onActivityDataChanged != null) {
              widget.onActivityDataChanged!(updatedData);
            }
          },
        );
      },
    );
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
          // Sección de localizaciones (refactorizada)
          ActivityLocationsSection(
            actividadId: widget.actividad.id,
            isAdminOrSolicitante: widget.isAdminOrSolicitante,
            localizacionService: _localizacionService,
            onDataChanged: (data) {
              if (data.containsKey('localizaciones')) {
                setState(() {
                  _localizaciones = data['localizaciones'];
                });
              }
              _notifyChanges();
            },
          ),
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
          // Sección de localizaciones (refactorizada)
          child: ActivityLocationsSection(
            actividadId: widget.actividad.id,
            isAdminOrSolicitante: widget.isAdminOrSolicitante,
            localizacionService: _localizacionService,
            onDataChanged: (data) {
              if (data.containsKey('localizaciones')) {
                setState(() {
                  _localizaciones = data['localizaciones'];
                });
              }
              _notifyChanges();
            },
          ),
        ),
      ],
    );
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

