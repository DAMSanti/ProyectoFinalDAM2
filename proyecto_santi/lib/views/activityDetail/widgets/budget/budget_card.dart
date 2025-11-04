import 'package:flutter/material.dart';
import '../../../../models/empresa_transporte.dart';
import '../../../../models/alojamiento.dart';

/// Widget reutilizable para mostrar tarjetas de presupuesto
/// Soporta modo display y modo edición con callbacks
class BudgetCardWidget extends StatelessWidget {
  final String titulo;
  final double valor;
  final IconData icono;
  final Color color;
  final double width;
  final bool isWeb;
  final bool showEdit;
  final bool isEditing;
  final VoidCallback? onEditPressed;
  final EmpresaTransporte? empresaTransporte;
  final Alojamiento? alojamiento;
  final List<EmpresaTransporte>? empresasDisponibles;
  final List<Alojamiento>? alojamientosDisponibles;
  final Function(EmpresaTransporte?)? onEmpresaChanged;
  final Function(Alojamiento?)? onAlojamientoChanged;
  final bool cargandoEmpresas;
  final bool cargandoAlojamientos;
  final TextEditingController? controller;
  final Function(String)? onSubmitted;

  const BudgetCardWidget({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    required this.width,
    required this.isWeb,
    this.showEdit = false,
    this.isEditing = false,
    this.onEditPressed,
    this.empresaTransporte,
    this.alojamiento,
    this.empresasDisponibles,
    this.alojamientosDisponibles,
    this.onEmpresaChanged,
    this.onAlojamientoChanged,
    this.cargandoEmpresas = false,
    this.cargandoAlojamientos = false,
    this.controller,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      width: width > 600 ? width : double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 18, 
        vertical: isMobile ? 8 : 14,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: isMobile ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: isMobile ? 6 : 12,
            offset: Offset(0, isMobile ? 2 : 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (titulo != 'Coste por Alumno')
            SizedBox(height: isMobile ? 6 : 8),
          if (isEditing && controller != null)
            _buildEditingContent(context)
          else if (titulo == 'Coste por Alumno')
            _buildCosteAlumnoContent(context)
          else
            _buildDisplayContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Para "Coste por Alumno" no mostrar header separado
    if (titulo == 'Coste por Alumno') {
      return SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // Ocultar icono en móvil
              if (!isMobile)
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.8),
                        color.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icono,
                    color: Colors.white,
                    size: isWeb ? 22 : 24.0,
                  ),
                ),
              if (!isMobile) SizedBox(width: 12),
              Flexible(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : (isWeb ? 14 : 16.0),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (showEdit && onEditPressed != null)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEditing
                    ? [Colors.green.withValues(alpha: 0.2), Colors.green.withValues(alpha: 0.1)]
                    : [Colors.grey.withValues(alpha: 0.2), Colors.grey.withValues(alpha: 0.1)],
              ),
              borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                onTap: onEditPressed,
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 4 : 8),
                  child: Icon(
                    isEditing ? Icons.check_circle : Icons.edit_rounded,
                    size: isMobile ? 14 : (isWeb ? 20 : 22.0),
                    color: isEditing ? Colors.green[700] : color,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditingContent(BuildContext context) {
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Si es transporte o alojamiento con dropdown
    if ((titulo == 'Transporte' && empresasDisponibles != null) ||
        (titulo == 'Alojamiento' && alojamientosDisponibles != null)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Campo de precio
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: isMobile ? 14 : (isWeb ? 16 : 18.0),
                fontWeight: FontWeight.bold,
                color: color,
              ),
              decoration: InputDecoration(
                suffix: Text(
                  '€',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : (isWeb ? 16 : 18.0),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8, horizontal: 0),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: color),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: color, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          // Dropdown
          Expanded(
            flex: 3,
            child: titulo == 'Transporte'
                ? _buildEmpresaDropdown(context)
                : _buildAlojamientoDropdown(context),
          ),
        ],
      );
    }

    // Campo simple de edición (para Presupuesto Estimado)
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        fontSize: isMobile ? 14 : (isWeb ? 16 : 18.0),
        fontWeight: FontWeight.bold,
        color: color,
      ),
      decoration: InputDecoration(
        suffix: Text(
          '€',
          style: TextStyle(
            fontSize: isMobile ? 14 : (isWeb ? 16 : 18.0),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8, horizontal: 0),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
      autofocus: true,
      onSubmitted: onSubmitted,
    );
  }

  Widget _buildEmpresaDropdown(BuildContext context) {
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    if (cargandoEmpresas) {
      return Center(
        child: SizedBox(
          height: isMobile ? 16 : 20,
          width: isMobile ? 16 : 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: color,
          ),
        ),
      );
    }

    final empresasUnicas = _getUniqueEmpresas();

    return Container(
      padding: EdgeInsets.only(bottom: isMobile ? 6 : 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: color, width: 1),
        ),
      ),
      child: DropdownButton<EmpresaTransporte>(
        value: empresaTransporte,
        isExpanded: true,
        underline: SizedBox(),
        hint: Text(
          'Sin selección',
          style: TextStyle(
            fontSize: isMobile ? 11 : (isWeb ? 12 : 14.0),
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: Icon(Icons.arrow_drop_down, color: color, size: isMobile ? 18 : 24),
        selectedItemBuilder: (BuildContext context) {
          return empresasUnicas.map((empresa) {
            return Text(
              empresa.nombre,
              style: TextStyle(
                fontSize: isMobile ? 11 : (isWeb ? 12 : 14.0),
                color: color,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList();
        },
        items: empresasUnicas.isEmpty
            ? [
                DropdownMenuItem<EmpresaTransporte>(
                  value: null,
                  child: Text(
                    'No hay empresas disponibles',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : (isWeb ? 12 : 14.0),
                      color: Colors.grey[600],
                    ),
                  ),
                )
              ]
            : empresasUnicas.map((empresa) {
                return DropdownMenuItem<EmpresaTransporte>(
                  value: empresa,
                  child: Text(
                    empresa.nombre,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : (isWeb ? 12 : 14.0),
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
        onChanged: onEmpresaChanged,
      ),
    );
  }

  Widget _buildAlojamientoDropdown(BuildContext context) {
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    if (cargandoAlojamientos) {
      return Center(
        child: SizedBox(
          height: isMobile ? 16 : 20,
          width: isMobile ? 16 : 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: color,
          ),
        ),
      );
    }

    final alojamientosUnicos = _getUniqueAlojamientos();

    return Container(
      padding: EdgeInsets.only(bottom: isMobile ? 6 : 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: color, width: 1),
        ),
      ),
      child: DropdownButton<Alojamiento>(
        value: alojamiento,
        isExpanded: true,
        underline: SizedBox(),
        hint: Text(
          'Seleccione alojamiento',
          style: TextStyle(
            fontSize: isMobile ? 11 : (isWeb ? 12 : 14.0),
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: Icon(Icons.arrow_drop_down, color: color, size: isMobile ? 18 : 24),
        items: [
          DropdownMenuItem<Alojamiento>(
            value: null,
            child: Text(
              'Sin selección',
              style: TextStyle(
                fontSize: isMobile ? 11 : (isWeb ? 12 : 14.0),
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          ...alojamientosUnicos.map((alojamiento) {
            return DropdownMenuItem<Alojamiento>(
              value: alojamiento,
              child: Text(
                alojamiento.nombre,
                style: TextStyle(
                  fontSize: isMobile ? 11 : (isWeb ? 12 : 14.0),
                  color: Colors.black87,
                ),
              ),
            );
          }),
        ],
        onChanged: onAlojamientoChanged,
      ),
    );
  }

  Widget _buildCosteAlumnoContent(BuildContext context) {
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(
              icono,
              color: color,
              size: isMobile ? 16 : (isWeb ? 20 : 22.0),
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: isMobile ? 12 : (isWeb ? 13 : 15.0),
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Text(
          '${valor.toStringAsFixed(2)} €',
          style: TextStyle(
            fontSize: isMobile ? 14 : (isWeb ? 16 : 18.0),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayContent(BuildContext context) {
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${valor.toStringAsFixed(2)} €',
          style: TextStyle(
            fontSize: isMobile ? 14 : (isWeb ? 16 : 18.0),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (titulo == 'Transporte' && empresaTransporte != null)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: isMobile ? 6 : 8),
              child: Text(
                empresaTransporte!.nombre,
                style: TextStyle(
                  fontSize: isMobile ? 11 : (isWeb ? 12 : 14.0),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        if (titulo == 'Alojamiento' && alojamiento != null)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: isMobile ? 6 : 8),
              child: Text(
                alojamiento!.nombre,
                style: TextStyle(
                  fontSize: isMobile ? 11 : (isWeb ? 12 : 14.0),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }

  List<EmpresaTransporte> _getUniqueEmpresas() {
    if (empresasDisponibles == null) return [];
    final idsVistos = <int>{};
    final empresasUnicas = <EmpresaTransporte>[];
    for (var empresa in empresasDisponibles!) {
      if (!idsVistos.contains(empresa.id)) {
        idsVistos.add(empresa.id);
        empresasUnicas.add(empresa);
      }
    }
    return empresasUnicas;
  }

  List<Alojamiento> _getUniqueAlojamientos() {
    if (alojamientosDisponibles == null) return [];
    final idsVistos = <int>{};
    final alojamientosUnicos = <Alojamiento>[];
    for (var alojamiento in alojamientosDisponibles!) {
      if (!idsVistos.contains(alojamiento.id)) {
        idsVistos.add(alojamiento.id);
        alojamientosUnicos.add(alojamiento);
      }
    }
    return alojamientosUnicos;
  }
}
