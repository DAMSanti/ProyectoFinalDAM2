import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/services/services.dart';
class ActivityDetailState {
  late final ApiService apiService;
  late final ActividadService actividadService;
  late final ProfesorService profesorService;
  late final CatalogoService catalogoService;
  late final PhotoService photoService;
  late final LocalizacionService localizacionService;
  Actividad? actividadCompleta;
  Actividad? actividadOriginal;
  Map<String, dynamic>? datosEditados;
  bool isLoadingActivity = true;
  List<Photo> imagesActividad = [];
  List<XFile> selectedImages = [];
  List<int> imagesToDelete = [];
  bool isDataChanged = false;
  bool isAdminOrSolicitante = true;
  bool isDialogVisible = false;
  bool isPopupVisible = false;
  bool isCameraVisible = false;
  ActivityDetailState() {
    apiService = ApiService();
    actividadService = ActividadService(apiService);
    profesorService = ProfesorService(apiService);
    catalogoService = CatalogoService(apiService);
    photoService = PhotoService(apiService);
    localizacionService = LocalizacionService(apiService);
  }
  void markAsChanged() {
    isDataChanged = true;
  }
  void clearChanges() {
    isDataChanged = false;
    selectedImages.clear();
    imagesToDelete.clear();
    datosEditados = null;
  }
  void updateEditedData(Map<String, dynamic> data) {
    datosEditados = {...?datosEditados, ...data};
  }
}