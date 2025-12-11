import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:proyecto_santi/tema/app_colors.dart';
import 'package:proyecto_santi/config.dart';
import '../helpers/pdf_helpers/web_pdf_helper_stub.dart' if (dart.library.html) '../helpers/pdf_helpers/web_pdf_helper.dart';
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
  String? _blobUrl; 
  @override
  void initState() {
    super.initState();
    _loadPdfBytes();
  }
  @override
  void dispose() {
    if (kIsWeb && _blobUrl != null) {
      html.Url.revokeObjectUrl(_blobUrl!);
    }
    super.dispose();
  }
  Future<void> _loadPdfBytes() async {
    try {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
      final fullUrl = _getFullPdfUrl();
      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        if (mounted) {
          if (kIsWeb) {
            final blob = html.Blob([response.bodyBytes], 'application/pdf');
            final url = html.Url.createObjectUrlFromBlob(blob);
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
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = 'Error al cargar el PDF: $e';
        });
      }
    }
  }
  String _getFullPdfUrl() {
    final url = widget.pdfUrl;
    if (url.startsWith('http:
      return url;
    }
    final baseUrl = AppConfig.apiBaseUrl.replaceAll('/api', '');
    final cleanUrl = url.startsWith('/') ? url : '/$url';
    final fullUrl = Uri.parse('$baseUrl$cleanUrl').toString();
    print('[PdfViewerDialog] URL completa del PDF: $fullUrl');
    return fullUrl;
  }
  Future<void> _downloadPdf() async {
    setState(() {
      _isDownloading = true;
    });
    try {
      final fullUrl = _getFullPdfUrl();
      if (kIsWeb) {
        html.AnchorElement anchorElement = html.AnchorElement(href: fullUrl);
        anchorElement.download = widget.fileName;
        anchorElement.click();
        if (mounted) {
        }
      } else {
        await _downloadPdfNative(fullUrl);
      }
    } catch (e) {
      if (mounted) {
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }
  Future<void> _downloadPdfNative(String url) async {
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb;
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
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
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
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: !isWeb ? 12.dg : 4.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
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
                                      color: AppColors.estadoRechazado,
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
                                  ? _WebPdfViewer(blobUrl: _blobUrl!)
                                  : SfPdfViewer.memory(
                                      _pdfBytes!,
                                      canShowScrollHead: true,
                                      canShowScrollStatus: true,
                                      enableDoubleTapZooming: true,
                                      enableTextSelection: true,
                                      onDocumentLoaded: (details) {
                                      },
                                      onDocumentLoadFailed: (details) {
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
class _WebPdfViewer extends StatefulWidget {
  final String blobUrl;
  const _WebPdfViewer({required this.blobUrl});
  @override
  State<_WebPdfViewer> createState() => _WebPdfViewerState();
}
class _WebPdfViewerState extends State<_WebPdfViewer> {
  bool _registered = false;
  @override
  void initState() {
    super.initState();
    if (kIsWeb && !_registered) {
      registerWebPdfView(widget.blobUrl);
      _registered = true;
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