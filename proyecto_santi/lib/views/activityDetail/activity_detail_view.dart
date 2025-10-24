import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/components/app_bar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'package:proyecto_santi/views/activityDetail/views/activity_detail_large_landscape_layout.dart';
import 'package:proyecto_santi/views/activityDetail/views/activity_detail_small_landscape_layout.dart';
import 'package:proyecto_santi/views/activityDetail/views/activity_detail_portrait_layout.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import 'package:proyecto_santi/func.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

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
  final ApiService _apiService = ApiService();
  bool isDataChanged = false;
  bool isAdminOrSolicitante = true;
  List<Photo> imagesActividad = [];
  List<XFile> selectedImages = [];
  bool isDialogVisible = false;
  bool isPopupVisible = false;
  bool isCameraVisible = false;
  bool isSaving = false;
  bool isLoading = true;
  
  // Copia mutable de la actividad para editar
  late Actividad _currentActividad;
  // Copia del estado original para revertir
  late Actividad _originalActividad;

  @override
  void initState() {
    super.initState();
    _currentActividad = widget.actividad;
    _originalActividad = widget.actividad;
    _loadActivityDetails();
  }

  Future<void> _loadActivityDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Cargar detalles completos de la actividad desde la API
      final actividadCompleta = await _apiService.fetchActivityById(widget.actividad.id);
      
      if (actividadCompleta != null) {
        setState(() {
          _currentActividad = actividadCompleta;
          _originalActividad = actividadCompleta; // Guardar estado original
        });
      }

      // Cargar fotos
      final photos = await _apiService.fetchPhotosByActivityId(widget.actividad.id);
      setState(() {
        imagesActividad = photos;
        isLoading = false;
      });
    } catch (e) {
      print('[ActivityDetailView] Error cargando detalles: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _revertChanges() {
    setState(() {
      _currentActividad = _originalActividad;
      selectedImages.clear();
      isDataChanged = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cambios revertidos'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImages.add(image);
        isDataChanged = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (isSaving) return;
    
    setState(() {
      isSaving = true;
    });

    try {
      // Guardar cambios de información básica si hay
      if (isDataChanged) {
        // Actualizar la actividad en la API
        await _apiService.updateActividad(
          _currentActividad.id,
          {
            'nombre': _currentActividad.titulo,
            'descripcion': _currentActividad.descripcion,
            'fechaInicio': _currentActividad.fini,
            'fechaFin': _currentActividad.ffin,
            'aprobada': _currentActividad.estado == 'Aprobada',
          },
        );
      }

      // Subir imágenes seleccionadas
      for (var image in selectedImages) {
        await _apiService.uploadPhoto(
          activityId: _currentActividad.id,
          imagePath: image.path,
        );
      }

      // Recargar fotos
      final photos = await _apiService.fetchPhotosByActivityId(_currentActividad.id);
      
      setState(() {
        imagesActividad = photos;
        selectedImages.clear();
        isDataChanged = false;
        isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cambios guardados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar cambios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleActivityUpdate(Map<String, dynamic> updatedData) {
    setState(() {
      _currentActividad = Actividad(
        id: _currentActividad.id,
        titulo: updatedData['nombre'] ?? _currentActividad.titulo,
        tipo: _currentActividad.tipo,
        descripcion: updatedData['descripcion'],
        fini: updatedData['fechaInicio'] ?? _currentActividad.fini,
        ffin: updatedData['fechaFin'] ?? _currentActividad.ffin,
        hini: _currentActividad.hini,
        hfin: _currentActividad.hfin,
        previstaIni: _currentActividad.previstaIni,
        transporteReq: _currentActividad.transporteReq,
        comentTransporte: _currentActividad.comentTransporte,
        alojamientoReq: _currentActividad.alojamientoReq,
        comentAlojamiento: _currentActividad.comentAlojamiento,
        comentarios: _currentActividad.comentarios,
        estado: updatedData['aprobada'] == true ? 'Aprobada' : 'Pendiente',
        comentEstado: _currentActividad.comentEstado,
        incidencias: _currentActividad.incidencias,
        urlFolleto: _currentActividad.urlFolleto,
        solicitante: _currentActividad.solicitante,
        importePorAlumno: _currentActividad.importePorAlumno,
        latitud: _currentActividad.latitud,
        longitud: _currentActividad.longitud,
        profesorResponsableNombre: _currentActividad.profesorResponsableNombre,
        profesorResponsableUuid: _currentActividad.profesorResponsableUuid,
      );
      isDataChanged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            appBar: shouldShowAppBar()
                ? AndroidAppBar(
              onToggleTheme: widget.onToggleTheme,
              title: 'Actividades',
            )
                : null,
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
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return ActivityDetailLargeLandscapeLayout(
        actividad: _currentActividad,
        isDarkTheme: widget.isDarkTheme,
        onToggleTheme: widget.onToggleTheme,
        isDataChanged: isDataChanged,
        isAdminOrSolicitante: isAdminOrSolicitante,
        imagesActividad: imagesActividad,
        selectedImages: selectedImages,
        showImagePicker: _showImagePicker,
        saveChanges: _saveChanges,
        revertChanges: _revertChanges,
        onActivityUpdate: _handleActivityUpdate,
      );
    } else {
      return OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return ActivityDetailPortraitLayout(
              actividad: _currentActividad,
              isDarkTheme: widget.isDarkTheme,
              onToggleTheme: widget.onToggleTheme,
              isDataChanged: isDataChanged,
              isAdminOrSolicitante: isAdminOrSolicitante,
              imagesActividad: imagesActividad,
              selectedImages: selectedImages,
              showImagePicker: _showImagePicker,
              saveChanges: _saveChanges,
              revertChanges: _revertChanges,
              onActivityUpdate: _handleActivityUpdate,
            );
          } else {
            return ActivityDetailSmallLandscapeLayout(
              actividad: _currentActividad,
              isDarkTheme: widget.isDarkTheme,
              onToggleTheme: widget.onToggleTheme,
              isDataChanged: isDataChanged,
              isAdminOrSolicitante: isAdminOrSolicitante,
              imagesActividad: imagesActividad,
              selectedImages: selectedImages,
              showImagePicker: _showImagePicker,
              saveChanges: _saveChanges,
              revertChanges: _revertChanges,
              onActivityUpdate: _handleActivityUpdate,
            );
          }
        },
      );
    }
  }
}