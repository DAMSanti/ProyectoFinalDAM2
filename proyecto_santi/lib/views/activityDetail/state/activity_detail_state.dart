import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/services/services.dart';

/// Clase que gestiona el estado de la vista de detalle de actividad
class ActivityDetailState {
  // Servicios
  late final ApiService apiService;
  late final ActividadService actividadService;
  late final ProfesorService profesorService;
  late final CatalogoService catalogoService;
  late final PhotoService photoService;
  late final LocalizacionService localizacionService;

  // Estado de la actividad
  Actividad? actividadCompleta;
  Actividad? actividadOriginal;
  Map<String, dynamic>? datosEditados;
  bool isLoadingActivity = true;

  // Estado de imágenes
  List<Photo> imagesActividad = [];
  List<XFile> selectedImages = [];
  List<int> imagesToDelete = [];

  // Estado de UI
  bool isDataChanged = false;
  bool isAdminOrSolicitante = true;
  bool isDialogVisible = false;
  bool isPopupVisible = false;
  bool isCameraVisible = false;

  /// Constructor que inicializa los servicios
  ActivityDetailState() {
    apiService = ApiService();
    actividadService = ActividadService(apiService);
    profesorService = ProfesorService(apiService);
    catalogoService = CatalogoService(apiService);
    photoService = PhotoService(apiService);
    localizacionService = LocalizacionService(apiService);
  }

  /// Marca que hay cambios pendientes
  void markAsChanged() {
    isDataChanged = true;
  }

  /// Limpia el estado de cambios
  void clearChanges() {
    isDataChanged = false;
    selectedImages.clear();
    imagesToDelete.clear();
    datosEditados = null;
  }

  /// Actualiza los datos editados
  void updateEditedData(Map<String, dynamic> data) {
    datosEditados = {...?datosEditados, ...data};
  }
}
