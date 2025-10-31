import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/alojamiento.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/departamento.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'package:proyecto_santi/models/empresa_transporte.dart';
import 'package:proyecto_santi/models/gasto_personalizado.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/services/gasto_personalizado_service.dart';
import 'package:proyecto_santi/components/app_bar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/views/activityDetail/layouts/large_landscape_layout.dart';
import 'package:proyecto_santi/views/activityDetail/layouts/small_landscape_layout.dart';
import 'package:proyecto_santi/views/activityDetail/layouts/portrait_layout.dart';
import 'package:proyecto_santi/views/activityDetail/dialogs/image_preview_dialog.dart';
import 'package:proyecto_santi/views/activityDetail/services/save_service.dart';
import 'package:proyecto_santi/views/activityDetail/helpers/image_picker_helper.dart';
import 'package:proyecto_santi/views/activityDetail/helpers/change_detection_helper.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/func.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:proyecto_santi/components/desktop_shell.dart';

class ActivityDetailView extends StatefulWidget {
  final Actividad actividad;
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;

  const ActivityDetailView({
    super.key,
    required this.actividad,
    required this.isDarkTheme,
    required this.onToggleTheme,
  });

  @override
  ActivityDetailViewState createState() => ActivityDetailViewState();
}

class ActivityDetailViewState extends State<ActivityDetailView> {
  late Future<List<Photo>> _futurePhotos;
  late final ApiService _apiService;
  late final ActividadService _actividadService;
  late final ProfesorService _profesorService;
  late final CatalogoService _catalogoService;
  late final PhotoService _photoService;
  late final LocalizacionService _localizacionService;
  late final SaveHandler _saveHandler;
  bool isDataChanged = false;
  bool isAdminOrSolicitante = true;
  List<Photo> imagesActividad = [];
  List<XFile> selectedImages = [];
  Map<String, String> selectedImagesDescriptions = {}; // Mapa: path -> descripción
  List<int> imagesToDelete = []; // IDs de imágenes marcadas para eliminar
  bool isDialogVisible = false;
  bool isPopupVisible = false;
  bool isCameraVisible = false;
  
  // Actividad completa con todos los datos
  Actividad? _actividadCompleta;
  Actividad? _actividadOriginal; // Copia de los datos originales de la BD
  Map<String, dynamic>? _datosEditados; // Datos modificados en el diálogo
  bool _isLoadingActivity = true;
  int _widgetKey = 0; // Key para forzar reconstrucción del widget

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _actividadService = ActividadService(_apiService);
    _profesorService = ProfesorService(_apiService);
    _catalogoService = CatalogoService(_apiService);
    _photoService = PhotoService(_apiService);
    _localizacionService = LocalizacionService(_apiService);
    _saveHandler = SaveHandler(
      actividadService: _actividadService,
      profesorService: _profesorService,
      catalogoService: _catalogoService,
      photoService: _photoService,
      localizacionService: _localizacionService,
      gastoService: GastoPersonalizadoService(_apiService),
    );
    _loadActivityDetails();
    _futurePhotos = _photoService.fetchPhotosByActivityId(widget.actividad.id);
    _futurePhotos.then((photos) {
      setState(() {
        imagesActividad = photos;
      });
    });
  }
  
  Future<void> _loadActivityDetails() async {
    try {

      final actividadCompleta = await _actividadService.fetchActivityById(widget.actividad.id);

      
      // Cargar fotos de la actividad
      final photos = await _photoService.fetchPhotosByActivityId(widget.actividad.id);
      
      setState(() {
        _actividadCompleta = actividadCompleta ?? widget.actividad;
        _actividadOriginal = actividadCompleta ?? widget.actividad; // Guardar copia original
        imagesActividad = photos;
        _isLoadingActivity = false;
      });
    } catch (e) {
      setState(() {
        _actividadCompleta = widget.actividad;
        _actividadOriginal = widget.actividad; // Guardar copia original
        _isLoadingActivity = false;
      });
    }
  }

  Future<void> _loadPhotos() async {
    try {
      final photos = await _photoService.fetchPhotosByActivityId(widget.actividad.id);
      setState(() {
        imagesActividad = photos;
      });
    } catch (e) {
    }
  }

  void _showImagePicker() async {
    await ImagePickerHelper.showImagePicker(
      context: context,
      onImageSelected: (image, description) {
        setState(() {
          selectedImages.add(image);
          // Guardar la descripción asociada a esta imagen
          if (description.isNotEmpty) {
            selectedImagesDescriptions[image.path] = description;
          }
          isDataChanged = true;
        });
      },
    );
  }

  void _removeSelectedImage(int index) {
    setState(() {
      final imagePath = selectedImages[index].path;
      selectedImages.removeAt(index);
      // Eliminar también la descripción asociada
      selectedImagesDescriptions.remove(imagePath);
      isDataChanged = true;
    });
  }

  Future<void> _removeApiImage(int index) async {
    // Mostrar diálogo de confirmación
    final confirmed = await ImagePickerHelper.confirmImageDeletion(context);

    if (confirmed && index < imagesActividad.length) {
      final photo = imagesActividad[index];
      setState(() {
        // Marcar la imagen para eliminar
        imagesToDelete.add(photo.id);
        // Remover de la lista de visualización
        imagesActividad.removeAt(index);
        // Marcar que hay cambios
        isDataChanged = true;
      });
    }
  }

  // Método para eliminar una imagen de la API cuando ya se confirmó la eliminación (desde diálogo de edición)
  void _removeApiImageConfirmed(int index) {
    print('DEBUG: _removeApiImageConfirmed llamado con index: $index');
    print('DEBUG: imagesActividad.length: ${imagesActividad.length}');
    
    if (index < imagesActividad.length) {
      final photo = imagesActividad[index];
      print('DEBUG: Eliminando foto ID: ${photo.id}');
      
      setState(() {
        // Marcar la imagen para eliminar
        imagesToDelete.add(photo.id);
        print('DEBUG: Foto agregada a imagesToDelete. Total: ${imagesToDelete.length}');
        
        // Remover de la lista de visualización
        imagesActividad.removeAt(index);
        print('DEBUG: Foto removida de imagesActividad. Nueva longitud: ${imagesActividad.length}');
        
        // Marcar que hay cambios
        isDataChanged = true;
        print('DEBUG: isDataChanged = true');
      });
    } else {
      print('ERROR: Index fuera de rango! index: $index, length: ${imagesActividad.length}');
    }
  }
  
  // Método para editar la descripción de una imagen local
  void _editLocalImage(int index) async {
    if (index >= selectedImages.length) return;
    
    final image = selectedImages[index];
    final currentDescription = selectedImagesDescriptions[image.path];
    
    await ImagePickerHelper.editImageDescription(
      context: context,
      image: image,
      currentDescription: currentDescription,
      onDescriptionChanged: (description) {
        setState(() {
          // Actualizar o eliminar la descripción
          if (description.isNotEmpty) {
            selectedImagesDescriptions[image.path] = description;
          } else {
            selectedImagesDescriptions.remove(image.path);
          }
        });
      },
    );
  }
  
  bool _hasRealChanges() {
    return ChangeDetectionHelper.hasRealChanges(
      selectedImages: selectedImages,
      imagesToDelete: imagesToDelete,
      datosEditados: _datosEditados,
      actividadOriginal: _actividadOriginal,
    );
  }
  
  Future<void> _revertChanges() async {
    // Limpiar todos los cambios pendientes
    setState(() {
      _datosEditados = null;
      selectedImages.clear();
      selectedImagesDescriptions.clear();
      imagesToDelete.clear();
      isDataChanged = false;
    });
    
    // Recargar todo desde la base de datos (actividad, fotos, profesores, grupos)
    // Esto restaurará folleto, profesores participantes, grupos participantes, etc.
    await _loadActivityDetails();
    
    // Incrementar _widgetKey para que los componentes internos se recarguen
    setState(() {
      _widgetKey++;
    });
  }
  
  void _handleActivityDataChanged(Map<String, dynamic> updatedData) async {


    updatedData.forEach((key, value) {
      if (key != 'folletoBytes' && key != 'selectedImages') {

      }
    });
    
    // Si _datosEditados es null, inicializarlo
    if (_datosEditados == null) {
      _datosEditados = {};
    }
    
    // Fusionar los datos actualizados con los existentes
    _datosEditados!.addAll(updatedData);
    


    _datosEditados!.forEach((key, value) {
      if (key != 'folletoBytes' && key != 'selectedImages') {

      }
    });
    
    // Si hay cambios en localizaciones, marcar como cambio
    if (updatedData.containsKey('localizaciones_changed') && updatedData['localizaciones_changed'] == true) {
      setState(() {
        isDataChanged = true;
      });

      return;
    }
    
    // Si hay cambios en descripciones de fotos, marcar como cambio
    if (updatedData.containsKey('photoDescriptionChanges')) {
      setState(() {
        isDataChanged = true;
      });
      return;
    }
    
    // Buscar el profesor (responsable) actualizado si cambió
    dynamic nuevoProfesor = _actividadCompleta?.responsable;
    
    // Si cambió el profesor, buscar el nuevo
    if (updatedData['profesorId'] != null) {
      try {
        final profesores = await _profesorService.fetchProfesores();
        final profesorEncontrado = profesores.where((p) => p.uuid == updatedData['profesorId']).toList();
        if (profesorEncontrado.isNotEmpty) {
          nuevoProfesor = profesorEncontrado.first;
        }
      } catch (e) {
      }
    }
    
    // Ya no usamos departamento, eliminamos este código
    
    setState(() {
      // Actualizar la actividad completa con los nuevos datos
      if (_actividadCompleta != null) {
        // Crear una nueva instancia de Actividad con los datos actualizados
        _actividadCompleta = Actividad(
          id: _actividadCompleta!.id,
          titulo: updatedData['nombre'] ?? _actividadCompleta!.titulo,
          tipo: updatedData['tipoActividad'] ?? _actividadCompleta!.tipo,
          descripcion: updatedData['descripcion'] ?? _actividadCompleta!.descripcion,
          fini: updatedData['fechaInicio'] ?? _actividadCompleta!.fini,
          ffin: updatedData['fechaFin'] ?? _actividadCompleta!.ffin,
          hini: updatedData['hini'] ?? _actividadCompleta!.hini,
          hfin: updatedData['hfin'] ?? _actividadCompleta!.hfin,
          previstaIni: _actividadCompleta!.previstaIni,
          transporteReq: updatedData['transporteReq'] ?? _actividadCompleta!.transporteReq,
          comentTransporte: _actividadCompleta!.comentTransporte,
          precioTransporte: updatedData['precioTransporte'] ?? _actividadCompleta!.precioTransporte,
          // NO actualizar empresaTransporte aquí - se actualizará después de guardar con datos completos
          empresaTransporte: _actividadCompleta!.empresaTransporte,
          alojamientoReq: updatedData['alojamientoReq'] ?? _actividadCompleta!.alojamientoReq,
          comentAlojamiento: _actividadCompleta!.comentAlojamiento,
          precioAlojamiento: updatedData['precioAlojamiento'] ?? _actividadCompleta!.precioAlojamiento,
          alojamiento: _actividadCompleta!.alojamiento,
          comentarios: _actividadCompleta!.comentarios,
          estado: updatedData['estado'] ?? _actividadCompleta!.estado,
          comentEstado: _actividadCompleta!.comentEstado,
          incidencias: _actividadCompleta!.incidencias,
          urlFolleto: _actividadCompleta!.urlFolleto,
          responsable: nuevoProfesor,
          localizacion: _actividadCompleta!.localizacion,
          importePorAlumno: _actividadCompleta!.importePorAlumno,
          presupuestoEstimado: updatedData['presupuestoEstimado'] ?? _actividadCompleta!.presupuestoEstimado,
          costoReal: _actividadCompleta!.costoReal,
        );
      }
      
      // Verificar si hay cambios reales comparando con el original
      // Esto se ejecuta cada vez que se edita, así que siempre compara con los últimos valores
      isDataChanged = _hasRealChanges();
      
      // Evitar imprimir datos binarios en bruto (ej. fichero en bytes)
      try {
        final safeUpdated = Map<String, dynamic>.from(updatedData);
        if (safeUpdated.containsKey('folletoBytes')) {
          final bytes = safeUpdated['folletoBytes'];
          final len = (bytes is List<int>) ? bytes.length : null;
          safeUpdated['folletoBytes'] = '<bytes length: ${len ?? 'unknown'}>';
        }
        if (safeUpdated.containsKey('selectedImages')) {
          safeUpdated['selectedImages'] = '<images count: ${selectedImages.length}>';
        }

      } catch (e) {

      }

    });
  }

  Future<void> _saveChanges() async {
    // Verificar si hay cambios para guardar
    if (selectedImages.isEmpty && imagesToDelete.isEmpty && _datosEditados == null) {
      if (mounted) {
        _showMessage('No hay cambios para guardar', isError: false);
      }
      return;
    }

    // Mostrar diálogo de carga
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Guardando cambios...'),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    try {
      // Usar SaveHandler para procesar todos los cambios
      final result = await _saveHandler.saveChanges(
        actividadOriginal: _actividadOriginal!,
        actividadId: widget.actividad.id,
        datosEditados: _datosEditados,
        selectedImages: selectedImages,
        selectedImagesDescriptions: selectedImagesDescriptions,
        imagesToDelete: imagesToDelete,
      );

      // Cerrar diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result.success) {
        // Recargar las fotos de la actividad
        final photos = await _photoService.fetchPhotosByActivityId(widget.actividad.id);
        
        // Si hubo cambios significativos, recargar actividad completa
        if (_datosEditados != null && 
            (_datosEditados!.containsKey('localizaciones_changed') || 
             _datosEditados!.containsKey('transporteReq') ||
             _datosEditados!.containsKey('alojamientoReq'))) {
          await _loadActivityDetails();
        }
        
        if (mounted) {
          setState(() {
            // Actualizar con la actividad devuelta por SaveHandler
            _actividadOriginal = result.actividad;
            _actividadCompleta = result.actividad;
            imagesActividad = photos;
            selectedImages.clear();
            selectedImagesDescriptions.clear();
            imagesToDelete.clear();
            isDataChanged = false;
            _datosEditados = null;
          });

          _showMessage('Cambios guardados correctamente', isError: false);
        }
      } else {
        throw Exception('Error al guardar algunos cambios');
      }
    } catch (e) {
      // Cerrar diálogo de carga si aún está abierto
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showMessage('Error al guardar: ${e.toString()}', isError: true);
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isError ? Icons.error : Icons.check_circle,
                color: isError ? Colors.red : Colors.green,
              ),
              SizedBox(width: 8),
              Text(isError ? 'Error' : 'Éxito'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _uploadSelectedImages() async {
    try {
      // Para cada imagen seleccionada, subirla individualmente
      for (var xFile in selectedImages) {
        final bytes = await xFile.readAsBytes();
        final fileName = xFile.name;
        
        // Obtener la descripción asociada a esta imagen (si existe)
        final description = selectedImagesDescriptions[xFile.path] ?? '';

        // Subir la imagen usando el método del ApiService
        bool success = await _photoService.uploadPhotosFromBytes(
          activityId: widget.actividad.id,
          bytes: bytes,
          filename: fileName,
          descripcion: description,
        );

        if (!success) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si estamos dentro del shell (desktop/web)
    final bool isInsideShell = isInsideDesktopShell(context);
    final bool isDesktopWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    // Si estamos en desktop/web Y dentro del shell, mostrar solo el contenido
    if (isDesktopWeb && isInsideShell) {
      return Stack(
        children: [
          Theme.of(context).brightness == Brightness.dark
              ? GradientBackgroundDark(child: Container())
              : GradientBackgroundLight(child: Container()),
          Material(
            color: Colors.transparent,
            child: _buildLayout(context),
          ),
        ],
      );
    }
    
    // Si no estamos en el shell, mostrar la vista completa con Scaffold
    return WillPopScope(
      onWillPop: () => onWillPopSalir(context),
      child: Stack(
        children: [
          Theme.of(context).brightness == Brightness.dark
              ? GradientBackgroundDark(
            child: Container(),
          )
              : GradientBackgroundLight(
            child: Container(),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: null,
            drawer: !(kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                ? OrientationBuilder(
              builder: (context, orientation) {
                return orientation == Orientation.portrait
                    ? Menu()
                    : MenuLandscape();
              },
            )
                : Menu(),
            body: _buildLayout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    // Si estamos cargando, mostrar indicador
    if (_isLoadingActivity) {
      return Center(child: CircularProgressIndicator());
    }
    
    // Usar la actividad completa si está disponible, si no usar la del widget
    final actividadAMostrar = _actividadCompleta ?? widget.actividad;
    
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return ActivityDetailLargeLandscapeLayout(
        actividad: actividadAMostrar,
        isDarkTheme: widget.isDarkTheme,
        onToggleTheme: widget.onToggleTheme,
        isDataChanged: isDataChanged,
        isAdminOrSolicitante: isAdminOrSolicitante,
        imagesActividad: imagesActividad,
        selectedImages: selectedImages,
        selectedImagesDescriptions: selectedImagesDescriptions,
        showImagePicker: _showImagePicker,
        removeSelectedImage: _removeSelectedImage,
        removeApiImage: _removeApiImage,
        removeApiImageConfirmed: _removeApiImageConfirmed,
        editLocalImage: _editLocalImage,
        saveChanges: _saveChanges,
        revertChanges: _revertChanges,
        onActivityDataChanged: _handleActivityDataChanged,
        reloadTrigger: _widgetKey, // Pasar el contador de reload
      );
    } else {
      return OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return ActivityDetailPortraitLayout(
              actividad: actividadAMostrar,
              isDarkTheme: widget.isDarkTheme,
              onToggleTheme: widget.onToggleTheme,
              isDataChanged: isDataChanged,
              isAdminOrSolicitante: isAdminOrSolicitante,
              imagesActividad: imagesActividad,
              selectedImages: selectedImages,
              selectedImagesDescriptions: selectedImagesDescriptions,
              showImagePicker: _showImagePicker,
              removeSelectedImage: _removeSelectedImage,
              removeApiImage: _removeApiImage,
              removeApiImageConfirmed: _removeApiImageConfirmed,
              editLocalImage: _editLocalImage,
              saveChanges: _saveChanges,
              revertChanges: _revertChanges,
              onActivityDataChanged: _handleActivityDataChanged,
              reloadTrigger: _widgetKey,
            );
          } else {
            return ActivityDetailSmallLandscapeLayout(
              actividad: actividadAMostrar,
              isDarkTheme: widget.isDarkTheme,
              onToggleTheme: widget.onToggleTheme,
              isDataChanged: isDataChanged,
              isAdminOrSolicitante: isAdminOrSolicitante,
              imagesActividad: imagesActividad,
              selectedImages: selectedImages,
              selectedImagesDescriptions: selectedImagesDescriptions,
              showImagePicker: _showImagePicker,
              removeSelectedImage: _removeSelectedImage,
              removeApiImage: _removeApiImage,
              removeApiImageConfirmed: _removeApiImageConfirmed,
              editLocalImage: _editLocalImage,
              saveChanges: _saveChanges,
              revertChanges: _revertChanges,
              onActivityDataChanged: _handleActivityDataChanged,
              reloadTrigger: _widgetKey,
            );
          }
        },
      );
    }
  }
}
