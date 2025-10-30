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
import 'package:proyecto_santi/views/activityDetail/views/activity_detail_large_landscape_layout.dart';
import 'package:proyecto_santi/views/activityDetail/views/activity_detail_small_landscape_layout.dart';
import 'package:proyecto_santi/views/activityDetail/views/activity_detail_portrait_layout.dart';
import 'package:proyecto_santi/views/activityDetail/components/images/image_preview_dialog.dart';
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
      print('[ActivityDetail] Error loading activity details: $e');
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
      print('[ActivityDetail] Error loading photos: $e');
    }
  }

  void _showImagePicker() async {
    final ImagePicker picker = ImagePicker();
    
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    XFile? image;
    
    // En móvil, mostrar opciones de cámara o galería
    if (isMobile) {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Color.fromRGBO(25, 118, 210, 0.25),
                        Color.fromRGBO(21, 101, 192, 0.20),
                      ]
                    : [
                        Color.fromRGBO(187, 222, 251, 0.95),
                        Color.fromRGBO(144, 202, 249, 0.85),
                      ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle visual
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white30 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Título
                  Text(
                    'Seleccionar imagen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Color(0xFF1976d2),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Opción: Tomar foto
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF1976d2).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Color(0xFF1976d2),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Tomar foto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Usa la cámara',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  // Opción: Galería
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: Colors.purple,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Galería',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Elige de tus fotos',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  SizedBox(height: 8),
                  // Botón cancelar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: isDark 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      
      // Si el usuario canceló, salir
      if (source == null) return;
      
      // Obtener imagen de la fuente seleccionada
      image = await picker.pickImage(source: source);
    } else {
      // En desktop, usar directamente la galería
      image = await picker.pickImage(source: ImageSource.gallery);
    }
    
    if (image != null && mounted) {
      // Capturar la imagen en una variable local no-nullable
      final XFile selectedImage = image;
      
      // Mostrar diálogo de preview con descripción
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return ImagePreviewDialog(
            imageFile: selectedImage,
            onConfirm: (description) {
              // Cerrar el diálogo
              Navigator.of(dialogContext).pop();
              
              // Añadir la imagen con su descripción
              setState(() {
                selectedImages.add(selectedImage);
                // Guardar la descripción asociada a esta imagen
                if (description.isNotEmpty) {
                  selectedImagesDescriptions[selectedImage.path] = description;
                }
                isDataChanged = true;
              });
            },
          );
        },
      );
    }
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar imagen'),
          content: Text('¿Está seguro que quiere eliminar esta imagen? Se eliminará al guardar los cambios.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && index < imagesActividad.length) {
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
  
  // Método para editar la descripción de una imagen local
  void _editLocalImage(int index) async {
    if (index >= selectedImages.length) return;
    
    final image = selectedImages[index];
    final currentDescription = selectedImagesDescriptions[image.path];
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImagePreviewDialog(
          imageFile: image,
          initialDescription: currentDescription,
          isEditing: true,
          onConfirm: (description) {
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
      },
    );
  }
  
  
  bool _hasRealChanges() {

    
    // Verificar si hay imágenes nuevas o marcadas para eliminar
    if (selectedImages.isNotEmpty || imagesToDelete.isNotEmpty) {

      return true;
    }
    
    // Verificar si hay cambios en participantes (profesores o grupos)
    if (_datosEditados != null) {
      if (_datosEditados!.containsKey('profesoresParticipantes') || 
          _datosEditados!.containsKey('gruposParticipantes')) {

        return true;
      }
    }

    // Verificar si hay cambios en gastos personalizados (gastos varios)
    if (_datosEditados != null) {
      if (_datosEditados!.containsKey('gastosPersonalizados') ||
          _datosEditados!.containsKey('budgetChanged')) {

        return true;
      }
    }

    // Verificar si se seleccionó o cambió un folleto (archivo PDF)
    if (_datosEditados != null) {
      if (_datosEditados!.containsKey('folletoFileName') ||
          _datosEditados!.containsKey('folletoBytes') ||
          _datosEditados!.containsKey('folletoFilePath') ||
          _datosEditados!.containsKey('deleteFolleto')) {

        return true;
      }
    }
    
    // Verificar si hay cambios en los datos editados
    if (_datosEditados == null || _actividadOriginal == null) {

      return false;
    }
    



    
    // Comparar cada campo editado con el original
    // Solo consideramos que hay cambio si el valor es diferente al original
    
    final nombre = _datosEditados!['nombre'] as String?;
    if (nombre != null) {
      final nombreTrimmed = nombre.trim();
      final originalTrimmed = _actividadOriginal!.titulo.trim();

      if (nombreTrimmed != originalTrimmed) {

        return true;
      }
    }
    
    final descripcion = _datosEditados!['descripcion'] as String?;
    if (descripcion != null) {
      final descripcionTrimmed = descripcion.trim();
      final originalDescripcionTrimmed = (_actividadOriginal!.descripcion?.trim() ?? '');

      if (descripcionTrimmed != originalDescripcionTrimmed) {

        return true;
      }
    }
    
    final fechaInicio = _datosEditados!['fechaInicio'] as String?;
    if (fechaInicio != null) {
      // Normalizar las fechas parseándolas como DateTime y comparándolas
      try {
        final fechaEditada = DateTime.parse(fechaInicio);
        final fechaOriginal = DateTime.parse(_actividadOriginal!.fini);
        // Comparar solo hasta los segundos, ignorando milisegundos
        final editadaNormalizada = DateTime(fechaEditada.year, fechaEditada.month, fechaEditada.day, 
                                             fechaEditada.hour, fechaEditada.minute, fechaEditada.second);
        final originalNormalizada = DateTime(fechaOriginal.year, fechaOriginal.month, fechaOriginal.day,
                                              fechaOriginal.hour, fechaOriginal.minute, fechaOriginal.second);

        if (editadaNormalizada != originalNormalizada) {

          return true;
        }
      } catch (e) {

        // Si hay error parseando, comparar como strings
        if (fechaInicio != _actividadOriginal!.fini) {
          return true;
        }
      }
    }
    
    final fechaFin = _datosEditados!['fechaFin'] as String?;
    if (fechaFin != null) {
      // Normalizar las fechas parseándolas como DateTime y comparándolas
      try {
        final fechaEditada = DateTime.parse(fechaFin);
        final fechaOriginal = DateTime.parse(_actividadOriginal!.ffin);
        // Comparar solo hasta los segundos, ignorando milisegundos
        final editadaNormalizada = DateTime(fechaEditada.year, fechaEditada.month, fechaEditada.day,
                                             fechaEditada.hour, fechaEditada.minute, fechaEditada.second);
        final originalNormalizada = DateTime(fechaOriginal.year, fechaOriginal.month, fechaOriginal.day,
                                              fechaOriginal.hour, fechaOriginal.minute, fechaOriginal.second);

        if (editadaNormalizada != originalNormalizada) {

          return true;
        }
      } catch (e) {

        // Si hay error parseando, comparar como strings
        if (fechaFin != _actividadOriginal!.ffin) {
          return true;
        }
      }
    }
    
    final hini = _datosEditados!['hini'] as String?;
    if (hini != null) {
      // Normalizar las horas a formato HH:mm (sin segundos)
      String hiniNueva = hini;
      if (hiniNueva.length > 5 && hiniNueva.substring(5, 6) == ':') {
        hiniNueva = hiniNueva.substring(0, 5);
      }
      
      String hiniOriginal = _actividadOriginal!.hini;
      if (hiniOriginal.length > 5 && hiniOriginal.substring(5, 6) == ':') {
        hiniOriginal = hiniOriginal.substring(0, 5);
      }
      

      if (hiniNueva != hiniOriginal) {

        return true;
      }
    }
    
    final hfin = _datosEditados!['hfin'] as String?;
    if (hfin != null) {
      // Normalizar las horas a formato HH:mm (sin segundos)
      String hfinNueva = hfin;
      if (hfinNueva.length > 5 && hfinNueva.substring(5, 6) == ':') {
        hfinNueva = hfinNueva.substring(0, 5);
      }
      
      String hfinOriginal = _actividadOriginal!.hfin;
      if (hfinOriginal.length > 5 && hfinOriginal.substring(5, 6) == ':') {
        hfinOriginal = hfinOriginal.substring(0, 5);
      }
      

      if (hfinNueva != hfinOriginal) {

        return true;
      }
    }
    
    final aprobada = _datosEditados!['aprobada'] as bool?;
    if (aprobada != null) {
      final estadoOriginal = _actividadOriginal!.estado == 'Aprobada';

      if (aprobada != estadoOriginal) {

        return true;
      }
    }
    
    // Comparar profesor
    final profesorId = _datosEditados!['profesorId'] as String?;
    if (profesorId != null) {
      final profesorOriginalId = _actividadOriginal!.solicitante?.uuid;

      if (profesorId != profesorOriginalId) {

        return true;
      }
    }
    
    // Ya no comparamos departamento, ahora usamos responsable
    
    // Comparar transporteReq
    final transporteReq = _datosEditados!['transporteReq'] as int?;
    if (transporteReq != null) {

      if (transporteReq != _actividadOriginal!.transporteReq) {

        return true;
      }
    }
    
    // Comparar alojamientoReq
    final alojamientoReq = _datosEditados!['alojamientoReq'] as int?;
    if (alojamientoReq != null) {

      if (alojamientoReq != _actividadOriginal!.alojamientoReq) {

        return true;
      }
    }
    
    // Comparar presupuestoEstimado
    final presupuestoEstimado = _datosEditados!['presupuestoEstimado'] as double?;
    if (presupuestoEstimado != null) {
      final presupuestoOriginal = _actividadOriginal!.presupuestoEstimado ?? 0.0;

      if ((presupuestoEstimado - presupuestoOriginal).abs() > 0.01) { // Comparar con tolerancia para decimales

        return true;
      }
    }
    
    // Comparar precioTransporte
    final precioTransporte = _datosEditados!['precioTransporte'] as double?;
    if (precioTransporte != null) {
      final precioOriginal = _actividadOriginal!.precioTransporte ?? 0.0;

      if ((precioTransporte - precioOriginal).abs() > 0.01) { // Comparar con tolerancia para decimales

        return true;
      }
    }
    
    // Comparar empresaTransporteId
    final empresaTransporteId = _datosEditados!['empresaTransporteId'] as int?;
    if (empresaTransporteId != null) {
      final empresaOriginalId = _actividadOriginal!.empresaTransporte?.id;

      if (empresaTransporteId != empresaOriginalId) {

        return true;
      }
    }
    
    // Comparar alojamientoId
    final alojamientoId = _datosEditados!['alojamientoId'];
    if (alojamientoId != null) {
      final alojamientoOriginalId = _actividadOriginal!.alojamiento?.id;

      if (alojamientoId != alojamientoOriginalId) {

        return true;
      }
    }
    
    // Comparar precioAlojamiento
    final precioAlojamiento = _datosEditados!['precioAlojamiento'] as double?;
    if (precioAlojamiento != null) {
      final precioOriginal = 0.0; // El precio no está en el alojamiento, se guarda en la actividad

      if ((precioAlojamiento - precioOriginal).abs() > 0.01) { // Comparar con tolerancia para decimales

        return true;
      }
    }
    

    return false;
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
    
    // Después de recargar, incrementar el widgetKey para forzar reconstrucción
    setState(() {
      _widgetKey++; // Incrementar para forzar reconstrucción del widget con datos actualizados
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
        print('[Error] Buscando profesor: $e');
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
      bool success = true;
      




      
      // 1. Guardar cambios en los datos de la actividad (nombre, descripción, etc.)
      // Solo si hay cambios en campos de actividad (no participantes)
      final hasActivityChanges = _datosEditados != null && 
          _datosEditados!.keys.any((key) => 
            key != 'profesoresParticipantes' && 
            key != 'gruposParticipantes'
          );
      
      if (hasActivityChanges) {
        try {



          _datosEditados!.forEach((key, value) {
            if (key != 'folletoBytes' && key != 'selectedImages') {

            }
          });


          
          // Calcular el coste real sumando solo los servicios activados
          final transporteReq = (_datosEditados!['transporteReq'] ?? _actividadOriginal!.transporteReq) ?? 0;
          final alojamientoReq = (_datosEditados!['alojamientoReq'] ?? _actividadOriginal!.alojamientoReq) ?? 0;
          
          final precioTransporte = (_datosEditados!['precioTransporte'] ?? _actividadOriginal!.precioTransporte) ?? 0.0;
          final precioAlojamiento = (_datosEditados!['precioAlojamiento'] ?? _actividadOriginal!.precioAlojamiento) ?? 0.0;
          
          // Obtener gastos personalizados de la actividad
          final gastoService = GastoPersonalizadoService(ApiService());
          List<GastoPersonalizado> gastosPersonalizados = [];
          try {
            gastosPersonalizados = await gastoService.fetchGastosByActividad(widget.actividad.id);
          } catch (e) {
            print('[ERROR] Error al cargar gastos personalizados: $e');
          }
          
          // Calcular total de gastos personalizados
          final totalGastosPersonalizados = gastosPersonalizados.fold<double>(
            0.0,
            (sum, gasto) => sum + gasto.cantidad,
          );
          
          // Solo sumar al coste real si el switch está activado (req == 1) + gastos personalizados
          final costoRealCalculado = (transporteReq == 1 ? precioTransporte : 0.0) + 
                                     (alojamientoReq == 1 ? precioAlojamiento : 0.0) +
                                     totalGastosPersonalizados;

          
          // Crear objeto de EmpresaTransporte si hay un ID
          EmpresaTransporte? empresaTransporteParaGuardar;
          if (_datosEditados!['empresaTransporteId'] != null) {
            empresaTransporteParaGuardar = EmpresaTransporte(
              id: _datosEditados!['empresaTransporteId'] as int,
              nombre: '', // El backend no necesita el nombre, solo el ID
              cif: '',
            );

          } else {
            empresaTransporteParaGuardar = _actividadOriginal!.empresaTransporte;

          }
          
          // Obtener el alojamiento desde _datosEditados o usar el original
          Alojamiento? alojamientoParaGuardar;
          if (_datosEditados!.containsKey('alojamiento') && _datosEditados!['alojamiento'] != null) {
            alojamientoParaGuardar = _datosEditados!['alojamiento'] as Alojamiento;

          } else {
            alojamientoParaGuardar = _actividadOriginal!.alojamiento;

          }
          
          // Crear un objeto Actividad completo con los datos actualizados
          final actividadParaGuardar = Actividad(
            id: _actividadOriginal!.id,
            titulo: _datosEditados!['nombre'] ?? _actividadOriginal!.titulo,
            tipo: _datosEditados!['tipoActividad'] ?? _actividadOriginal!.tipo,
            descripcion: _datosEditados!['descripcion'] ?? _actividadOriginal!.descripcion,
            fini: _datosEditados!['fechaInicio'] ?? _actividadOriginal!.fini,
            ffin: _datosEditados!['fechaFin'] ?? _actividadOriginal!.ffin,
            hini: _datosEditados!['hini'] ?? _actividadOriginal!.hini,
            hfin: _datosEditados!['hfin'] ?? _actividadOriginal!.hfin,
            previstaIni: _actividadOriginal!.previstaIni,
            transporteReq: _datosEditados!['transporteReq'] ?? _actividadOriginal!.transporteReq,
            comentTransporte: _actividadOriginal!.comentTransporte,
            precioTransporte: _datosEditados!['precioTransporte'] ?? _actividadOriginal!.precioTransporte,
            empresaTransporte: empresaTransporteParaGuardar,
            alojamientoReq: _datosEditados!['alojamientoReq'] ?? _actividadOriginal!.alojamientoReq,
            comentAlojamiento: _actividadOriginal!.comentAlojamiento,
            precioAlojamiento: _datosEditados!['precioAlojamiento'] ?? _actividadOriginal!.precioAlojamiento,
            alojamiento: alojamientoParaGuardar,
            comentarios: _actividadOriginal!.comentarios,
            estado: _datosEditados!['estado'] ?? _actividadOriginal!.estado,
            comentEstado: _actividadOriginal!.comentEstado,
            incidencias: _actividadOriginal!.incidencias,
            urlFolleto: _actividadOriginal!.urlFolleto,
            responsable: _actividadCompleta?.responsable,
            localizacion: _actividadOriginal!.localizacion,
            importePorAlumno: _actividadOriginal!.importePorAlumno,
            presupuestoEstimado: _datosEditados!['presupuestoEstimado'] ?? _actividadOriginal!.presupuestoEstimado,
            costoReal: costoRealCalculado,
          );
          







          

          
          // Usar updateActivity en lugar de updateActivityFields
          final actividadActualizada = await _actividadService.updateActivity(
            widget.actividad.id,
            actividadParaGuardar,
          );
          
          if (actividadActualizada != null) {





            
            // La respuesta del API puede no incluir el objeto completo de Profesor (responsable)
            // Si se cambió el profesor, cargar los datos completos
            Profesor? profesorCompleto = actividadActualizada.responsable;
            
            // Si tenemos un UUID de profesor pero no el objeto completo, cargarlo
            if (_datosEditados!.containsKey('profesorId') && _datosEditados!['profesorId'] != null) {
              try {
                final profesores = await _profesorService.fetchProfesores();
                profesorCompleto = profesores.firstWhere(
                  (p) => p.uuid == _datosEditados!['profesorId'],
                  orElse: () => actividadActualizada.solicitante ?? _actividadOriginal!.solicitante!,
                );

              } catch (e) {
                print('[ERROR] Error cargando profesor completo: $e');
                profesorCompleto = actividadActualizada.solicitante;
              }
            }
            
            // Ya no cargamos departamento
            
            // Si tenemos un ID de empresa de transporte pero no el objeto completo, cargarlo
            EmpresaTransporte? empresaTransporteCompleta = actividadActualizada.empresaTransporte;
            
            // Verificar si necesitamos cargar la empresa:
            // 1. Si viene null del backend pero tenemos un ID guardado
            // 2. O si hay un cambio pendiente de empresaTransporteId
            final needsEmpresaLoad = empresaTransporteCompleta == null || 
                                     (_datosEditados!.containsKey('empresaTransporteId') && 
                                      _datosEditados!['empresaTransporteId'] != null &&
                                      _datosEditados!['empresaTransporteId'] != empresaTransporteCompleta.id);
            
            if (needsEmpresaLoad) {
              try {

                final empresas = await _actividadService.fetchEmpresasTransporte();
                
                // Obtener el ID: de datosEditados o del objeto original
                final empresaId = _datosEditados!['empresaTransporteId'] ?? 
                                 actividadActualizada.empresaTransporte?.id ??
                                 _actividadOriginal!.empresaTransporte?.id;
                
                if (empresaId != null) {
                  empresaTransporteCompleta = empresas.firstWhere(
                    (e) => e.id == empresaId,
                    orElse: () => throw Exception('Empresa con ID $empresaId no encontrada'),
                  );

                } else {

                }
              } catch (e) {
                print('[ERROR] Error cargando empresa de transporte completa: $e');
                empresaTransporteCompleta = actividadActualizada.empresaTransporte ?? _actividadOriginal!.empresaTransporte;
              }
            } else {

            }
            
            // Si tenemos un ID de alojamiento pero no el objeto completo, cargarlo
            Alojamiento? alojamientoCompleto = actividadActualizada.alojamiento;
            
            // Verificar si necesitamos cargar el alojamiento:
            // 1. Si viene null del backend pero tenemos un ID guardado
            // 2. O si hay un cambio pendiente de alojamientoId
            final needsAlojamientoLoad = alojamientoCompleto == null || 
                                        (_datosEditados!.containsKey('alojamientoId') && 
                                         _datosEditados!['alojamientoId'] != null &&
                                         _datosEditados!['alojamientoId'] != alojamientoCompleto?.id);
            
            if (needsAlojamientoLoad) {
              try {

                final alojamientos = await _actividadService.fetchAlojamientos();
                
                // Obtener el ID: de datosEditados o del objeto original
                final alojamientoId = _datosEditados!['alojamientoId'] ?? 
                                     actividadActualizada.alojamiento?.id ??
                                     _actividadOriginal!.alojamiento?.id;
                
                if (alojamientoId != null) {
                  alojamientoCompleto = alojamientos.firstWhere(
                    (a) => a.id == alojamientoId,
                    orElse: () => throw Exception('Alojamiento con ID $alojamientoId no encontrado'),
                  );

                } else {

                }
              } catch (e) {
                print('[ERROR] Error cargando alojamiento completo: $e');
                alojamientoCompleto = actividadActualizada.alojamiento ?? _actividadOriginal!.alojamiento;
              }
            } else {

            }
            
            // Crear una copia completa con los objetos cargados
            final actividadCompletaConObjetos = Actividad(
              id: actividadActualizada.id,
              titulo: actividadActualizada.titulo,
              tipo: actividadActualizada.tipo,
              descripcion: actividadActualizada.descripcion,
              fini: actividadActualizada.fini,
              ffin: actividadActualizada.ffin,
              hini: actividadActualizada.hini,
              hfin: actividadActualizada.hfin,
              previstaIni: actividadActualizada.previstaIni,
              transporteReq: actividadActualizada.transporteReq,
              comentTransporte: actividadActualizada.comentTransporte,
              precioTransporte: actividadActualizada.precioTransporte,
              empresaTransporte: empresaTransporteCompleta,
              alojamientoReq: actividadActualizada.alojamientoReq,
              comentAlojamiento: actividadActualizada.comentAlojamiento,
              precioAlojamiento: actividadActualizada.precioAlojamiento,
              alojamiento: alojamientoCompleto,
              comentarios: actividadActualizada.comentarios,
              estado: actividadActualizada.estado,
              comentEstado: actividadActualizada.comentEstado,
              incidencias: actividadActualizada.incidencias,
              urlFolleto: actividadActualizada.urlFolleto,
              responsable: profesorCompleto,
              localizacion: actividadActualizada.localizacion,
              importePorAlumno: actividadActualizada.importePorAlumno,
              presupuestoEstimado: actividadActualizada.presupuestoEstimado,
              costoReal: actividadActualizada.costoReal,
            );
            
            // Actualizar la actividad original con los nuevos datos completos
            _actividadOriginal = actividadCompletaConObjetos;
            _actividadCompleta = actividadCompletaConObjetos;
            





            
            // NO limpiar _datosEditados aquí, lo haremos al final después de guardar participantes

          } else {
            success = false;
          }
        } catch (e) {
          print('[ERROR] Error actualizando datos de actividad: $e');
          success = false;
        }
      }
      
      // 2. Eliminar las imágenes marcadas
      if (imagesToDelete.isNotEmpty) {
        for (int photoId in imagesToDelete) {
          try {
            await _photoService.deletePhoto(photoId);
          } catch (e) {
            print('[ActivityDetail] Error eliminando foto $photoId: $e');
            success = false;
          }
        }
      }

      // 3. Subir las imágenes nuevas
      if (selectedImages.isNotEmpty) {
        bool uploadSuccess = await _uploadSelectedImages();
        success = success && uploadSuccess;
      }

      // 4. Guardar profesores participantes
      if (_datosEditados != null && _datosEditados!.containsKey('profesoresParticipantes')) {
        try {

          final profesoresParticipantes = _datosEditados!['profesoresParticipantes'] as List<dynamic>;

          
          // Extraer los UUIDs de los objetos Profesor
          final profesoresIds = profesoresParticipantes.map((p) {
            if (p is Map<String, dynamic>) {
              return p['uuid'] as String;
            } else {
              // Es un objeto Profesor
              return (p as dynamic).uuid as String;
            }
          }).toList();
          

          await _profesorService.updateProfesoresParticipantes(widget.actividad.id, profesoresIds);

        } catch (e) {
          print('[ERROR] Error guardando profesores participantes: $e');
          print('[ERROR] Stack trace: ${StackTrace.current}');
          success = false;
        }
      }

      // 5. Guardar grupos participantes
      if (_datosEditados != null && _datosEditados!.containsKey('gruposParticipantes')) {
        try {

          final gruposParticipantes = _datosEditados!['gruposParticipantes'] as List<dynamic>;

          
          // Extraer los datos de los objetos GrupoParticipante
          final gruposData = gruposParticipantes.map((gp) {
            if (gp is Map<String, dynamic>) {
              return {
                'grupoId': gp['grupoId'] as int,
                'numeroParticipantes': gp['numeroParticipantes'] as int,
              };
            } else {
              // Es un objeto GrupoParticipante
              final grupoId = (gp as dynamic).grupo.id as int;
              final numParticipantes = (gp as dynamic).numeroParticipantes as int;
              return {
                'grupoId': grupoId,
                'numeroParticipantes': numParticipantes,
              };
            }
          }).toList();
          

          await _catalogoService.updateGruposParticipantes(widget.actividad.id, gruposData);

        } catch (e) {
          print('[ERROR] Error guardando grupos participantes: $e');
          print('[ERROR] Stack trace: ${StackTrace.current}');
          success = false;
        }
      }

      // 6. Eliminar folleto si se marcó para eliminación
      if (_datosEditados != null && _datosEditados!.containsKey('deleteFolleto') && _datosEditados!['deleteFolleto'] == true) {
        try {

          await _actividadService.deleteFolleto(widget.actividad.id);

        } catch (e) {
          print('[ERROR] Error eliminando folleto: $e');
          success = false;
        }
      }

      // 7. Subir folleto si cambió
      if (_datosEditados != null && _datosEditados!.containsKey('folletoFileName')) {
        try {

          final folletoName = _datosEditados!['folletoFileName'] as String;
          
          String folletoUrl;
          if (_datosEditados!.containsKey('folletoBytes')) {
            // Web: usar bytes
            final folletoBytes = _datosEditados!['folletoBytes'] as Uint8List;
            folletoUrl = await _actividadService.uploadFolleto(
              widget.actividad.id,
              fileBytes: folletoBytes,
              fileName: folletoName,
            );
          } else if (_datosEditados!.containsKey('folletoFilePath')) {
            // Móvil/Desktop: usar path
            final folletoPath = _datosEditados!['folletoFilePath'] as String;
            folletoUrl = await _actividadService.uploadFolleto(
              widget.actividad.id,
              filePath: folletoPath,
              fileName: folletoName,
            );
          } else {
            throw Exception('No se encontró path ni bytes del folleto');
          }
          

        } catch (e) {
          print('[ERROR] Error subiendo folleto: $e');
          print('[ERROR] Stack trace: ${StackTrace.current}');
          success = false;
        }
      }

      // 8. Guardar gastos personalizados si cambiaron
      if (_datosEditados != null && _datosEditados!.containsKey('gastosPersonalizados')) {
        try {
          final gastosService = GastoPersonalizadoService(ApiService());
          final gastosActuales = _datosEditados!['gastosPersonalizados'] as List<GastoPersonalizado>;
          
          // Obtener los gastos actuales de la BD
          final gastosEnBD = await gastosService.fetchGastosByActividad(widget.actividad.id);
          
          // Identificar gastos a crear (tienen ID negativo o null)
          final gastosACrear = gastosActuales.where((g) => g.id == null || g.id! < 0).toList();
          
          // Identificar gastos a eliminar (están en BD pero no en la lista actual)
          final idsActuales = gastosActuales.where((g) => g.id != null && g.id! > 0).map((g) => g.id!).toSet();
          final gastosAEliminar = gastosEnBD.where((g) => !idsActuales.contains(g.id)).toList();
          
          // Crear nuevos gastos
          for (var gasto in gastosACrear) {
            final nuevoGasto = GastoPersonalizado(
              actividadId: widget.actividad.id,
              concepto: gasto.concepto,
              cantidad: gasto.cantidad,
            );
            await gastosService.createGasto(nuevoGasto);
          }
          
          // Eliminar gastos que ya no están
          for (var gasto in gastosAEliminar) {
            if (gasto.id != null) {
              await gastosService.deleteGasto(gasto.id!);
            }
          }
          
          print('[GASTOS] Gastos guardados: ${gastosACrear.length} creados, ${gastosAEliminar.length} eliminados');
        } catch (e) {
          print('[ERROR] Error guardando gastos personalizados: $e');
          success = false;
        }
      }

      // 9. Guardar localizaciones si cambiaron
      if (_datosEditados != null && _datosEditados!.containsKey('localizaciones_modificadas')) {
        try {

          final localizacionesNuevas = _datosEditados!['localizaciones_modificadas'] as List<Localizacion>;
          final localizacionesOriginales = await _localizacionService.fetchLocalizaciones(widget.actividad.id);
          
          // Convertir a listas de IDs para comparar
          final idsOriginales = localizacionesOriginales.map((l) => l['id'] as int).toSet();
          final idsNuevos = localizacionesNuevas.where((l) => l.id > 0).map((l) => l.id).toSet();
          
          // 1. Eliminar localizaciones que ya no están
          for (var loc in localizacionesOriginales) {
            final id = loc['id'] as int;
            if (!idsNuevos.contains(id)) {
              await _localizacionService.removeLocalizacion(widget.actividad.id, id);

            }
          }
          
          // 2. Añadir nuevas localizaciones (las que tienen ID negativo)
          for (var loc in localizacionesNuevas.where((l) => l.id < 0)) {
            // Crear en catálogo primero
            final nuevaLocalizacion = await _localizacionService.createLocalizacion(
              nombre: loc.nombre,
              direccion: loc.direccion,
              ciudad: loc.ciudad,
              provincia: loc.provincia,
              codigoPostal: loc.codigoPostal,
              latitud: loc.latitud,
              longitud: loc.longitud,
              icono: loc.icono,
            );
            
            if (nuevaLocalizacion != null) {
              final localizacionId = nuevaLocalizacion['id'] as int;
              await _localizacionService.addLocalizacion(
                widget.actividad.id,
                localizacionId,
                esPrincipal: loc.esPrincipal,
                icono: loc.icono,
                descripcion: loc.descripcion,
                tipoLocalizacion: loc.tipoLocalizacion,
              );

            }
          }
          
          // 3. Actualizar las existentes (principal e icono)
          for (var loc in localizacionesNuevas.where((l) => l.id > 0)) {
            await _localizacionService.updateLocalizacion(
              widget.actividad.id,
              loc.id,
              esPrincipal: loc.esPrincipal,
              icono: loc.icono,
              descripcion: loc.descripcion,
              tipoLocalizacion: loc.tipoLocalizacion,
            );
          }
          

        } catch (e) {
          print('[ERROR] Error guardando localizaciones: $e');
          print('[ERROR] Stack trace: ${StackTrace.current}');
          success = false;
        }
      }

      // 10. Guardar descripciones de fotos si cambiaron
      if (_datosEditados != null && _datosEditados!.containsKey('photoDescriptionChanges')) {
        try {
          final photoChanges = _datosEditados!['photoDescriptionChanges'] as Map<int, String>;
          
          if (photoChanges.isNotEmpty) {
            print('[ACTIVITY_DETAIL] Guardando ${photoChanges.length} descripciones de fotos...');
            
            for (var entry in photoChanges.entries) {
              try {
                final photoId = entry.key;
                final newDescription = entry.value;
                
                await _photoService.updatePhotoDescription(photoId, newDescription);
                print('[ACTIVITY_DETAIL] Descripción de foto $photoId actualizada correctamente');
              } catch (e) {
                print('[ERROR] Error actualizando descripción de foto ${entry.key}: $e');
                success = false;
              }
            }
            
            print('[ACTIVITY_DETAIL] Descripciones de fotos guardadas correctamente');
          }
        } catch (e) {
          print('[ERROR] Error guardando descripciones de fotos: $e');
          success = false;
        }
      }

      // Cerrar diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        // Recargar las fotos de la actividad
        final photos = await _photoService.fetchPhotosByActivityId(widget.actividad.id);
        
        // Si hubo cambios en localizaciones o en campos de actividad (transporte/alojamiento), forzar recarga de la actividad completa
        if (_datosEditados != null && 
            (_datosEditados!.containsKey('localizaciones_changed') || 
             _datosEditados!.containsKey('transporteReq') ||
             _datosEditados!.containsKey('alojamientoReq'))) {
          await _loadActivityDetails();
        }
        
        if (mounted) {
          setState(() {
            imagesActividad = photos;
            selectedImages.clear();
            selectedImagesDescriptions.clear();
            imagesToDelete.clear();
            isDataChanged = false;
            _datosEditados = null; // Limpiar datos editados después de guardar exitosamente
          });

          _showMessage('Cambios guardados correctamente', isError: false);
        }
      } else {
        throw Exception('Error al guardar algunos cambios');
      }
    } catch (e) {
      print('Error en _saveChanges: $e');
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
      print('Error uploading images: $e');
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
              key: ValueKey(_widgetKey), // Forzar reconstrucción al revertir
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
              editLocalImage: _editLocalImage,
              saveChanges: _saveChanges,
              revertChanges: _revertChanges,
              onActivityDataChanged: _handleActivityDataChanged,
            );
          } else {
            return ActivityDetailSmallLandscapeLayout(
              key: ValueKey(_widgetKey), // Forzar reconstrucción al revertir
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
              editLocalImage: _editLocalImage,
              saveChanges: _saveChanges,
              revertChanges: _revertChanges,
              onActivityDataChanged: _handleActivityDataChanged,
            );
          }
        },
      );
    }
  }
}
