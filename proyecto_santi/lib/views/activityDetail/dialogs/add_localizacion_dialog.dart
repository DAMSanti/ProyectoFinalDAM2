import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'package:proyecto_santi/services/geocoding_service.dart';
import 'package:proyecto_santi/utils/icon_helper.dart';
import 'edit_localizacion_dialog.dart';
import '../widgets/locations/localizacion_widgets.dart';
import 'layouts/add_localizacion_landscape_layout.dart';
import 'layouts/add_localizacion_portrait_layout.dart';

/// Diálogo para gestionar las localizaciones de una actividad
/// Permite buscar, añadir, editar y eliminar localizaciones
class AddLocalizacionDialog extends StatefulWidget {
  final int actividadId;
  final List<Localizacion> localizacionesExistentes;
  final VoidCallback onLocalizacionAdded;

  const AddLocalizacionDialog({
    Key? key,
    required this.actividadId,
    required this.localizacionesExistentes,
    required this.onLocalizacionAdded,
  }) : super(key: key);

  @override
  AddLocalizacionDialogState createState() => AddLocalizacionDialogState();
}

class AddLocalizacionDialogState extends State<AddLocalizacionDialog> {
  final _searchController = TextEditingController();
  final _geocodingService = GeocodingService();
  
  List<GeocodingResult> _searchResults = [];
  List<Localizacion> _localizacionesActuales = [];
  Map<int, IconData> _iconosLocalizaciones = {}; // Mapa de id -> icono
  bool _isSearching = false;
  bool _hasChanges = false;
  int _nextTempId = -1; // IDs temporales para localizaciones nuevas (negativos)
  
  Timer? _debounce;

  // Iconos disponibles para localizaciones
  final List<IconData> _iconosDisponibles = [
    Icons.school,
    Icons.museum,
    Icons.park,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.store,
    Icons.stadium,
    Icons.theaters,
    Icons.beach_access,
    Icons.castle,
    Icons.church,
    Icons.landscape,
  ];

  @override
  void initState() {
    super.initState();
    
    // Copiar las localizaciones existentes e inicializar iconos por defecto
    _localizacionesActuales = List.from(widget.localizacionesExistentes);
    for (var loc in _localizacionesActuales) {
      _iconosLocalizaciones[loc.id] = loc.esPrincipal ? Icons.location_pin : Icons.location_on;
    }
    
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancelar búsqueda anterior
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Esperar 500ms después de que el usuario deje de escribir
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _searchAddress(query);
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  Future<void> _searchAddress(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _geocodingService.searchAddress(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar dirección: $e')),
        );
      }
    }
  }

  Future<void> _addLocalizacionFromSearch(GeocodingResult result) async {
    // Verificar si ya existe una localización en las mismas coordenadas
    final yaExiste = _localizacionesActuales.any((loc) =>
      (loc.latitud != null && loc.longitud != null) &&
      (loc.latitud! - result.lat).abs() < 0.001 &&
      (loc.longitud! - result.lon).abs() < 0.001
    );

    if (yaExiste) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Esta localización ya está añadida')),
        );
      }
      return;
    }

    // Crear la localización solo en memoria (con ID temporal negativo)
    final tempId = _nextTempId--;
    final orden = _localizacionesActuales.length + 1;
    final esPrincipal = _localizacionesActuales.isEmpty;
    
    final nuevaLoc = Localizacion(
      id: tempId,
      nombre: result.city ?? result.road ?? result.displayName,
      direccion: result.road,
      ciudad: result.city,
      provincia: result.state,
      codigoPostal: result.postcode,
      latitud: result.lat,
      longitud: result.lon,
      esPrincipal: esPrincipal,
    );
    
    setState(() {
      _localizacionesActuales.add(nuevaLoc);
      _iconosLocalizaciones[tempId] = Icons.location_on;
      _searchController.clear();
      _searchResults = [];
      _hasChanges = true;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Localización añadida (pendiente de guardar)')),
      );
    }
  }

  Future<void> _editLocalizacion(Localizacion loc) async {
    // Mostrar diálogo de edición
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => EditLocalizacionDialog(
        localizacion: loc,
        iconosDisponibles: _iconosDisponibles,
        iconoActual: _iconosLocalizaciones[loc.id],
        puedeSerPrincipal: !loc.esPrincipal,
      ),
    );

    if (result != null) {
      final nuevoPrincipal = result['esPrincipal'] as bool;
      final nuevoIcono = result['icono'] as IconData?;
      final nuevaDescripcion = result['descripcion'] as String?;
      final nuevoTipo = result['tipoLocalizacion'] as String?;
      String? nuevoIconoNombre;
      
      // Actualizar icono si se seleccionó uno y convertirlo a nombre string
      if (nuevoIcono != null) {
        nuevoIconoNombre = IconHelper.getIconName(nuevoIcono);
        setState(() {
          _iconosLocalizaciones[loc.id] = nuevoIcono;
        });
      }
      
      // Actualizar lista de localizaciones con el nuevo estado
      bool cambioRealizado = false;
      
      setState(() {
        _localizacionesActuales = _localizacionesActuales.map((l) {
          // Si esta localización se marca como principal, desmarcar las demás
          if (nuevoPrincipal && !loc.esPrincipal && l.esPrincipal) {
            cambioRealizado = true;
            return Localizacion(
              id: l.id,
              nombre: l.nombre,
              direccion: l.direccion,
              ciudad: l.ciudad,
              provincia: l.provincia,
              codigoPostal: l.codigoPostal,
              latitud: l.latitud,
              longitud: l.longitud,
              esPrincipal: false,
              icono: l.icono,
              descripcion: l.descripcion,
              tipoLocalizacion: l.tipoLocalizacion,
            );
          }
          
          // Actualizar la localización editada
          if (l.id == loc.id) {
            final iconoCambio = nuevoIconoNombre != null && nuevoIconoNombre != l.icono;
            final principalCambio = nuevoPrincipal != l.esPrincipal;
            final descripcionCambio = nuevaDescripcion != l.descripcion;
            final tipoCambio = nuevoTipo != l.tipoLocalizacion;
            
            if (iconoCambio || principalCambio || descripcionCambio || tipoCambio) {
              cambioRealizado = true;
              return Localizacion(
                id: l.id,
                nombre: l.nombre,
                direccion: l.direccion,
                ciudad: l.ciudad,
                provincia: l.provincia,
                codigoPostal: l.codigoPostal,
                latitud: l.latitud,
                longitud: l.longitud,
                esPrincipal: nuevoPrincipal,
                icono: nuevoIconoNombre ?? l.icono,
                descripcion: nuevaDescripcion,
                tipoLocalizacion: nuevoTipo,
              );
            }
          }
          
          return l;
        }).toList();
        
        if (cambioRealizado) {
          _hasChanges = true;
        }
      });
      
      if (cambioRealizado && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cambio pendiente de guardar')),
        );
      }
    }
  }

  Future<void> _removeLocalizacion(Localizacion loc) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar localización'),
        content: Text('¿Deseas eliminar "${loc.nombre}"?\n(Los cambios se guardarán al pulsar Guardar en la actividad)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        _localizacionesActuales.removeWhere((l) => l.id == loc.id);
        _iconosLocalizaciones.remove(loc.id);
        _hasChanges = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eliminación pendiente de guardar')),
        );
      }
    }
  }

  void _guardarYCerrar() {
    if (_hasChanges) {
      // Devolver los datos modificados al padre
      Navigator.of(context).pop({
        'localizaciones': _localizacionesActuales,
        'iconos': _iconosLocalizaciones,
        'hasChanges': true,
      });
      widget.onLocalizacionAdded(); // Notificar que hay cambios
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
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
        width: isWeb ? 750 : (isMobile ? double.infinity : 600),
        constraints: BoxConstraints(
          maxHeight: isMobileLandscape
              ? screenHeight * 0.95
              : (isMobile ? screenHeight * 0.85 : screenHeight * 0.9)),
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
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobileLandscape ? 12 : (isMobile ? 12 : 20),
                vertical: isMobileLandscape ? 10 : (isMobile ? 12 : 20),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1976d2),
                    Color(0xFF1565c0),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                  topRight: Radius.circular(isMobileLandscape ? 16 : (isMobile ? 20 : 20)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1976d2).withOpacity(0.3),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                    ),
                    child: Icon(
                      Icons.add_location_rounded,
                      color: Colors.white,
                      size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                    ),
                  ),
                  SizedBox(width: isMobileLandscape ? 8 : (isMobile ? 8 : 12)),
                  Expanded(
                    child: Text(
                      isMobile ? 'Localizaciones' : 'Gestionar Localizaciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobileLandscape ? 14 : (isMobile ? 16 : 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_hasChanges && !isMobile)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Cambios pendientes',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_hasChanges && isMobile)
                    Tooltip(
                      message: 'Cambios pendientes',
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.orange[300],
                      ),
                    ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.white, size: isMobile ? 20 : 24),
                    padding: EdgeInsets.all(isMobile ? 4 : 8),
                    constraints: BoxConstraints(),
                    onPressed: () {
                      if (_hasChanges) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('¿Salir sin guardar?'),
                            content: Text('Tienes cambios pendientes. ¿Deseas salir sin guardarlos?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: Text('Salir sin guardar'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
            
            // Content - Layout condicional
            Expanded(
              child: isMobileLandscape
                  ? AddLocalizacionLandscapeLayout(
                      isDark: isDark,
                      isMobile: isMobile,
                      searchController: _searchController,
                      isSearching: _isSearching,
                      searchResults: _searchResults,
                      localizacionesActuales: _localizacionesActuales,
                      iconosLocalizaciones: _iconosLocalizaciones,
                      onClearSearch: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                        });
                      },
                      onResultTap: _addLocalizacionFromSearch,
                      onEdit: _editLocalizacion,
                      onRemove: _removeLocalizacion,
                    )
                  : AddLocalizacionPortraitLayout(
                      isDark: isDark,
                      isMobile: isMobile,
                      searchController: _searchController,
                      isSearching: _isSearching,
                      searchResults: _searchResults,
                      localizacionesActuales: _localizacionesActuales,
                      iconosLocalizaciones: _iconosLocalizaciones,
                      onClearSearch: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                        });
                      },
                      onResultTap: _addLocalizacionFromSearch,
                      onEdit: _editLocalizacion,
                      onRemove: _removeLocalizacion,
                    ),
            ),
            
            // Actions - Footer adaptivo
            Container(
              padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 20)),
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
                mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.end,
                children: [
                  // Botón Guardar
                  Flexible(
                    child: Container(
                      constraints: isMobile ? BoxConstraints(minWidth: double.infinity) : BoxConstraints(),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1976d2),
                            Color(0xFF1565c0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                        boxShadow: [
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
                          onTap: _guardarYCerrar,
                          borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobileLandscape ? 16 : (isMobile ? 20 : 24), 
                              vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: isMobileLandscape ? 14 : (isMobile ? 18 : 20),
                                ),
                                SizedBox(width: isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
                                Text(
                                  'Guardar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobileLandscape ? 13 : (isMobile ? 15 : 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
