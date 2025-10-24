import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/views/activityDetail/components/edit_activity_dialog.dart';
import 'dart:io';

class ActivityDetailInfo extends StatelessWidget {
  final Actividad actividad;
  final bool isAdminOrSolicitante;
  final List<Photo> imagesActividad;
  final List<XFile> selectedImages;
  final VoidCallback showImagePicker;
  final Function(Map<String, dynamic>) onActivityUpdate;

  const ActivityDetailInfo({
    super.key,
    required this.actividad,
    required this.isAdminOrSolicitante,
    required this.imagesActividad,
    required this.selectedImages,
    required this.showImagePicker,
    required this.onActivityUpdate,
  });

  @override
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
    
    // Parsear fechas correctamente
    final DateTime fechaInicio = DateTime.parse(actividad.fini);
    final DateTime fechaFin = DateTime.parse(actividad.ffin);
    
    // Formatear fechas
    final String formattedStartDate = dateFormat.format(fechaInicio);
    final String formattedEndDate = dateFormat.format(fechaFin);
    
    // Comparar solo día, mes y año (ignorar hora)
    final bool mismoDia = fechaInicio.year == fechaFin.year &&
        fechaInicio.month == fechaFin.month &&
        fechaInicio.day == fechaFin.day;
    
    // Texto de fecha según si es el mismo día o no
    final String dateText = mismoDia
        ? formattedStartDate
        : '$formattedStartDate a $formattedEndDate';

    // Nombre del responsable (priorizar profesorResponsableNombre, luego solicitante)
    final String responsable = actividad.profesorResponsableNombre ??
        (actividad.solicitante != null
            ? '${actividad.solicitante!.nombre} ${actividad.solicitante!.apellidos}'
            : 'Sin responsable');

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
              color: Colors.blue,
              onPressed: () => _showEditDialog(context),
            ),
          ],
        ),
        SizedBox(height: 8),
        
        // Descripción
        if (actividad.descripcion != null && actividad.descripcion!.isNotEmpty)
          Text(
            actividad.descripcion!,
            style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        if (actividad.descripcion != null && actividad.descripcion!.isNotEmpty)
          SizedBox(height: 8),
        
        // Responsable y Fecha en la misma fila
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: !isWeb ? 16.dg : 5.sp,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      responsable,
                      style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.blue,
                  size: !isWeb ? 16.dg : 5.sp,
                ),
                SizedBox(width: 4),
                Text(
                  dateText,
                  style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),
        
        // Tipo y Estado en la misma fila
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              toBeginningOfSentenceCase(actividad.tipo) ?? '',
              style: TextStyle(fontSize: !isWeb ? 13.dg : 4.sp),
            ),
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: Colors.blue,
                  size: !isWeb ? 16.dg : 5.sp,
                ),
                SizedBox(width: 4),
                Text(
                  actividad.estado,
                  style: TextStyle(
                      fontSize: !isWeb ? 13.dg : 4.sp, fontWeight: FontWeight.bold),
                ),
              ],
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
        return EditActivityDialog(
          actividad: actividad,
          onSave: onActivityUpdate,
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
                    color: Colors.blue,
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
