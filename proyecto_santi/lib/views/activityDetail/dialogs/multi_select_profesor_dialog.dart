import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/shared/widgets/dialog_header.dart';
import 'package:proyecto_santi/shared/widgets/dialog_footer.dart';

/// Diálogo para seleccionar múltiples profesores participantes
class MultiSelectProfesorDialog extends StatefulWidget {
  final List<Profesor> profesores;
  final List<Profesor> profesoresYaSeleccionados;

  const MultiSelectProfesorDialog({
    Key? key,
    required this.profesores,
    required this.profesoresYaSeleccionados,
  }) : super(key: key);

  @override
  State<MultiSelectProfesorDialog> createState() => _MultiSelectProfesorDialogState();
}

class _MultiSelectProfesorDialogState extends State<MultiSelectProfesorDialog> {
  final List<Profesor> _selectedProfesores = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // No pre-seleccionamos ninguno, el usuario elegirá
  }

  List<Profesor> get _filteredProfesores {
    if (_searchQuery.isEmpty) {
      return widget.profesores;
    }
    
    return widget.profesores.where((profesor) {
      final fullName = '${profesor.nombre} ${profesor.apellidos}'.toLowerCase();
      final email = profesor.correo.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return fullName.contains(query) || email.contains(query);
    }).toList();
  }

  bool _isProfesorYaParticipante(Profesor profesor) {
    return widget.profesoresYaSeleccionados.any((p) => p.uuid == profesor.uuid);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final isMobile = screenWidth < 600;
    final isMobileLandscape = (isMobile && !isPortrait) || (!isPortrait && screenHeight < 500);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: isMobileLandscape
          ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : (isMobile 
              ? EdgeInsets.symmetric(horizontal: 16, vertical: 40)
              : EdgeInsets.symmetric(horizontal: 40, vertical: 24)),
      child: Container(
        width: isMobile ? double.infinity : 600,
        constraints: BoxConstraints(
          maxHeight: isMobileLandscape
              ? screenHeight * 0.95
              : (isMobile ? screenHeight * 0.85 : screenHeight * 0.85),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
              ? const [
                  Color.fromRGBO(25, 118, 210, 0.25),
                  Color.fromRGBO(21, 101, 192, 0.20),
                ]
              : const [
                  Color.fromRGBO(187, 222, 251, 0.95),
                  Color.fromRGBO(144, 202, 249, 0.85),
                ],
          ),
          borderRadius: BorderRadius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
          border: Border.all(
            color: isDark 
              ? const Color.fromRGBO(255, 255, 255, 0.1) 
              : const Color.fromRGBO(0, 0, 0, 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(0, isMobileLandscape ? 6 : 10),
              blurRadius: isMobileLandscape ? 20 : 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            DialogHeader(
              isMobile: isMobile,
              isMobileLandscape: isMobileLandscape,
              onClose: () => Navigator.of(context).pop(),
              title: isMobile ? 'Agregar Profesores' : 'Agregar Profesores Participantes',
              icon: Icons.group_add_rounded,
            ),
            
            // Content - Layout condicional
            Expanded(
              child: isMobileLandscape
                  ? _buildLandscapeMobileLayout(isDark, isMobile, isMobileLandscape)
                  : _buildPortraitLayout(isDark, isMobile, isMobileLandscape),
            ),
            
            // Actions - Footer with custom logic for add button
            _buildCustomFooter(isDark, isMobile, isMobileLandscape, context),
          ],
        ),
      ),
    );
  }

  // Layout vertical para portrait y desktop
  Widget _buildPortraitLayout(bool isDark, bool isMobile, bool isMobileLandscape) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        children: [
          // Buscador
          _buildSearchField(isMobile, isMobileLandscape),
          SizedBox(height: isMobile ? 12 : 16),
          
          // Contador
          if (_selectedProfesores.isNotEmpty) ...[
            _buildCounter(isMobile, isMobileLandscape),
            SizedBox(height: isMobile ? 10 : 12),
          ],
          
          // Lista
          Expanded(
            child: _buildListaProfesores(isDark, isMobile, isMobileLandscape),
          ),
        ],
      ),
    );
  }

  // Layout horizontal 2 columnas para landscape
  Widget _buildLandscapeMobileLayout(bool isDark, bool isMobile, bool isMobileLandscape) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          // Columna izquierda: Búsqueda + contador (40%)
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildSearchField(isMobile, isMobileLandscape),
                SizedBox(height: 10),
                if (_selectedProfesores.isNotEmpty) ...[
                  _buildCounter(isMobile, isMobileLandscape),
                  SizedBox(height: 10),
                ],
                Spacer(),
              ],
            ),
          ),
          SizedBox(width: 12),
          
          // Columna derecha: Lista (60%)
          Expanded(
            flex: 6,
            child: _buildListaProfesores(isDark, isMobile, isMobileLandscape),
          ),
        ],
      ),
    );
  }

  // Campo de búsqueda reutilizable
  Widget _buildSearchField(bool isMobile, bool isMobileLandscape) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(isMobileLandscape ? 10 : (isMobile ? 10 : 12)),
        border: Border.all(
          color: Color(0xFF1976d2).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1976d2).withOpacity(0.1),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: isMobileLandscape ? 'Buscar...' : (isMobile ? 'Buscar...' : 'Buscar profesor por nombre o email...'),
          hintStyle: TextStyle(fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Color(0xFF1976d2),
            size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobileLandscape ? 10 : (isMobile ? 10 : 12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobileLandscape ? 10 : (isMobile ? 12 : 16),
            vertical: isMobileLandscape ? 10 : (isMobile ? 12 : 14),
          ),
          isDense: isMobileLandscape,
        ),
        style: TextStyle(fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14)),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  // Contador de seleccionados reutilizable
  Widget _buildCounter(bool isMobile, bool isMobileLandscape) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobileLandscape ? 10 : (isMobile ? 12 : 16),
        vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1976d2).withOpacity(0.2),
            Color(0xFF1565c0).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
        border: Border.all(
          color: Color(0xFF1976d2).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: isMobileLandscape ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.all(isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
              ),
              borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 6 : 8)),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: isMobileLandscape ? 12 : (isMobile ? 14 : 16),
              color: Colors.white,
            ),
          ),
          SizedBox(width: isMobileLandscape ? 6 : (isMobile ? 8 : 12)),
          Expanded(
            child: Text(
              isMobileLandscape 
                  ? '${_selectedProfesores.length} selec.' 
                  : '${_selectedProfesores.length} profesor(es) seleccionado(s) para agregar',
              style: TextStyle(
                color: Color(0xFF1976d2),
                fontWeight: FontWeight.w600,
                fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 14),
              ),
              maxLines: isMobileLandscape ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Lista de profesores reutilizable
  Widget _buildListaProfesores(bool isDark, bool isMobile, bool isMobileLandscape) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(isMobileLandscape ? 10 : (isMobile ? 10 : 12)),
        border: Border.all(
          color: isDark 
            ? Colors.white.withOpacity(0.1) 
            : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: _filteredProfesores.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
                  decoration: BoxDecoration(
                    color: Color(0xFF1976d2).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: isMobileLandscape ? 32 : (isMobile ? 40 : 48),
                    color: Color(0xFF1976d2).withOpacity(0.5),
                  ),
                ),
                SizedBox(height: isMobileLandscape ? 10 : (isMobile ? 12 : 16)),
                Text(
                  'No se encontraron profesores',
                  style: TextStyle(
                    fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16),
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 0),
                  child: Text(
                    'Intenta con otros términos de búsqueda',
                    style: TextStyle(
                      fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 13),
                      color: isDark ? Colors.white54 : Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
            itemCount: _filteredProfesores.length,
            itemBuilder: (context, index) {
              final profesor = _filteredProfesores[index];
              final yaParticipante = _isProfesorYaParticipante(profesor);
              final isSelected = _selectedProfesores.any((p) => p.uuid == profesor.uuid);
              
              return Container(
                margin: EdgeInsets.only(bottom: isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
                decoration: BoxDecoration(
                  color: yaParticipante 
                    ? Colors.grey.withOpacity(0.1)
                    : isSelected
                      ? Color(0xFF1976d2).withOpacity(0.15)
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                  border: Border.all(
                    color: yaParticipante
                      ? Colors.grey.withOpacity(0.3)
                      : isSelected
                        ? Color(0xFF1976d2).withOpacity(0.5)
                        : Colors.transparent,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: CheckboxListTile(
                  dense: isMobile || isMobileLandscape,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobileLandscape ? 6 : (isMobile ? 8 : 12),
                    vertical: isMobileLandscape ? 2 : (isMobile ? 4 : 8),
                  ),
                  title: Row(
                    children: [
                      Container(
                        width: isMobileLandscape ? 32 : (isMobile ? 36 : 40),
                        height: isMobileLandscape ? 32 : (isMobile ? 36 : 40),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: yaParticipante
                              ? [Colors.grey[400]!, Colors.grey[500]!]
                              : [Color(0xFF1976d2), Color(0xFF1565c0)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${profesor.nombre[0]}${profesor.apellidos[0]}'.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isMobileLandscape ? 11 : (isMobile ? 12 : 14),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${profesor.nombre} ${profesor.apellidos}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!isMobileLandscape)
                              Text(
                                profesor.correo,
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  subtitle: yaParticipante && !isMobileLandscape
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: 8, 
                          left: isMobile ? 46 : 52,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 6 : 8, 
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: isMobile ? 10 : 12,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                isMobile ? 'Ya participa' : 'Ya participa en esta actividad',
                                style: TextStyle(
                                  fontSize: isMobile ? 10 : 11,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
                  value: isSelected,
                  enabled: !yaParticipante,
                  activeColor: Color(0xFF1976d2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                  ),
                  visualDensity: isMobileLandscape 
                      ? VisualDensity.compact 
                      : (isMobile ? VisualDensity.compact : VisualDensity.standard),
                  onChanged: yaParticipante
                      ? null
                      : (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedProfesores.add(profesor);
                            } else {
                              _selectedProfesores.removeWhere((p) => p.uuid == profesor.uuid);
                            }
                          });
                        },
                ),
              );
            },
          ),
    );
  }

  // Custom footer with special logic for enabled/disabled state
  Widget _buildCustomFooter(bool isDark, bool isMobile, bool isMobileLandscape, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey[850]!.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
          bottomRight: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
        children: [
          // Botón Cancelar - using base DialogFooter styling
          Expanded(
            flex: isMobile ? 1 : 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[400]!,
                    Colors.grey[500]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 24), 
                      vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12),
                    ),
                    child: Row(
                      mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                        ),
                        SizedBox(width: isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
                        Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Botón Agregar with custom disabled state logic
          Expanded(
            flex: isMobile ? 1 : 0,
            child: Opacity(
              opacity: _selectedProfesores.isEmpty ? 0.5 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1976d2),
                      Color(0xFF1565c0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedProfesores.isEmpty
                    ? []
                    : [
                        BoxShadow(
                          color: Color(0xFF1976d2).withOpacity(0.4),
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _selectedProfesores.isEmpty
                        ? null
                        : () => Navigator.of(context).pop(_selectedProfesores),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 24), 
                        vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12),
                      ),
                      child: Row(
                        mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_add_rounded,
                            color: Colors.white,
                            size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                          ),
                          SizedBox(width: isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
                          Text(
                            'Agregar${_selectedProfesores.isEmpty ? '' : ' (${_selectedProfesores.length})'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
