import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

class ActivityDetailInfo extends StatelessWidget {
  final Actividad actividad;
  final bool isAdminOrSolicitante;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final VoidCallback showImagePicker;

  const ActivityDetailInfo({
    super.key,
    required this.actividad,
    required this.isAdminOrSolicitante,
    required this.imagesActividad,
    required this.selectedImages,
    required this.showImagePicker,
  });

  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              _buildHeader(context, constraints),
              SizedBox(height: 16),
              _buildImages(context, constraints),
              SizedBox(height: 16),
              _buildComentarios(context, constraints)
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints) {
    final isWeb =
        kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final String formattedStartDate =
        dateFormat.format(DateTime.parse(actividad.fini));
    final String formattedEndDate =
        dateFormat.format(DateTime.parse(actividad.ffin));
    final String dateText = actividad.fini == actividad.ffin
        ? formattedStartDate
        : '$formattedStartDate a $formattedEndDate';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              actividad.titulo,
              style: TextStyle(
                  fontSize: !isWeb ? 20.dg : 7.sp,
                  fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showEditDialog(context),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Descripcion: ${actividad.descripcion}',
          style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${actividad.solicitante.nombre} ${actividad.solicitante.apellidos}',
                style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
            Text(
              dateText,
              style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              toBeginningOfSentenceCase('${actividad.tipo}') ?? '',
              style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
            ),
            Text(
              '${actividad.estado}',
              style: TextStyle(
                  fontSize: !isWeb ? 13.dg : 4.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Actividad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Título'),
                controller: TextEditingController(text: actividad.titulo),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Descripción'),
                controller: TextEditingController(text: actividad.descripcion),
              ),
              // Add more fields as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Save changes logic here
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImages(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotos de la Actividad',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 200.0, // Adjust the height as needed
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (isAdminOrSolicitante)
                SizedBox(
                  height: 100.0, // Adjust the height as needed
                  child: IconButton(
                    icon: Icon(Icons.add_a_photo),
                    onPressed: showImagePicker,
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
      ],
    );
  }

  Widget _buildComentarios(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción de la Actividad',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(actividad.comentarios ?? 'Sin comentarios'),
      ],
    );
  }
}
