import 'package:image_picker/image_picker.dart';
import '../../../models/actividad.dart';
class ChangeDetectionHelper {
  static bool hasRealChanges({
    required List<XFile> selectedImages,
    required List<int> imagesToDelete,
    Map<String, dynamic>? datosEditados,
    Actividad? actividadOriginal,
  }) {
    if (selectedImages.isNotEmpty || imagesToDelete.isNotEmpty) {
      return true;
    }
    if (datosEditados != null) {
      if (datosEditados.containsKey('profesoresParticipantes') ||
          datosEditados.containsKey('gruposParticipantes')) {
        return true;
      }
    }
    if (datosEditados != null) {
      if (datosEditados.containsKey('gastosPersonalizados') ||
          datosEditados.containsKey('budgetChanged')) {
        return true;
      }
    }
    if (datosEditados != null) {
      if (datosEditados.containsKey('localizaciones') ||
          datosEditados.containsKey('localizaciones_changed')) {
        return true;
      }
    }
    if (datosEditados != null) {
      if (datosEditados.containsKey('folletoFileName') ||
          datosEditados.containsKey('folletoBytes') ||
          datosEditados.containsKey('folletoFilePath') ||
          datosEditados.containsKey('deleteFolleto')) {
        return true;
      }
    }
    if (datosEditados == null || actividadOriginal == null) {
      return false;
    }
    return _hasFieldChanges(datosEditados, actividadOriginal);
  }
  static bool _hasFieldChanges(
    Map<String, dynamic> datosEditados,
    Actividad actividadOriginal,
  ) {
    if (_hasNombreChanged(datosEditados, actividadOriginal)) return true;
    if (_hasDescripcionChanged(datosEditados, actividadOriginal)) return true;
    if (_hasFechaInicioChanged(datosEditados, actividadOriginal)) return true;
    if (_hasFechaFinChanged(datosEditados, actividadOriginal)) return true;
    if (_hasHoraInicioChanged(datosEditados, actividadOriginal)) return true;
    if (_hasHoraFinChanged(datosEditados, actividadOriginal)) return true;
    if (_hasAprobadaChanged(datosEditados, actividadOriginal)) return true;
    if (_hasEstadoChanged(datosEditados, actividadOriginal)) return true;
    if (_hasTipoActividadChanged(datosEditados, actividadOriginal)) return true;
    if (_hasProfesorChanged(datosEditados, actividadOriginal)) return true;
    if (_hasTransporteReqChanged(datosEditados, actividadOriginal)) return true;
    if (_hasAlojamientoReqChanged(datosEditados, actividadOriginal)) return true;
    if (_hasPresupuestoEstimadoChanged(datosEditados, actividadOriginal)) return true;
    if (_hasPrecioTransporteChanged(datosEditados, actividadOriginal)) return true;
    if (_hasEmpresaTransporteChanged(datosEditados, actividadOriginal)) return true;
    if (_hasAlojamientoChanged(datosEditados, actividadOriginal)) return true;
    if (_hasPrecioAlojamientoChanged(datosEditados, actividadOriginal)) return true;
    return false;
  }
  static bool _hasNombreChanged(Map<String, dynamic> datos, Actividad original) {
    final nombre = datos['nombre'] as String?;
    if (nombre != null) {
      final nombreTrimmed = nombre.trim();
      final originalTrimmed = original.titulo.trim();
      if (nombreTrimmed != originalTrimmed) return true;
    }
    return false;
  }
  static bool _hasDescripcionChanged(Map<String, dynamic> datos, Actividad original) {
    final descripcion = datos['descripcion'] as String?;
    if (descripcion != null) {
      final descripcionTrimmed = descripcion.trim();
      final originalDescripcionTrimmed = (original.descripcion?.trim() ?? '');
      if (descripcionTrimmed != originalDescripcionTrimmed) return true;
    }
    return false;
  }
  static bool _hasFechaInicioChanged(Map<String, dynamic> datos, Actividad original) {
    final fechaInicio = datos['fechaInicio'] as String?;
    if (fechaInicio != null) {
      try {
        final fechaEditada = DateTime.parse(fechaInicio);
        final fechaOriginal = DateTime.parse(original.fini);
        final editadaNormalizada = DateTime(
          fechaEditada.year,
          fechaEditada.month,
          fechaEditada.day,
          fechaEditada.hour,
          fechaEditada.minute,
          fechaEditada.second,
        );
        final originalNormalizada = DateTime(
          fechaOriginal.year,
          fechaOriginal.month,
          fechaOriginal.day,
          fechaOriginal.hour,
          fechaOriginal.minute,
          fechaOriginal.second,
        );
        if (editadaNormalizada != originalNormalizada) return true;
      } catch (e) {
        if (fechaInicio != original.fini) return true;
      }
    }
    return false;
  }
  static bool _hasFechaFinChanged(Map<String, dynamic> datos, Actividad original) {
    final fechaFin = datos['fechaFin'] as String?;
    if (fechaFin != null) {
      try {
        final fechaEditada = DateTime.parse(fechaFin);
        final fechaOriginal = DateTime.parse(original.ffin);
        final editadaNormalizada = DateTime(
          fechaEditada.year,
          fechaEditada.month,
          fechaEditada.day,
          fechaEditada.hour,
          fechaEditada.minute,
          fechaEditada.second,
        );
        final originalNormalizada = DateTime(
          fechaOriginal.year,
          fechaOriginal.month,
          fechaOriginal.day,
          fechaOriginal.hour,
          fechaOriginal.minute,
          fechaOriginal.second,
        );
        if (editadaNormalizada != originalNormalizada) return true;
      } catch (e) {
        if (fechaFin != original.ffin) return true;
      }
    }
    return false;
  }
  static bool _hasHoraInicioChanged(Map<String, dynamic> datos, Actividad original) {
    final hini = datos['hini'] as String?;
    if (hini != null) {
      String hiniNueva = hini;
      if (hiniNueva.length > 5 && hiniNueva.substring(5, 6) == ':') {
        hiniNueva = hiniNueva.substring(0, 5);
      }
      String hiniOriginal = original.hini;
      if (hiniOriginal.length > 5 && hiniOriginal.substring(5, 6) == ':') {
        hiniOriginal = hiniOriginal.substring(0, 5);
      }
      if (hiniNueva != hiniOriginal) return true;
    }
    return false;
  }
  static bool _hasHoraFinChanged(Map<String, dynamic> datos, Actividad original) {
    final hfin = datos['hfin'] as String?;
    if (hfin != null) {
      String hfinNueva = hfin;
      if (hfinNueva.length > 5 && hfinNueva.substring(5, 6) == ':') {
        hfinNueva = hfinNueva.substring(0, 5);
      }
      String hfinOriginal = original.hfin;
      if (hfinOriginal.length > 5 && hfinOriginal.substring(5, 6) == ':') {
        hfinOriginal = hfinOriginal.substring(0, 5);
      }
      if (hfinNueva != hfinOriginal) return true;
    }
    return false;
  }
  static bool _hasAprobadaChanged(Map<String, dynamic> datos, Actividad original) {
    final aprobada = datos['aprobada'] as bool?;
    if (aprobada != null) {
      final estadoOriginal = original.estado == 'Aprobada';
      if (aprobada != estadoOriginal) return true;
    }
    return false;
  }
  static bool _hasEstadoChanged(Map<String, dynamic> datos, Actividad original) {
    final estado = datos['estado'] as String?;
    if (estado != null) {
      final estadoNuevo = _normalizeEstado(estado);
      final estadoOriginal = _normalizeEstado(original.estado);
      if (estadoNuevo != estadoOriginal) return true;
    }
    return false;
  }
  static bool _hasTipoActividadChanged(Map<String, dynamic> datos, Actividad original) {
    final tipo = datos['tipoActividad'] as String?;
    if (tipo != null) {
      final tipoNuevo = _normalizeTipo(tipo);
      final tipoOriginal = _normalizeTipo(original.tipo);
      if (tipoNuevo != tipoOriginal) return true;
    }
    return false;
  }
  static bool _hasProfesorChanged(Map<String, dynamic> datos, Actividad original) {
    final profesorId = datos['profesorId'] as String?;
    if (profesorId != null) {
      final profesorOriginalId = original.responsable?.uuid;
      if (profesorId != profesorOriginalId) return true;
    }
    return false;
  }
  static String _normalizeEstado(String estado) {
    if (estado.isEmpty) return '';
    final estadoLower = estado.toLowerCase().trim();
    if (estadoLower == 'pendiente') return 'Pendiente';
    if (estadoLower == 'aprobada') return 'Aprobada';
    if (estadoLower == 'cancelada') return 'Cancelada';
    if (estado.length == 1) return estado.toUpperCase();
    return estado[0].toUpperCase() + estado.substring(1).toLowerCase();
  }
  static String _normalizeTipo(String tipo) {
    if (tipo.isEmpty) return '';
    final tipoLower = tipo.toLowerCase().trim();
    if (tipoLower == 'complementaria') return 'Complementaria';
    if (tipoLower == 'extraescolar') return 'Extraescolar';
    if (tipo.length == 1) return tipo.toUpperCase();
    return tipo[0].toUpperCase() + tipo.substring(1).toLowerCase();
  }
  static bool _hasTransporteReqChanged(Map<String, dynamic> datos, Actividad original) {
    final transporteReq = datos['transporteReq'] as int?;
    if (transporteReq != null) {
      if (transporteReq != original.transporteReq) return true;
    }
    return false;
  }
  static bool _hasAlojamientoReqChanged(Map<String, dynamic> datos, Actividad original) {
    final alojamientoReq = datos['alojamientoReq'] as int?;
    if (alojamientoReq != null) {
      if (alojamientoReq != original.alojamientoReq) return true;
    }
    return false;
  }
  static bool _hasPresupuestoEstimadoChanged(Map<String, dynamic> datos, Actividad original) {
    final presupuestoEstimado = datos['presupuestoEstimado'] as double?;
    if (presupuestoEstimado != null) {
      final presupuestoOriginal = original.presupuestoEstimado ?? 0.0;
      if ((presupuestoEstimado - presupuestoOriginal).abs() > 0.01) return true;
    }
    return false;
  }
  static bool _hasPrecioTransporteChanged(Map<String, dynamic> datos, Actividad original) {
    final precioTransporte = datos['precioTransporte'] as double?;
    if (precioTransporte != null) {
      final precioOriginal = original.precioTransporte ?? 0.0;
      if ((precioTransporte - precioOriginal).abs() > 0.01) return true;
    }
    return false;
  }
  static bool _hasEmpresaTransporteChanged(Map<String, dynamic> datos, Actividad original) {
    final empresaTransporteId = datos['empresaTransporteId'] as int?;
    if (empresaTransporteId != null) {
      final empresaOriginalId = original.empresaTransporte?.id;
      if (empresaTransporteId != empresaOriginalId) return true;
    }
    return false;
  }
  static bool _hasAlojamientoChanged(Map<String, dynamic> datos, Actividad original) {
    final alojamientoId = datos['alojamientoId'];
    if (alojamientoId != null) {
      final alojamientoOriginalId = original.alojamiento?.id;
      if (alojamientoId != alojamientoOriginalId) return true;
    }
    return false;
  }
  static bool _hasPrecioAlojamientoChanged(Map<String, dynamic> datos, Actividad original) {
    final precioAlojamiento = datos['precioAlojamiento'] as double?;
    if (precioAlojamiento != null) {
      final precioOriginal = 0.0; 
      if ((precioAlojamiento - precioOriginal).abs() > 0.01) return true;
    }
    return false;
  }
}