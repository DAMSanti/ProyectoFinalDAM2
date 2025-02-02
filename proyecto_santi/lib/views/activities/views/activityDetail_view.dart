import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/components/appBar.dart';
import 'package:proyecto_santi/components/menu.dart';
import 'dart:io';

class ActivityDetailView extends StatefulWidget {
  final int activityId;
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;

  const ActivityDetailView(
      {Key? key,
        required this.activityId,
        required this.isDarkTheme,
        required this.onToggleTheme})
      : super(key: key);

  @override
  _ActivityDetailViewState createState() => _ActivityDetailViewState();
}

class _ActivityDetailViewState extends State<ActivityDetailView> {
  late Future<Actividad?> _futureActivity;
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
    _futureActivity = _apiService.fetchActivityById(widget.activityId);
    _futurePhotos = _apiService.fetchPhotosByActivityId(widget.activityId);
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
    // Implement your save logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onToggleTheme: widget.onToggleTheme,
        title: 'Detalles de Actividad',
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
            FutureBuilder<Actividad?>(
              future: _futureActivity,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red)));
                } else if (!snapshot.hasData) {
                  return Center(child: Text("No activity details available"));
                } else {
                  final actividad = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          actividad.titulo ?? 'Sin título',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Solicitante: ${actividad.solicitante ?? 'N/A'}'),
                        SizedBox(height: 8),
                        Text('Fecha: ${actividad.fini ?? 'N/A'} a ${actividad
                            .ffin ?? 'N/A'}'),
                        SizedBox(height: 8),
                        Text('Tipo: ${actividad.tipo ?? 'N/A'}'),
                        SizedBox(height: 8),
                        Text('Estado: ${actividad.estado ?? 'N/A'}'),
                        SizedBox(height: 16),
                        Text(
                          'Fotos de la Actividad',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                                    onPressed: () {
                                      setState(() {
                                        isPopupVisible = true;
                                      });
                                    },
                                  ),
                                ),
                              ...imagesActividad.map((photo) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  height: 100.0, // Adjust the height as needed
                                  child: Image.network(
                                      photo.urlFoto ?? '', fit: BoxFit.cover),
                                );
                              }),
                              ...selectedImages.map((image) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  height: 100.0, // Adjust the height as needed
                                  child: Image.file(
                                      File(image.path), fit: BoxFit.cover),
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Descripción de la Actividad',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(actividad.descripcion ?? 'Sin descripción'),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}