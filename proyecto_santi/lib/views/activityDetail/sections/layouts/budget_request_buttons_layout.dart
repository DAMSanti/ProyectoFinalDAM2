import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/app_colors.dart';

/// Widget que maneja el layout responsive de los botones de solicitar presupuestos.
/// 
/// Muestra botones para solicitar presupuestos de transporte y/o alojamiento
/// seg�n est�n activados.
/// 
/// Layout:
/// - Mobile landscape: columna vertical compacta
/// - Mobile portrait: columna vertical con m�s espaciado
/// - Desktop: fila horizontal con texto abreviado
class BudgetRequestButtonsLayout extends StatelessWidget {
  final bool isMobile;
  final bool isMobileLandscape;
  final bool transporteReq;
  final bool alojamientoReq;
  final VoidCallback onRequestTransporte;
  final VoidCallback onRequestAlojamiento;

  const BudgetRequestButtonsLayout({
    super.key,
    required this.isMobile,
    required this.isMobileLandscape,
    required this.transporteReq,
    required this.alojamientoReq,
    required this.onRequestTransporte,
    required this.onRequestAlojamiento,
  });

  @override
  Widget build(BuildContext context) {
    // Si ninguno est� activo, no mostrar nada
    if (!transporteReq && !alojamientoReq) {
      return SizedBox.shrink();
    }

    if (isMobileLandscape) {
      return _buildMobileLandscapeLayout();
    } else if (isMobile) {
      return _buildMobilePortraitLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  /// Layout para m�vil en modo landscape (columna compacta)
  Widget _buildMobileLandscapeLayout() {
    return Column(
      children: [
        if (transporteReq) ...[
          _buildButton(
            onTap: onRequestTransporte,
            color: AppColors.tipoComplementaria,
            text: 'Solicitar Presupuestos',
            iconSize: 14,
            fontSize: 13,
            horizontalPadding: 14,
            verticalPadding: 10,
            borderRadius: 10,
          ),
          if (alojamientoReq) SizedBox(height: 6),
        ],
        if (alojamientoReq)
          _buildButton(
            onTap: onRequestAlojamiento,
            color: AppColors.presupuestoAlojamiento,
            text: 'Solicitar Presupuestos',
            iconSize: 14,
            fontSize: 13,
            horizontalPadding: 14,
            verticalPadding: 10,
            borderRadius: 10,
          ),
      ],
    );
  }

  /// Layout para m�vil en modo portrait (columna con espaciado)
  Widget _buildMobilePortraitLayout() {
    return Column(
      children: [
        if (transporteReq) ...[
          _buildButton(
            onTap: onRequestTransporte,
            color: AppColors.tipoComplementaria,
            text: 'Solicitar Presupuestos',
            iconSize: 16,
            fontSize: 14,
            horizontalPadding: 16,
            verticalPadding: 12,
            borderRadius: 12,
          ),
          if (alojamientoReq) SizedBox(height: 10),
        ],
        if (alojamientoReq)
          _buildButton(
            onTap: onRequestAlojamiento,
            color: AppColors.presupuestoAlojamiento,
            text: 'Solicitar Presupuestos',
            iconSize: 16,
            fontSize: 14,
            horizontalPadding: 16,
            verticalPadding: 12,
            borderRadius: 12,
          ),
      ],
    );
  }

  /// Layout para escritorio (fila horizontal con texto corto)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        if (transporteReq)
          Expanded(
            child: _buildButton(
              onTap: onRequestTransporte,
              color: AppColors.tipoComplementaria,
              text: 'Solicitar',
              iconSize: 18,
              fontSize: 14,
              horizontalPadding: 16,
              verticalPadding: 12,
              borderRadius: 12,
            ),
          ),
        if (transporteReq && alojamientoReq) SizedBox(width: 10),
        if (alojamientoReq)
          Expanded(
            child: _buildButton(
              onTap: onRequestAlojamiento,
              color: AppColors.presupuestoAlojamiento,
              text: 'Solicitar',
              iconSize: 18,
              fontSize: 14,
              horizontalPadding: 16,
              verticalPadding: 12,
              borderRadius: 12,
            ),
          ),
      ],
    );
  }

  /// Construye un bot�n de solicitud con estilo gradiente
  Widget _buildButton({
    required VoidCallback onTap,
    required Color color,
    required String text,
    required double iconSize,
    required double fontSize,
    required double horizontalPadding,
    required double verticalPadding,
    required double borderRadius,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.85),
              color.withValues(alpha: 0.65),
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: borderRadius == 10 ? 6 : 8,
              offset: Offset(0, borderRadius == 10 ? 2 : 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: iconSize,
            ),
            SizedBox(width: iconSize == 14 ? 6 : 8),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
