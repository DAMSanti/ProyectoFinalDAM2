// Archivo específico para web
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:universal_html/html.dart' as html;

void registerWebPdfView(String blobUrl) {
  ui_web.platformViewRegistry.registerViewFactory(
    'pdf-viewer-${blobUrl.hashCode}',
    (int viewId) {
      final iframe = html.IFrameElement()
        ..src = blobUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      
      return iframe;
    },
  );
}
