import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/components/appBar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'dart:io';

class ActivityDetailView extends StatefulWidget {
  final Actividad actividad;
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;

  const ActivityDetailView({
    Key? key,
    required this.actividad,
    required this.isDarkTheme,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  _ActivityDetailViewState createState() => _ActivityDetailViewState();
}

class _ActivityDetailViewState extends State<ActivityDetailView> {
  late Future<List<Photo>> _futurePhotos;
  final ApiService _apiService = ApiService();
  bool isDataChanged = false;
  bool isAdminOrSolicitante = true;
  List<Photo> imagesActividad = [];
  List<XFile> selectedImages = [];
  bool isDialogVisible = false;
  bool isPopupVisible = false;
  bool isCameraVisible = false;

  @override
  void initState() {
    super.initState();
    _futurePhotos = _apiService.fetchPhotosByActivityId(widget.actividad.id);
    _futurePhotos.then((photos) {
      setState(() {
        imagesActividad = photos;
      });
    });
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

  void _saveChanges() {
    // Save changes logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onToggleTheme: widget.onToggleTheme,
        title: 'Activity Details',
      ),
      drawer: Menu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (ModalRoute.of(context)?.settings.name != '/')
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ElevatedButton(
                  onPressed: isDataChanged ? _saveChanges : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  child: Text('Guardar'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.actividad.titulo ?? 'Sin título',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Solicitante: ${widget.actividad.solicitante ?? 'N/A'}'),
                  SizedBox(height: 8),
                  Text('Fecha: ${widget.actividad.fini ?? 'N/A'} a ${widget.actividad.ffin ?? 'N/A'}'),
                  SizedBox(height: 8),
                  Text('Tipo: ${widget.actividad.tipo ?? 'N/A'}'),
                  SizedBox(height: 8),
                  Text('Estado: ${widget.actividad.estado ?? 'N/A'}'),
                  SizedBox(height: 16),
                  Text(
                    'Fotos de la Actividad',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 250.0, // Adjust the height as needed
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (isAdminOrSolicitante)
                          Container(
                            height: 100.0, // Adjust the height as needed
                            child: IconButton(
                              icon: Icon(Icons.add_a_photo),
                              onPressed: _showImagePicker,
                            ),
                          ),
                        ...imagesActividad.map((photo) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            height: 100.0, // Adjust the height as needed
                            child: Image.network(photo.urlFoto ?? '', fit: BoxFit.cover),
                          );
                        }),
                        ...selectedImages.map((image) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            height: 100.0, // Adjust the height as needed
                            child: Image.file(File(image.path), fit: BoxFit.cover),
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
                  Text(widget.actividad.descripcion ?? 'Sin descripción'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}