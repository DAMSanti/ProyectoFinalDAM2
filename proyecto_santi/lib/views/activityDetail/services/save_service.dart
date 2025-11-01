import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/empresa_transporte.dart';
import 'package:proyecto_santi/models/alojamiento.dart';
import 'package:proyecto_santi/models/gasto_personalizado.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/services/gasto_personalizado_service.dart';

/// Servicio que maneja la lógica de guardado de cambios en ActivityDetail
class SaveHandler {
  final ActividadService actividadService;
  final ProfesorService profesorService;
  final CatalogoService catalogoService;
  final PhotoService photoService;
  final LocalizacionService localizacionService;
  final GastoPersonalizadoService gastoService;

  SaveHandler({
    required this.actividadService,
    required this.profesorService,
    required this.catalogoService,
    required this.photoService,
    required this.localizacionService,
    required this.gastoService,
  });

  /// Guarda los cambios realizados en la actividad
  Future<SaveResult> saveChanges({
    required Actividad actividadOriginal,
    required int actividadId,
    Map<String, dynamic>? datosEditados,
    required List<XFile> selectedImages,
    required Map<String, String> selectedImagesDescriptions,
    required List<int> imagesToDelete,
  }) async {
    bool success = true;
    Actividad? actividadActualizada;

    // 1. Guardar cambios en los datos de la actividad
    final hasActivityChanges = datosEditados != null &&
        datosEditados.keys.any((key) =>
            key != 'profesoresParticipantes' && key != 'gruposParticipantes');

    if (hasActivityChanges) {
      final result = await _saveActivityChanges(
        actividadOriginal: actividadOriginal,
        actividadId: actividadId,
        datosEditados: datosEditados!,
      );
      success = result.success;
      actividadActualizada = result.actividad;
    }

    // 2. Eliminar imágenes marcadas
    if (imagesToDelete.isNotEmpty) {
      success = success && await _deleteMarkedImages(imagesToDelete);
    }

    // 3. Subir imágenes nuevas
    if (selectedImages.isNotEmpty) {
      success = success &&
          await _uploadNewImages(
            actividadId: actividadId,
            selectedImages: selectedImages,
            descriptions: selectedImagesDescriptions,
          );
    }

    // 4. Guardar profesores participantes
    if (datosEditados != null && datosEditados.containsKey('profesoresParticipantes')) {
      success = success &&
          await _saveProfesoresParticipantes(
            actividadId: actividadId,
            profesoresParticipantes: datosEditados['profesoresParticipantes'],
          );
    }

    // 5. Guardar grupos participantes
    if (datosEditados != null && datosEditados.containsKey('gruposParticipantes')) {
      success = success &&
          await _saveGruposParticipantes(
            actividadId: actividadId,
            gruposParticipantes: datosEditados['gruposParticipantes'],
          );
    }

    // 6. Manejar folleto
    if (datosEditados != null) {
      if (datosEditados['deleteFolleto'] == true) {
        success = success && await _deleteFolleto(actividadId);
      } else if (datosEditados.containsKey('folletoBytes')) {
        // Caso Web: Los bytes vienen directamente del FilePicker
        var folletoBytes = datosEditados['folletoBytes'];
        if (folletoBytes is Uint8List) {
          folletoBytes = folletoBytes.toList();
        }
        success = success &&
            await _uploadFolleto(
              actividadId: actividadId,
              folletoBytes: folletoBytes,
              folletoFileName: datosEditados['folletoFileName'],
            );
      } else if (datosEditados.containsKey('folletoFilePath')) {
        // Caso Desktop: Leer el archivo desde el path
        try {
          final file = File(datosEditados['folletoFilePath']);
          final bytes = await file.readAsBytes();
          success = success &&
              await _uploadFolleto(
                actividadId: actividadId,
                folletoBytes: bytes.toList(),
                folletoFileName: datosEditados['folletoFileName'],
              );
        } catch (e) {
          print('❌ Error leyendo archivo folleto: $e');
          success = false;
        }
      }
    }

    // 7. Guardar gastos personalizados
    if (datosEditados != null && datosEditados.containsKey('gastosPersonalizados')) {
      success = success &&
          await _saveGastosPersonalizados(
            actividadId: actividadId,
            gastos: datosEditados['gastosPersonalizados'],
          );
    }

    // 8. Guardar localizaciones
    if (datosEditados != null && datosEditados.containsKey('localizaciones')) {
      success = success &&
          await _saveLocalizaciones(
            actividadId: actividadId,
            localizaciones: datosEditados['localizaciones'],
          );
    }

    // 9. Guardar descripciones de fotos
    if (datosEditados != null && datosEditados.containsKey('photoDescriptionChanges')) {
      success = success &&
          await _savePhotoDescriptions(
            photoChanges: datosEditados['photoDescriptionChanges'],
          );
    }

    return SaveResult(
      success: success,
      actividad: actividadActualizada ?? actividadOriginal,
    );
  }

  Future<ActivitySaveResult> _saveActivityChanges({
    required Actividad actividadOriginal,
    required int actividadId,
    required Map<String, dynamic> datosEditados,
  }) async {
    try {
      // Calcular coste real
      final transporteReq = (datosEditados['transporteReq'] ?? actividadOriginal.transporteReq) ?? 0;
      final alojamientoReq = (datosEditados['alojamientoReq'] ?? actividadOriginal.alojamientoReq) ?? 0;
      final precioTransporte = (datosEditados['precioTransporte'] ?? actividadOriginal.precioTransporte) ?? 0.0;
      final precioAlojamiento = (datosEditados['precioAlojamiento'] ?? actividadOriginal.precioAlojamiento) ?? 0.0;

      // Obtener gastos personalizados
      List<GastoPersonalizado> gastosPersonalizados = [];
      if (datosEditados.containsKey('gastosPersonalizados')) {
        gastosPersonalizados = datosEditados['gastosPersonalizados'] as List<GastoPersonalizado>;
      } else {
        try {
          gastosPersonalizados = await gastoService.fetchGastosByActividad(actividadId);
        } catch (e) {
          // Error silencioso
        }
      }

      final totalGastosPersonalizados = gastosPersonalizados.fold<double>(
        0.0,
        (sum, gasto) => sum + (gasto.cantidad ?? 0.0),
      );

      double costoRealCalculado = totalGastosPersonalizados;
      if (transporteReq == 1) costoRealCalculado += precioTransporte;
      if (alojamientoReq == 1) costoRealCalculado += precioAlojamiento;

      // Preparar profesor responsable si ha cambiado
      Profesor? responsableParaGuardar = actividadOriginal.responsable;
      if (datosEditados.containsKey('profesorId') && datosEditados['profesorId'] != null) {
        // Crear un objeto Profesor temporal solo con el UUID para el guardado
        responsableParaGuardar = Profesor(
          uuid: datosEditados['profesorId'],
          dni: '',
          nombre: '', // Se actualizará después con los datos completos
          apellidos: '',
          correo: '',
          password: '',
          rol: 'Profesor',
          activo: 1,
          esJefeDep: 0,
        );
        print('DEBUG: Preparando guardado con nuevo responsable UUID: ${datosEditados['profesorId']}');
      }

      // Crear actividad para guardar
      final actividadParaGuardar = Actividad(
        id: actividadOriginal.id,
        titulo: datosEditados['nombre'] ?? actividadOriginal.titulo,
        tipo: datosEditados['tipoActividad'] ?? actividadOriginal.tipo,
        descripcion: datosEditados['descripcion'] ?? actividadOriginal.descripcion,
        fini: datosEditados['fechaInicio'] ?? actividadOriginal.fini,
        ffin: datosEditados['fechaFin'] ?? actividadOriginal.ffin,
        hini: datosEditados['hini'] ?? actividadOriginal.hini,
        hfin: datosEditados['hfin'] ?? actividadOriginal.hfin,
        previstaIni: actividadOriginal.previstaIni,
        transporteReq: datosEditados['transporteReq'] ?? actividadOriginal.transporteReq,
        comentTransporte: actividadOriginal.comentTransporte,
        alojamientoReq: datosEditados['alojamientoReq'] ?? actividadOriginal.alojamientoReq,
        solicitante: actividadOriginal.solicitante,
        estado: datosEditados['estado'] ?? actividadOriginal.estado,
        empresaTransporte: actividadOriginal.empresaTransporte,
        alojamiento: actividadOriginal.alojamiento,
        precioTransporte: datosEditados['precioTransporte'] ?? actividadOriginal.precioTransporte,
        precioAlojamiento: datosEditados['precioAlojamiento'] ?? actividadOriginal.precioAlojamiento,
        urlFolleto: actividadOriginal.urlFolleto,
        responsable: responsableParaGuardar,
        localizacion: actividadOriginal.localizacion,
        importePorAlumno: actividadOriginal.importePorAlumno,
        presupuestoEstimado: datosEditados['presupuestoEstimado'] ?? actividadOriginal.presupuestoEstimado,
        costoReal: costoRealCalculado,
      );

      final actividadActualizada = await actividadService.updateActivity(actividadId, actividadParaGuardar);

      if (actividadActualizada != null) {
        // Cargar datos completos de relaciones
        Profesor? profesorCompleto = actividadActualizada.responsable;
        if (datosEditados.containsKey('profesorId') && datosEditados['profesorId'] != null) {
          try {
            profesorCompleto = await profesorService.getProfesorByUuid(datosEditados['profesorId']);
          } catch (e) {
            // Error silencioso
          }
        }

        EmpresaTransporte? empresaCompletaTransporte = actividadActualizada.empresaTransporte;
        // No hay método para obtener empresa de transporte por ID, usar la que viene en actividadActualizada

        Alojamiento? alojamientoCompleto = actividadActualizada.alojamiento;
        // No hay método para obtener alojamiento por ID, usar el que viene en actividadActualizada

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
          solicitante: actividadActualizada.solicitante,
          estado: actividadActualizada.estado,
          empresaTransporte: empresaCompletaTransporte,
          alojamiento: alojamientoCompleto,
          precioTransporte: actividadActualizada.precioTransporte,
          precioAlojamiento: actividadActualizada.precioAlojamiento,
          urlFolleto: actividadActualizada.urlFolleto,
          responsable: profesorCompleto,
          localizacion: actividadActualizada.localizacion,
          importePorAlumno: actividadActualizada.importePorAlumno,
          presupuestoEstimado: actividadActualizada.presupuestoEstimado,
          costoReal: actividadActualizada.costoReal,
        );

        return ActivitySaveResult(success: true, actividad: actividadCompletaConObjetos);
      }

      return ActivitySaveResult(success: false, actividad: null);
    } catch (e) {
      return ActivitySaveResult(success: false, actividad: null);
    }
  }

  Future<bool> _deleteMarkedImages(List<int> imagesToDelete) async {
    for (int photoId in imagesToDelete) {
      try {
        await photoService.deletePhoto(photoId);
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _uploadNewImages({
    required int actividadId,
    required List<XFile> selectedImages,
    required Map<String, String> descriptions,
  }) async {
    try {
      // Subir imágenes una por una
      for (final imageFile in selectedImages) {
        final bytes = await imageFile.readAsBytes();
        final description = descriptions[imageFile.path] ?? '';
        
        await photoService.uploadPhotosFromBytes(
          activityId: actividadId,
          bytes: bytes,
          filename: imageFile.name,
          descripcion: description,
        );
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _saveProfesoresParticipantes({
    required int actividadId,
    required List<dynamic> profesoresParticipantes,
  }) async {
    try {
      final profesoresIds = profesoresParticipantes.map((p) {
        if (p is Map<String, dynamic>) {
          return p['uuid'] as String;
        } else {
          // Asumimos que es un objeto Profesor
          return (p as dynamic).uuid as String;
        }
      }).toList();

      print('DEBUG: Guardando profesores participantes - IDs: $profesoresIds'); // DEBUG
      await profesorService.updateProfesoresParticipantes(actividadId, profesoresIds);
      print('DEBUG: Profesores participantes guardados exitosamente'); // DEBUG
      return true;
    } catch (e, stackTrace) {
      print('ERROR al guardar profesores participantes: $e'); // DEBUG
      print('StackTrace: $stackTrace'); // DEBUG
      return false;
    }
  }

  Future<bool> _saveGruposParticipantes({
    required int actividadId,
    required List<dynamic> gruposParticipantes,
  }) async {
    try {
      final gruposMapped = gruposParticipantes.map((g) {
        if (g is Map<String, dynamic>) {
          return {
            'id': g['id'] as int,
            'numeroAlumnos': g['numeroAlumnos'] ?? 0,
          };
        } else {
          return {
            'id': (g as dynamic).id as int,
            'numeroAlumnos': (g as dynamic).numeroAlumnos ?? 0,
          };
        }
      }).toList();

      await catalogoService.updateGruposParticipantes(actividadId, gruposMapped);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteFolleto(int actividadId) async {
    try {
      await actividadService.deleteFolleto(actividadId);
      return true;
    } catch (e) {
      print('❌ Error al eliminar folleto: $e');
      return false;
    }
  }

  Future<bool> _uploadFolleto({
    required int actividadId,
    required List<int> folletoBytes,
    required String folletoFileName,
  }) async {
    try {
      await actividadService.uploadFolleto(
        actividadId,
        fileBytes: Uint8List.fromList(folletoBytes),
        fileName: folletoFileName,
      );
      return true;
    } catch (e) {
      print('❌ Error al subir folleto: $e');
      return false;
    }
  }

  Future<bool> _saveGastosPersonalizados({
    required int actividadId,
    required List<GastoPersonalizado> gastos,
  }) async {
    try {
      final gastosOriginales = await gastoService.fetchGastosByActividad(actividadId);
      final gastosOriginalesIds = gastosOriginales.map((g) => g.id).toSet();
      final gastosNuevosIds = gastos.where((g) => g.id != null).map((g) => g.id!).toSet();

      // Eliminar gastos
      final gastosAEliminar = gastosOriginalesIds.difference(gastosNuevosIds);
      for (final gastoId in gastosAEliminar) {
        if (gastoId != null) {
          await gastoService.deleteGasto(gastoId);
        }
      }

      // Crear gastos nuevos
      final gastosACrear = gastos.where((g) => g.id == null).toList();
      for (final gasto in gastosACrear) {
        await gastoService.createGasto(gasto);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _saveLocalizaciones({
    required int actividadId,
    required List<dynamic> localizaciones,
  }) async {
    try {
      // Las localizaciones se gestionan individualmente mediante add/remove/update
      // No hay endpoint batch, así que retornamos true
      // El sistema actual ya maneja las localizaciones correctamente
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _savePhotoDescriptions({
    required Map<int, String> photoChanges,
  }) async {
    try {
      for (final entry in photoChanges.entries) {
        final photoId = entry.key;
        final newDescription = entry.value;
        await photoService.updatePhotoDescription(photoId, newDescription);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Resultado de la operación de guardado
class SaveResult {
  final bool success;
  final Actividad actividad;

  SaveResult({
    required this.success,
    required this.actividad,
  });
}

/// Resultado de guardado de actividad
class ActivitySaveResult {
  final bool success;
  final Actividad? actividad;

  ActivitySaveResult({
    required this.success,
    required this.actividad,
  });
}
