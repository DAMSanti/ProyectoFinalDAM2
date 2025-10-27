import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/departamento.dart';
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
  final ApiService _apiService = ApiService();
  bool isDataChanged = false;
  bool isAdminOrSolicitante = true;
  List<Photo> imagesActividad = [];
  List<XFile> selectedImages = [];
  List<int> imagesToDelete = []; // IDs de imágenes marcadas para eliminar
  bool isDialogVisible = false;
  bool isPopupVisible = false;
  bool isCameraVisible = false;
  
  // Actividad completa con todos los datos
  Actividad? _actividadCompleta;
  Actividad? _actividadOriginal; // Copia de los datos originales de la BD
  Map<String, dynamic>? _datosEditados; // Datos modificados en el diálogo
  bool _isLoadingActivity = true;

  @override
  void initState() {
    super.initState();
    _loadActivityDetails();
    _futurePhotos = _apiService.fetchPhotosByActivityId(widget.actividad.id);
    _futurePhotos.then((photos) {
      setState(() {
        imagesActividad = photos;
      });
    });
  }
  
  Future<void> _loadActivityDetails() async {
    try {
      final actividadCompleta = await _apiService.fetchActivityById(widget.actividad.id);
      setState(() {
        _actividadCompleta = actividadCompleta ?? widget.actividad;
        _actividadOriginal = actividadCompleta ?? widget.actividad; // Guardar copia original
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
      final photos = await _apiService.fetchPhotosByActivityId(widget.actividad.id);
      setState(() {
        imagesActividad = photos;
      });
    } catch (e) {
      print('[ActivityDetail] Error loading photos: $e');
    }
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

  void _removeSelectedImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
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
  
  
  bool _hasRealChanges() {
    print('[DEBUG] ========== Verificando cambios reales ==========');
    
    // Verificar si hay imágenes nuevas o marcadas para eliminar
    if (selectedImages.isNotEmpty || imagesToDelete.isNotEmpty) {
      print('[DEBUG] Hay cambios en imágenes: ${selectedImages.length} nuevas, ${imagesToDelete.length} a eliminar');
      return true;
    }
    
    // Verificar si hay cambios en los datos editados
    if (_datosEditados == null || _actividadOriginal == null) {
      print('[DEBUG] No hay datos editados o actividad original');
      return false;
    }
    
    print('[DEBUG] Datos editados: $_datosEditados');
    print('[DEBUG] Actividad original - Título: "${_actividadOriginal!.titulo}"');
    print('[DEBUG] Actividad original - Descripción: "${_actividadOriginal!.descripcion}"');
    
    // Comparar cada campo editado con el original
    // Solo consideramos que hay cambio si el valor es diferente al original
    
    final nombre = _datosEditados!['nombre'] as String?;
    if (nombre != null) {
      final nombreTrimmed = nombre.trim();
      final originalTrimmed = _actividadOriginal!.titulo.trim();
      print('[DEBUG] Comparando nombre: "$nombreTrimmed" vs "$originalTrimmed"');
      if (nombreTrimmed != originalTrimmed) {
        print('[DEBUG] ¡CAMBIO DETECTADO en nombre!');
        return true;
      }
    }
    
    final descripcion = _datosEditados!['descripcion'] as String?;
    if (descripcion != null) {
      final descripcionTrimmed = descripcion.trim();
      final originalDescripcionTrimmed = (_actividadOriginal!.descripcion?.trim() ?? '');
      print('[DEBUG] Comparando descripción: "$descripcionTrimmed" vs "$originalDescripcionTrimmed"');
      if (descripcionTrimmed != originalDescripcionTrimmed) {
        print('[DEBUG] ¡CAMBIO DETECTADO en descripción!');
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
        print('[DEBUG] Comparando fechaInicio: $editadaNormalizada vs $originalNormalizada');
        if (editadaNormalizada != originalNormalizada) {
          print('[DEBUG] ¡CAMBIO DETECTADO en fechaInicio!');
          return true;
        }
      } catch (e) {
        print('[DEBUG] Error parseando fechaInicio: $e');
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
        print('[DEBUG] Comparando fechaFin: $editadaNormalizada vs $originalNormalizada');
        if (editadaNormalizada != originalNormalizada) {
          print('[DEBUG] ¡CAMBIO DETECTADO en fechaFin!');
          return true;
        }
      } catch (e) {
        print('[DEBUG] Error parseando fechaFin: $e');
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
      
      print('[DEBUG] Comparando hini: "$hiniNueva" vs "$hiniOriginal"');
      if (hiniNueva != hiniOriginal) {
        print('[DEBUG] ¡CAMBIO DETECTADO en hini!');
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
      
      print('[DEBUG] Comparando hfin: "$hfinNueva" vs "$hfinOriginal"');
      if (hfinNueva != hfinOriginal) {
        print('[DEBUG] ¡CAMBIO DETECTADO en hfin!');
        return true;
      }
    }
    
    final aprobada = _datosEditados!['aprobada'] as bool?;
    if (aprobada != null) {
      final estadoOriginal = _actividadOriginal!.estado == 'Aprobada';
      print('[DEBUG] Comparando estado: $aprobada vs $estadoOriginal');
      if (aprobada != estadoOriginal) {
        print('[DEBUG] ¡CAMBIO DETECTADO en estado!');
        return true;
      }
    }
    
    // Comparar profesor
    final profesorId = _datosEditados!['profesorId'] as String?;
    if (profesorId != null) {
      final profesorOriginalId = _actividadOriginal!.solicitante?.uuid;
      print('[DEBUG] Comparando profesorId: "$profesorId" vs "$profesorOriginalId"');
      if (profesorId != profesorOriginalId) {
        print('[DEBUG] ¡CAMBIO DETECTADO en profesorId!');
        return true;
      }
    }
    
    // Comparar departamento
    final departamentoId = _datosEditados!['departamentoId'] as int?;
    if (departamentoId != null) {
      final departamentoOriginalId = _actividadOriginal!.departamento?.id;
      print('[DEBUG] Comparando departamentoId: "$departamentoId" vs "$departamentoOriginalId"');
      if (departamentoId != departamentoOriginalId) {
        print('[DEBUG] ¡CAMBIO DETECTADO en departamentoId!');
        return true;
      }
    }
    
    print('[DEBUG] No se detectaron cambios reales');
    return false;
  }
  
  void _revertChanges() {
    setState(() {
      // Restaurar la actividad original
      _actividadCompleta = _actividadOriginal;
      _datosEditados = null;
      
      // Limpiar imágenes seleccionadas y marcadas para eliminar
      selectedImages.clear();
      imagesToDelete.clear();
      
      // Desactivar el botón guardar
      isDataChanged = false;
    });
  }
  
  void _handleActivityDataChanged(Map<String, dynamic> updatedData) async {
    // Actualizar los datos editados (siempre con los últimos valores del diálogo)
    _datosEditados = Map<String, dynamic>.from(updatedData);
    
    // Buscar el profesor y departamento actualizados si cambiaron
    dynamic nuevoProfesor = _actividadCompleta?.solicitante;
    dynamic nuevoDepartamento = _actividadCompleta?.departamento;
    
    // Si cambió el profesor, buscar el nuevo
    if (updatedData['profesorId'] != null) {
      try {
        final profesores = await _apiService.fetchProfesores();
        final profesorEncontrado = profesores.where((p) => p.uuid == updatedData['profesorId']).toList();
        if (profesorEncontrado.isNotEmpty) {
          nuevoProfesor = profesorEncontrado.first;
        }
      } catch (e) {
        print('[Error] Buscando profesor: $e');
      }
    }
    
    // Si cambió el departamento, buscar el nuevo
    if (updatedData['departamentoId'] != null) {
      try {
        final departamentos = await _apiService.fetchDepartamentos();
        final departamentoEncontrado = departamentos.where((d) => d.id == updatedData['departamentoId']).toList();
        if (departamentoEncontrado.isNotEmpty) {
          nuevoDepartamento = departamentoEncontrado.first;
        }
      } catch (e) {
        print('[Error] Buscando departamento: $e');
      }
    }
    
    setState(() {
      // Actualizar la actividad completa con los nuevos datos
      if (_actividadCompleta != null) {
        // Crear una nueva instancia de Actividad con los datos actualizados
        _actividadCompleta = Actividad(
          id: _actividadCompleta!.id,
          titulo: updatedData['nombre'] ?? _actividadCompleta!.titulo,
          tipo: _actividadCompleta!.tipo,
          descripcion: updatedData['descripcion'] ?? _actividadCompleta!.descripcion,
          fini: updatedData['fechaInicio'] ?? _actividadCompleta!.fini,
          ffin: updatedData['fechaFin'] ?? _actividadCompleta!.ffin,
          hini: updatedData['hini'] ?? _actividadCompleta!.hini,
          hfin: updatedData['hfin'] ?? _actividadCompleta!.hfin,
          previstaIni: _actividadCompleta!.previstaIni,
          transporteReq: _actividadCompleta!.transporteReq,
          comentTransporte: _actividadCompleta!.comentTransporte,
          alojamientoReq: _actividadCompleta!.alojamientoReq,
          comentAlojamiento: _actividadCompleta!.comentAlojamiento,
          comentarios: _actividadCompleta!.comentarios,
          estado: updatedData['aprobada'] == true ? 'Aprobada' : 'Pendiente',
          comentEstado: _actividadCompleta!.comentEstado,
          incidencias: _actividadCompleta!.incidencias,
          urlFolleto: _actividadCompleta!.urlFolleto,
          solicitante: nuevoProfesor,
          departamento: nuevoDepartamento,
          importePorAlumno: _actividadCompleta!.importePorAlumno,
          latitud: _actividadCompleta!.latitud,
          longitud: _actividadCompleta!.longitud,
        );
      }
      
      // Verificar si hay cambios reales comparando con el original
      // Esto se ejecuta cada vez que se edita, así que siempre compara con los últimos valores
      isDataChanged = _hasRealChanges();
      
      print('[DEBUG] Datos actualizados: $updatedData');
      print('[DEBUG] ¿Hay cambios reales?: $isDataChanged');
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
      if (_datosEditados != null) {
        try {
          // Crear un objeto Actividad completo con los datos actualizados
          final actividadParaGuardar = Actividad(
            id: _actividadOriginal!.id,
            titulo: _datosEditados!['nombre'] ?? _actividadOriginal!.titulo,
            tipo: _actividadOriginal!.tipo,
            descripcion: _datosEditados!['descripcion'] ?? _actividadOriginal!.descripcion,
            fini: _datosEditados!['fechaInicio'] ?? _actividadOriginal!.fini,
            ffin: _datosEditados!['fechaFin'] ?? _actividadOriginal!.ffin,
            hini: _datosEditados!['hini'] ?? _actividadOriginal!.hini,
            hfin: _datosEditados!['hfin'] ?? _actividadOriginal!.hfin,
            previstaIni: _actividadOriginal!.previstaIni,
            transporteReq: _actividadOriginal!.transporteReq,
            comentTransporte: _actividadOriginal!.comentTransporte,
            alojamientoReq: _actividadOriginal!.alojamientoReq,
            comentAlojamiento: _actividadOriginal!.comentAlojamiento,
            comentarios: _actividadOriginal!.comentarios,
            estado: _datosEditados!['aprobada'] == true ? 'Aprobada' : 'Pendiente',
            comentEstado: _actividadOriginal!.comentEstado,
            incidencias: _actividadOriginal!.incidencias,
            urlFolleto: _actividadOriginal!.urlFolleto,
            solicitante: _actividadCompleta?.solicitante,
            departamento: _actividadCompleta?.departamento,
            importePorAlumno: _actividadOriginal!.importePorAlumno,
            latitud: _actividadOriginal!.latitud,
            longitud: _actividadOriginal!.longitud,
          );
          
          print('[DEBUG] Guardando actividad completa');
          
          // Usar updateActivity en lugar de updateActivityFields
          final actividadActualizada = await _apiService.updateActivity(
            widget.actividad.id,
            actividadParaGuardar,
          );
          
          if (actividadActualizada != null) {
            // La respuesta del API puede no incluir los objetos completos de Profesor y Departamento
            // Si se cambió el profesor o departamento, cargar los datos completos
            Profesor? profesorCompleto = actividadActualizada.solicitante;
            Departamento? departamentoCompleto = actividadActualizada.departamento;
            
            // Si tenemos un UUID de profesor pero no el objeto completo, cargarlo
            if (_datosEditados!.containsKey('profesorId') && _datosEditados!['profesorId'] != null) {
              try {
                final profesores = await _apiService.fetchProfesores();
                profesorCompleto = profesores.firstWhere(
                  (p) => p.uuid == _datosEditados!['profesorId'],
                  orElse: () => actividadActualizada.solicitante ?? _actividadOriginal!.solicitante!,
                );
                print('[DEBUG] Profesor completo cargado: ${profesorCompleto.nombre}');
              } catch (e) {
                print('[ERROR] Error cargando profesor completo: $e');
                profesorCompleto = actividadActualizada.solicitante;
              }
            }
            
            // Si tenemos un ID de departamento pero no el objeto completo, cargarlo
            if (_datosEditados!.containsKey('departamentoId') && _datosEditados!['departamentoId'] != null) {
              try {
                final departamentos = await _apiService.fetchDepartamentos();
                departamentoCompleto = departamentos.firstWhere(
                  (d) => d.id == _datosEditados!['departamentoId'],
                  orElse: () => actividadActualizada.departamento ?? _actividadOriginal!.departamento!,
                );
                print('[DEBUG] Departamento completo cargado: ${departamentoCompleto.nombre}');
              } catch (e) {
                print('[ERROR] Error cargando departamento completo: $e');
                departamentoCompleto = actividadActualizada.departamento;
              }
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
              alojamientoReq: actividadActualizada.alojamientoReq,
              comentAlojamiento: actividadActualizada.comentAlojamiento,
              comentarios: actividadActualizada.comentarios,
              estado: actividadActualizada.estado,
              comentEstado: actividadActualizada.comentEstado,
              incidencias: actividadActualizada.incidencias,
              urlFolleto: actividadActualizada.urlFolleto,
              solicitante: profesorCompleto,
              departamento: departamentoCompleto,
              importePorAlumno: actividadActualizada.importePorAlumno,
              latitud: actividadActualizada.latitud,
              longitud: actividadActualizada.longitud,
            );
            
            // Actualizar la actividad original con los nuevos datos completos
            _actividadOriginal = actividadCompletaConObjetos;
            _actividadCompleta = actividadCompletaConObjetos;
            _datosEditados = null;
            print('[DEBUG] Actividad actualizada correctamente en BD con objetos completos');
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
            await _apiService.deletePhoto(photoId);
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

      // Cerrar diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        // Recargar las fotos de la actividad
        final photos = await _apiService.fetchPhotosByActivityId(widget.actividad.id);
        if (mounted) {
          setState(() {
            imagesActividad = photos;
            selectedImages.clear();
            imagesToDelete.clear();
            isDataChanged = false;
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

        // Subir la imagen usando el método del ApiService
        bool success = await _apiService.uploadPhotosFromBytes(
          activityId: widget.actividad.id,
          bytes: bytes,
          filename: fileName,
          descripcion: '',
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
        showImagePicker: _showImagePicker,
        removeSelectedImage: _removeSelectedImage,
        removeApiImage: _removeApiImage,
        saveChanges: _saveChanges,
        revertChanges: _revertChanges,
        onActivityDataChanged: _handleActivityDataChanged,
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
              showImagePicker: _showImagePicker,
              removeSelectedImage: _removeSelectedImage,
              saveChanges: _saveChanges,
              revertChanges: _revertChanges,
              onActivityDataChanged: _handleActivityDataChanged,
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
              showImagePicker: _showImagePicker,
              removeSelectedImage: _removeSelectedImage,
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