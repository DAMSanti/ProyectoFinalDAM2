import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewWidget extends StatelessWidget {
  final XFile? imageFile;
  final String? imageUrl;

  const ImagePreviewWidget({
    super.key,
    this.imageFile,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        headers: {
          'Access-Control-Allow-Origin': '*',
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  'Error al cargar',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        },
      );
    } else if (kIsWeb) {
      return Image.network(
        imageFile!.path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.broken_image_rounded,
              size: 64,
              color: Colors.grey,
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(imageFile!.path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.broken_image_rounded,
              size: 64,
              color: Colors.grey,
            ),
          );
        },
      );
    }
  }
}
