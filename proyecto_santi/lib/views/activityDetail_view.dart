import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/photo.dart';

class ActivityDetailView extends StatefulWidget {
  final int activityId;
  final bool isDarkTheme;

  const ActivityDetailView(
      {super.key, required this.activityId, required this.isDarkTheme});

  @override
  _ActivityDetailViewState createState() => _ActivityDetailViewState();
}

class _ActivityDetailViewState extends State<ActivityDetailView> {
  bool isDataChanged = false;
  bool isAdminOrSolicitante = false;
  List<Photo> imagesActividad = [];
  List<XFile> selectedImages = [];
  bool isDialogVisible = false;
  bool isPopupVisible = false;
  bool isCameraVisible = false;

  @override
  void initState() {
    super.initState();
    // Fetch activity details and initialize state variables
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

  void _showCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        selectedImages.add(image);
        isDataChanged = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Actividad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Título de la Actividad',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Solicitante: Nombre del Solicitante'),
            SizedBox(height: 8),
            Text('Fecha: 2023-01-01 a 2023-01-02'),
            SizedBox(height: 8),
            Text('Tipo: Tipo de Actividad'),
            SizedBox(height: 8),
            Text('Estado: Estado de la Actividad'),
            SizedBox(height: 16),
            Text(
              'Fotos de la Actividad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (isAdminOrSolicitante)
                    IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: () {
                        setState(() {
                          isPopupVisible = true;
                        });
                      },
                    ),
                  ...imagesActividad.map((photo) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      //child: Image.network(photo.urlFoto),
                    );
                  }),
                  ...selectedImages.map((image) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      //child: Image.file(File(image.path)),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Descripción de la Actividad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Descripción detallada de la actividad...'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isDataChanged ? () {} : null,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

void showImagePickerDialog(BuildContext context, VoidCallback onSelectGallery,
    VoidCallback onSelectCamera) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Seleccionar foto"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onSelectGallery,
              child: Text("Subir foto desde la galería"),
            ),
            TextButton(
              onPressed: onSelectCamera,
              child: Text("Tomar foto"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancelar"),
          ),
        ],
      );
    },
  );
}
