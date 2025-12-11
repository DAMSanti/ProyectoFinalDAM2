import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/tema.dart';
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
  final Function(int)? removeApiImage; 
  final Function(int)? removeApiImageConfirmed; 
  final Function(int)? editLocalImage; 
  final Function(Map<String, dynamic>)? onActivityDataChanged; 
  final int reloadTrigger; 
  const ActivityDetailInfo({
    super.key,
    required this.actividad,
    required this.isAdminOrSolicitante,
    required this.imagesActividad,
    required this.selectedImages,
    required this.selectedImagesDescriptions,
    required this.showImagePicker,
    required this.removeSelectedImage,
    this.removeApiImage, 
    this.removeApiImageConfirmed, 
    this.editLocalImage, 
    this.onActivityDataChanged, 
    this.reloadTrigger = 0, 
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
  Map<int, IconData> _iconosLocalizaciones = {}; 
  Map<int, String> _photoDescriptionChanges = {}; 
  bool _loadingProfesores = false;
  bool _loadingGrupos = false;
  bool _loadingLocalizaciones = false;
  int? _editingGrupoId; 
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
    _loadParticipantes();
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
      for (var data in localizacionesData) {
      }
      setState(() {
        _localizaciones = localizacionesData.map((data) => Localizacion.fromJson(data)).toList();
        for (var loc in _localizaciones) {
          if (!_iconosLocalizaciones.containsKey(loc.id)) {
            if (loc.icono != null && loc.icono!.isNotEmpty) {
              final iconData = IconHelper.getIcon(
                loc.icono,
                defaultIcon: loc.esPrincipal ? Icons.location_pin : Icons.location_on,
              );
              _iconosLocalizaciones[loc.id] = iconData;
            } else {
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
      final profesoresIds = await _profesorService.fetchProfesoresParticipantes(widget.actividad.id);
      final todosLosProfesores = await _profesorService.fetchProfesores();
      final gruposData = await _catalogoService.fetchGruposParticipantes(widget.actividad.id);
      final todosLosGrupos = await _catalogoService.fetchGrupos();
      setState(() {
        _profesoresParticipantes = todosLosProfesores
            .where((p) => profesoresIds.any((id) => id.toLowerCase() == p.uuid.toLowerCase()))
            .toList();
        _gruposParticipantes = gruposData.map((data) {
          final grupoId = data['grupoId'] as int;
          final numParticipantes = data['numeroParticipantes'] as int;
          final grupo = todosLosGrupos.firstWhere((g) => g.id == grupoId);
          return GrupoParticipante(
            grupo: grupo,
            numeroParticipantes: numParticipantes,
          );
        }).toList();
        _profesoresParticipantesOriginales = List.from(_profesoresParticipantes);
        _gruposParticipantesOriginales = _gruposParticipantes.map((gp) => 
          GrupoParticipante(
            grupo: gp.grupo,
            numeroParticipantes: gp.numeroParticipantes,
          )
        ).toList();
      });
    } catch (e) {
      setState(() {
        _profesoresParticipantesOriginales = [];
        _gruposParticipantesOriginales = [];
      });
    }
  }
  void _notifyChanges() {
    if (widget.onActivityDataChanged != null) {
      final Map<String, dynamic> changes = {
        'profesoresParticipantes': _profesoresParticipantes,
        'gruposParticipantes': _gruposParticipantes,
      };
      if (_localizaciones.isNotEmpty) {
        changes['localizaciones'] = _localizaciones;
        changes['localizaciones_changed'] = true;
      }
      widget.onActivityDataChanged!(changes);
    }
  }
  Future<void> reloadData() async {
    setState(() {
      _folletoFileName = null;
      _folletoFilePath = null;
      _folletoChanged = false;
      _folletoMarkedForDeletion = false;
      _photoDescriptionChanges.clear();
    });
    await _loadParticipantes();
  }
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
  String _extractFileName(String url) {
    final parts = url.split('/');
    if (parts.isEmpty) return 'folleto.pdf';
    final fileName = parts.last;
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
                folletoMarkedForDeletion: _folletoMarkedForDeletion,
                newFolletoFileName: _folletoChanged ? _folletoFileName : null,
                onEditPressed: () => _showEditDialog(context),
                onFolletoChanged: (data) {
                  setState(() {
                    if (data.containsKey('deleteFolleto') && data['deleteFolleto'] == true) {
                      _folletoMarkedForDeletion = true;
                      _folletoFileName = null;
                      _folletoFilePath = null;
                      _folletoChanged = false;
                    } else {
                      if (data.containsKey('folletoFileName')) {
                        _folletoFileName = data['folletoFileName'];
                      }
                      if (data.containsKey('folletoFilePath')) {
                        _folletoFilePath = data['folletoFilePath'];
                      }
                      _folletoChanged = true;
                      _folletoMarkedForDeletion = false;
                    }
                  });
                  if (widget.onActivityDataChanged != null) {
                    widget.onActivityDataChanged!(data);
                  }
                },
              ),
              SizedBox(height: 16),
              if (widget.isAdminOrSolicitante)
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
              if (widget.isAdminOrSolicitante)
                SizedBox(height: 16),
              if (widget.isAdminOrSolicitante)
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
              if (widget.isAdminOrSolicitante)
                SizedBox(height: 16),
              if (widget.isAdminOrSolicitante)
                _buildPresupuesto(context, constraints),
              SizedBox(height: 16),
              _buildLocalizaciones(context, constraints),
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
            if (widget.onActivityDataChanged != null) {
              widget.onActivityDataChanged!(updatedData);
            }
          },
        );
      },
    );
  }
  Widget _buildPresupuesto(BuildContext context, BoxConstraints constraints) {
    return ActivityBudgetSection(
      key: ValueKey('budget_${widget.reloadTrigger}'),
      actividad: widget.actividad,
      isAdminOrSolicitante: widget.isAdminOrSolicitante,
      totalAlumnosParticipantes: _totalAlumnosParticipantes,
      actividadService: _actividadService,
      onBudgetChanged: (budgetData) {
        setState(() {});
        if (widget.onActivityDataChanged != null) {
          widget.onActivityDataChanged!({
            'budgetChanged': true,
            ...budgetData,
          });
        }
      },
    );
  }
  Widget _buildLocalizaciones(BuildContext context, BoxConstraints constraints) {
    return ActivityLocationsSection(
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
    );
  }
  Widget _buildPresupuestoYLocalizacion(BuildContext context, BoxConstraints constraints) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    if (constraints.maxWidth < 800) {
      return Column(
        children: [
          ActivityBudgetSection(
            key: ValueKey('budget_${widget.reloadTrigger}'), 
            actividad: widget.actividad,
            isAdminOrSolicitante: widget.isAdminOrSolicitante,
            totalAlumnosParticipantes: _totalAlumnosParticipantes,
            actividadService: _actividadService,
            onBudgetChanged: (budgetData) {
              setState(() {});
              if (widget.onActivityDataChanged != null) {
                widget.onActivityDataChanged!({
                  'budgetChanged': true,
                  ...budgetData, 
                });
              }
            },
          ),
          SizedBox(height: 16),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ActivityBudgetSection(
            key: ValueKey('budget_${widget.reloadTrigger}'), 
            actividad: widget.actividad,
            isAdminOrSolicitante: widget.isAdminOrSolicitante,
            totalAlumnosParticipantes: _totalAlumnosParticipantes,
            actividadService: _actividadService,
            onBudgetChanged: (budgetData) {
              setState(() {});
              if (widget.onActivityDataChanged != null) {
                widget.onActivityDataChanged!({
                  'budgetChanged': true,
                  ...budgetData, 
                });
              }
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.estadoRechazado),
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
  Widget _buildComentarios(BuildContext context, BoxConstraints constraints) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    if (widget.actividad.comentarios == null || widget.actividad.comentarios!.isEmpty) {
      return SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment,
                color: AppColors.primary,
                size: isWeb ? 16 : 18.0,
              ),
              SizedBox(width: 8),
              Text(
                'Comentarios',
                style: TextStyle(
                  fontSize: isWeb ? 14 : 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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