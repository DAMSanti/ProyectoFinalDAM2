import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'package:proyecto_santi/services/geocoding_service.dart';
import 'package:proyecto_santi/utils/icon_helper.dart';
import 'edit_localizacion_dialog.dart';

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
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isWeb ? 750 : double.maxFinite,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark 
              ? const Color.fromRGBO(255, 255, 255, 0.1) 
              : const Color.fromRGBO(0, 0, 0, 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
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
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_location_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gestionar Localizaciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_hasChanges)
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
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.white),
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
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de búsqueda moderno
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
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
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar y añadir dirección',
                          hintText: 'Ej: Calle Mayor 1, Torrelavega',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF1976d2),
                          ),
                          suffixIcon: _isSearching
                              ? Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976d2)),
                                    ),
                                  ),
                                )
                              : _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear_rounded, color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchResults = [];
                                        });
                                      },
                                    )
                                  : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Resultados de búsqueda
                    if (_searchResults.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.travel_explore_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Resultados de búsqueda - Haz clic para añadir',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976d2),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
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
                        child: ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _addLocalizacionFromSearch(result),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            result.displayName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                    
                    // Divisor
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFF1976d2).withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Título de localizaciones
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.list_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Localizaciones de esta actividad',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976d2),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1976d2).withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${_localizacionesActuales.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Lista de localizaciones actuales
                    Container(
                      constraints: BoxConstraints(minHeight: 200, maxHeight: 400),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark 
                            ? Colors.white.withOpacity(0.1) 
                            : Colors.black.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      child: _localizacionesActuales.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1976d2).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.location_off_rounded,
                                        size: 48,
                                        color: Color(0xFF1976d2).withOpacity(0.5),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No hay localizaciones añadidas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? Colors.white70 : Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Busca y añade direcciones usando el campo superior',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white54 : Colors.black38,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(8),
                              shrinkWrap: true,
                              itemCount: _localizacionesActuales.length,
                              itemBuilder: (context, index) {
                                final loc = _localizacionesActuales[index];
                                final icono = _iconosLocalizaciones[loc.id] ?? 
                                             (loc.esPrincipal ? Icons.location_pin : Icons.location_on);
                                
                                return Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    gradient: loc.esPrincipal 
                                        ? LinearGradient(
                                            colors: [
                                              Colors.red.withOpacity(0.15),
                                              Colors.red.withOpacity(0.08),
                                            ],
                                          )
                                        : null,
                                    color: loc.esPrincipal ? null : Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: loc.esPrincipal
                                        ? Colors.red.withOpacity(0.4)
                                        : Colors.transparent,
                                      width: loc.esPrincipal ? 2 : 1,
                                    ),
                                    boxShadow: loc.esPrincipal
                                      ? [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: loc.esPrincipal
                                                ? [Colors.red[400]!, Colors.red[600]!]
                                                : [Color(0xFF1976d2), Color(0xFF1565c0)],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            icono,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      loc.nombre,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: loc.esPrincipal ? FontWeight.bold : FontWeight.w600,
                                                        color: loc.esPrincipal 
                                                          ? Colors.red[700]
                                                          : (isDark ? Colors.white : Colors.black87),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (loc.esPrincipal)
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [Colors.red[400]!, Colors.red[600]!],
                                                        ),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.star_rounded,
                                                            size: 12,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            'PRINCIPAL',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                loc.direccionCompleta.isEmpty 
                                                    ? 'Sin dirección' 
                                                    : loc.direccionCompleta,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? Colors.white70 : Colors.black54,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFF1976d2).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.edit_rounded,
                                              size: 18,
                                              color: Color(0xFF1976d2),
                                            ),
                                            onPressed: () => _editLocalizacion(loc),
                                            tooltip: 'Editar',
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete_rounded,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            onPressed: () => _removeLocalizacion(loc),
                                            tooltip: 'Eliminar',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey[850]!.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón Guardar
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1976d2),
                          Color(0xFF1565c0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Guardar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
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
