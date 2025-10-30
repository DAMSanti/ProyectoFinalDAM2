import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

class PdfViewerDialog extends StatefulWidget {
  final String pdfUrl;
  final String fileName;

  const PdfViewerDialog({
    super.key,
    required this.pdfUrl,
    required this.fileName,
  });

  @override
  State<PdfViewerDialog> createState() => _PdfViewerDialogState();
}

class _PdfViewerDialogState extends State<PdfViewerDialog> {
  bool _isDownloading = false;
  bool _isLoading = true;
  Uint8List? _pdfBytes;
  String? _loadError;
  String? _blobUrl; // Para web: URL del blob del PDF

  @override
  void initState() {
    super.initState();
    _loadPdfBytes();
  }

  @override
  void dispose() {
    // Limpiar el blob URL en web para liberar memoria
    if (kIsWeb && _blobUrl != null) {
      html.Url.revokeObjectUrl(_blobUrl!);
    }
    super.dispose();
  }

  /// Carga los bytes del PDF desde la URL
  Future<void> _loadPdfBytes() async {
    try {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });

      final fullUrl = _getFullPdfUrl();
      print('[PDF_VIEWER] Descargando PDF desde: $fullUrl');
      
      final response = await http.get(Uri.parse(fullUrl));
      
      if (response.statusCode == 200) {
        if (mounted) {
          print('[PDF_VIEWER] PDF cargado correctamente (${response.bodyBytes.length} bytes)');
          
          // En web, crear un blob URL para el iframe
          if (kIsWeb) {
            final blob = html.Blob([response.bodyBytes], 'application/pdf');
            final url = html.Url.createObjectUrlFromBlob(blob);
            print('[PDF_VIEWER] Blob URL creado para web: $url');
            
            setState(() {
              _pdfBytes = response.bodyBytes;
              _blobUrl = url;
              _isLoading = false;
            });
          } else {
            setState(() {
              _pdfBytes = response.bodyBytes;
              _isLoading = false;
            });
          }
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('[PDF_VIEWER ERROR] Error al cargar bytes del PDF: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = 'Error al cargar el PDF: $e';
        });
      }
    }
  }

  /// Construye la URL completa del PDF si es una ruta relativa
  String _getFullPdfUrl() {
    final url = widget.pdfUrl;
    
    // Si ya es una URL completa (empieza con http:// o https://), retornarla tal cual
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    // Si es una ruta relativa, construir la URL completa
    // El backend devuelve URLs como '/uploads/folletos/filename.pdf'
    final baseUrl = kIsWeb ? 'http://localhost:5000' : 
                    (Platform.isAndroid ? 'http://192.168.1.42:5000' : 'http://localhost:5000');
    
    // Asegurar que la URL no tenga doble barra
    final cleanUrl = url.startsWith('/') ? url : '/$url';
    
    // Construir la URL completa y codificar caracteres especiales (espacios, etc.)
    final fullUrl = Uri.parse('$baseUrl$cleanUrl').toString();
    
    print('[PDF_VIEWER] URL original: $url');
    print('[PDF_VIEWER] URL completa: $fullUrl');
    print('[PDF_VIEWER] Intentando cargar PDF...');
    
    return fullUrl;
  }

  Future<void> _downloadPdf() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final fullUrl = _getFullPdfUrl();
      
      if (kIsWeb) {
        // Para web, usar AnchorElement para descargar
        html.AnchorElement anchorElement = html.AnchorElement(href: fullUrl);
        anchorElement.download = widget.fileName;
        anchorElement.click();
        
        if (mounted) {
          // Usar un SnackBar dentro del diálogo no es posible, mostrar un mensaje simple
          print('[PDF_VIEWER] Descarga iniciada: ${widget.fileName}');
        }
      } else {
        // Para móvil/escritorio
        final response = await http.get(Uri.parse(fullUrl));
        
        if (response.statusCode == 200) {
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/${widget.fileName}');
          await file.writeAsBytes(response.bodyBytes);
          
          if (mounted) {
            print('[PDF_VIEWER] PDF descargado en: ${file.path}');
          }
        } else {
          throw Exception('Error al descargar el PDF');
        }
      }
    } catch (e) {
      if (mounted) {
        print('[PDF_VIEWER ERROR] Error al descargar: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 24,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header del diálogo
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1976d2),
                    Color(0xFF1565c0),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Colors.white,
                    size: !isWeb ? 24.dg : 7.sp,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vista Previa del Folleto',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: !isWeb ? 16.dg : 5.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.fileName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: !isWeb ? 12.dg : 4.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Botón de descargar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: _isDownloading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                              size: !isWeb ? 24.dg : 7.sp,
                            ),
                      onPressed: _isDownloading ? null : _downloadPdf,
                      tooltip: 'Descargar PDF',
                    ),
                  ),
                  SizedBox(width: 8),
                  // Botón de cerrar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: !isWeb ? 24.dg : 7.sp,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Cerrar',
                    ),
                  ),
                ],
              ),
            ),
            
            // Visor de PDF
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Cargando PDF...',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  fontSize: !isWeb ? 14.dg : 4.5.sp,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _loadError != null
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      size: 64,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      _loadError!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : Colors.black54,
                                        fontSize: !isWeb ? 14.dg : 4.5.sp,
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: _loadPdfBytes,
                                      icon: Icon(Icons.refresh_rounded),
                                      label: Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _pdfBytes != null
                              ? (kIsWeb && _blobUrl != null)
                                  // Para web: usar HtmlElementView con iframe
                                  ? _WebPdfViewer(blobUrl: _blobUrl!)
                                  // Para móvil/desktop: usar SfPdfViewer.memory
                                  : SfPdfViewer.memory(
                                      _pdfBytes!,
                                      canShowScrollHead: true,
                                      canShowScrollStatus: true,
                                      enableDoubleTapZooming: true,
                                      enableTextSelection: true,
                                      onDocumentLoaded: (details) {
                                        print('[PDF_VIEWER] PDF renderizado correctamente');
                                      },
                                      onDocumentLoadFailed: (details) {
                                        print('[PDF_VIEWER ERROR] Error al renderizar: ${details.error}');
                                        print('[PDF_VIEWER ERROR] Descripción: ${details.description}');
                                        if (mounted) {
                                          setState(() {
                                            _loadError = 'Error al mostrar el PDF: ${details.description}';
                                          });
                                        }
                                      },
                                    )
                              : Center(
                                  child: Text('No se pudo cargar el PDF'),
                                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget específico para mostrar PDFs en Flutter Web usando iframe
class _WebPdfViewer extends StatefulWidget {
  final String blobUrl;

  const _WebPdfViewer({required this.blobUrl});

  @override
  State<_WebPdfViewer> createState() => _WebPdfViewerState();
}

class _WebPdfViewerState extends State<_WebPdfViewer> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Registrar el view factory para el iframe
      ui_web.platformViewRegistry.registerViewFactory(
        'pdf-viewer-${widget.blobUrl.hashCode}',
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = widget.blobUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';
          
          print('[PDF_VIEWER] IFrame creado con src: ${widget.blobUrl}');
          return iframe;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Center(child: Text('Este widget solo funciona en web'));
    }

    return HtmlElementView(
      viewType: 'pdf-viewer-${widget.blobUrl.hashCode}',
    );
  }
}
