import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proyecto_santi/views/estadisticas/models/chart_item.dart';
import 'package:proyecto_santi/views/estadisticas/models/filter_period.dart';
import 'package:intl/intl.dart';

class PdfExportService {
  static Future<void> generateAndExport({
    required BuildContext context,
    required List<ChartItem> charts,
    required FilterPeriod filterPeriod,
    required Map<ChartType, GlobalKey> chartKeys,
  }) async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando PDF...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Dar tiempo para que los widgets se rendericen completamente
      await Future.delayed(Duration(milliseconds: 500));
      
      final pdf = pw.Document();
      
      // Capturar imágenes de las gráficas seleccionadas
      final chartImages = <ChartType, Uint8List>{};
      
      for (final chart in charts) {
        if (chartKeys.containsKey(chart.type)) {
          print('Capturando gráfica: ${chart.title}');
          final image = await _captureWidget(chartKeys[chart.type]!);
          if (image != null) {
            chartImages[chart.type] = image;
            print('✓ Gráfica capturada: ${chart.title}');
          } else {
            print('✗ Error capturando: ${chart.title}');
          }
        }
      }

      if (chartImages.isEmpty) {
        throw Exception('No se pudo capturar ninguna gráfica');
      }

      print('Total gráficas capturadas: ${chartImages.length}');

      // Generar páginas del PDF
      await _addPdfPages(
        pdf: pdf,
        charts: charts,
        chartImages: chartImages,
        filterPeriod: filterPeriod,
      );

      // Cerrar diálogo de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      print('Total gráficas capturadas: ${chartImages.length}');
      print('Abriendo preview del PDF...');

      // Mostrar preview del PDF en diálogo
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => PdfPreviewDialog(
            pdf: pdf,
            fileName: 'estadisticas_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
          ),
        );
      }
      
      print('Preview cerrado');
    } catch (e, stackTrace) {
      print('Error generando PDF: $e');
      print('Stack trace: $stackTrace');
      
      // Cerrar diálogo de carga si está abierto
      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar el PDF: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  static Future<Uint8List?> _captureWidget(GlobalKey key) async {
    try {
      // Asegurar que el widget esté renderizado
      await Future.delayed(Duration(milliseconds: 100));
      
      final context = key.currentContext;
      if (context == null) {
        print('Error: Context es null para la key');
        return null;
      }
      
      final renderObject = context.findRenderObject();
      if (renderObject == null) {
        print('Error: RenderObject es null');
        return null;
      }
      
      if (renderObject is! RenderRepaintBoundary) {
        print('Error: RenderObject no es RenderRepaintBoundary');
        return null;
      }
      
      final boundary = renderObject as RenderRepaintBoundary;
      
      // Capturar imagen con alta resolución
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        print('Error: ByteData es null');
        return null;
      }
      
      return byteData.buffer.asUint8List();
    } catch (e, stackTrace) {
      print('Error capturando widget: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<void> _addPdfPages({
    required pw.Document pdf,
    required List<ChartItem> charts,
    required Map<ChartType, Uint8List> chartImages,
    required FilterPeriod filterPeriod,
  }) async {
    // Página de portada
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [
                    PdfColor.fromHex('#1E88E5'),
                    PdfColor.fromHex('#1565C0'),
                  ],
                ),
              ),
              child: pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'ACEX',
                      style: pw.TextStyle(
                        fontSize: 48,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'Informe de Estadísticas',
                      style: pw.TextStyle(
                        fontSize: 24,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 32),
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0x33FFFFFF), // White with 20% alpha
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'Período: ${_getPeriodLabel(filterPeriod)}',
                            style: pw.TextStyle(
                              fontSize: 16,
                              color: PdfColors.white,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              color: PdfColor.fromInt(0xE6FFFFFF), // White with 90% alpha
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );    // Páginas con gráficas (2 por página)
    for (int i = 0; i < charts.length; i += 2) {
      final chart1 = charts[i];
      final image1 = chartImages[chart1.type];
      
      final chart2 = i + 1 < charts.length ? charts[i + 1] : null;
      final image2 = chart2 != null ? chartImages[chart2.type] : null;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildPdfHeader(filterPeriod),
                pw.SizedBox(height: 24),

                // Primera gráfica
                if (image1 != null) ...[
                  _buildChartSection(chart1.title, chart1.description, image1),
                  if (image2 != null) pw.SizedBox(height: 24),
                ],

                // Segunda gráfica (si existe)
                if (image2 != null && chart2 != null) ...[
                  _buildChartSection(chart2.title, chart2.description, image2),
                ],

                pw.Spacer(),

                // Footer
                _buildPdfFooter(context),
              ],
            );
          },
        ),
      );
    }
  }

  static pw.Widget _buildPdfHeader(FilterPeriod filterPeriod) {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F5F5F5'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Informe de Estadísticas',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1E88E5'),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Período: ${_getPeriodLabel(filterPeriod)}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Text(
            DateFormat('dd/MM/yyyy').format(DateTime.now()),
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildChartSection(String title, String description, Uint8List imageData) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F5F5F5'),
              borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1E88E5'),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  description,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(12),
            child: pw.Center(
              child: pw.Image(
                pw.MemoryImage(imageData),
                fit: pw.BoxFit.contain,
                height: 200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generado por ACEX',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  static String _getPeriodLabel(FilterPeriod period) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    switch (period.type) {
      case FilterPeriodType.custom:
        return '${dateFormat.format(period.startDate)} - ${dateFormat.format(period.endDate)}';
      case FilterPeriodType.last30Days:
        return 'Últimos 30 días';
      case FilterPeriodType.last90Days:
        return 'Últimos 90 días';
      case FilterPeriodType.currentMonth:
        return 'Mes actual (${DateFormat('MMMM yyyy', 'es').format(period.startDate)})';
      case FilterPeriodType.currentYear:
        return 'Año actual (${period.startDate.year})';
      case FilterPeriodType.academicYear:
        final startYear = period.startDate.year;
        final endYear = period.endDate.year;
        return 'Año académico $startYear/$endYear';
      case FilterPeriodType.quarter:
        final quarter = ((period.startDate.month - 1) ~/ 3) + 1;
        return 'Trimestre $quarter de ${period.startDate.year}';
    }
  }
}

/// Diálogo para mostrar la vista previa del PDF
class PdfPreviewDialog extends StatelessWidget {
  final pw.Document pdf;
  final String fileName;

  const PdfPreviewDialog({
    Key? key,
    required this.pdf,
    required this.fileName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
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
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vista Previa PDF',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          fileName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),

            // PDF Preview
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PdfPreview(
                    build: (format) => pdf.save(),
                    allowSharing: false,
                    allowPrinting: false,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    canDebug: false,
                    pdfFileName: fileName,
                    scrollViewDecoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.grey[200],
                    ),
                  ),
                ),
              ),
            ),

            // Footer con botones
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                    label: Text('Cancelar'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.black54,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final bytes = await pdf.save();
                      await Printing.sharePdf(
                        bytes: bytes,
                        filename: fileName,
                      );
                    },
                    icon: Icon(Icons.share),
                    label: Text('Compartir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Printing.layoutPdf(
                        onLayout: (format) => pdf.save(),
                      );
                    },
                    icon: Icon(Icons.print),
                    label: Text('Imprimir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
