// Archivo específico para web
import 'dart:ui' as ui;
import 'package:universal_html/html.dart' as html;

void registerWebPdfView(String blobUrl) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
    'pdf-viewer-${blobUrl.hashCode}',
    (int viewId) {
      final iframe = html.IFrameElement()
        ..src = blobUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      
      print('[PDF_VIEWER] IFrame creado con src: $blobUrl');
      return iframe;
    },
  );
}
