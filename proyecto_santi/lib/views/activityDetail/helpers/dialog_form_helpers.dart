import 'package:flutter/material.dart';
import 'package:proyecto_santi/tema/tema.dart';

/// Clase con métodos helper para construir formularios en diálogos
class DialogFormHelpers {
  /// Construye un título de sección con icono y gradiente
  static Widget buildSectionTitle(
    String title,
    IconData icon,
    bool isMobile,
    bool isMobileLandscape,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
            ),
            borderRadius: BorderRadius.circular(isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
          ),
          child: Icon(icon, color: Colors.white, size: isMobileLandscape ? 14 : (isMobile ? 16 : 20)),
        ),
        SizedBox(width: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
        Text(
          title,
          style: TextStyle(
            fontSize: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  /// Construye un TextField personalizado con estilo consistente
  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String hint = '',
    int? maxLines = 1,
    bool isRequired = false,
    bool isMobile = false,
    bool isMobileLandscape = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
        border: Border.all(
          color: AppColors.primaryOpacity30,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16)),
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          labelStyle: TextStyle(fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14)),
          hintText: hint,
          hintStyle: TextStyle(fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14)),
          prefixIcon: Icon(icon, color: AppColors.primary, size: isMobileLandscape ? 18 : (isMobile ? 20 : 24)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobileLandscape ? 10 : (isMobile ? 12 : 16),
            vertical: isMobileLandscape ? 10 : (isMobile ? 12 : 16),
          ),
        ),
      ),
    );
  }

  /// Construye un botón para seleccionar fecha/hora
  static Widget buildDateTimeButton({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    bool isMobile = false,
    bool isMobileLandscape = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
        border: Border.all(
          color: AppColors.primaryOpacity30,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
          child: Padding(
            padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: isMobileLandscape ? 12 : (isMobile ? 14 : 16), color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: isMobileLandscape ? 10 : (isMobile ? 11 : 12),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye un Dropdown con estilo consistente
  static Widget buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    bool isMobile = false,
    bool isMobileLandscape = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
        border: Border.all(
          color: AppColors.primaryOpacity30,
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        style: TextStyle(fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16), color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14)),
          prefixIcon: Icon(icon, color: AppColors.primary, size: isMobileLandscape ? 18 : (isMobile ? 20 : 24)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobileLandscape ? 10 : (isMobile ? 12 : 16),
            vertical: isMobileLandscape ? 10 : (isMobile ? 12 : 16),
          ),
        ),
        isExpanded: true,
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  /// Construye una opción de radio button con icono y estilo visual
  static Widget buildRadioOption({
    required String value,
    required String groupValue,
    required String label,
    required IconData icon,
    required Color color,
    required void Function(String?) onChanged,
    bool isMobile = false,
    bool isMobileLandscape = false,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobileLandscape ? 5 : (isMobile ? 6 : 8),
          horizontal: isMobileLandscape ? 1 : (isMobile ? 2 : 4),
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isMobileLandscape ? 14 : (isMobile ? 16 : 20),
              ),
            ),
            SizedBox(height: isMobileLandscape ? 2 : (isMobile ? 3 : 4)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobileLandscape ? 9 : (isMobile ? 10 : 11),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
