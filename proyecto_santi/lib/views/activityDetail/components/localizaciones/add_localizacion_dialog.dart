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
            );
          }
          
          // Actualizar la localización editada
          if (l.id == loc.id) {
            final iconoCambio = nuevoIconoNombre != null && nuevoIconoNombre != l.icono;
            final principalCambio = nuevoPrincipal != l.esPrincipal;
            
            if (iconoCambio || principalCambio) {
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
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_location, color: Color(0xFF1976d2)),
          SizedBox(width: 8),
          Text('Gestionar Localizaciones'),
        ],
      ),
      content: Container(
        width: isWeb ? 700 : double.maxFinite,
        height: isWeb ? 650 : MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar y añadir dirección',
                hintText: 'Ej: Calle Mayor 1, Torrelavega',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _isSearching
                    ? Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            
            // Resultados de búsqueda (si hay)
            if (_searchResults.isNotEmpty) ...[
              Text(
                'Resultados de búsqueda - Haz clic para añadir',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.add_circle_outline, color: Color(0xFF1976d2)),
                      title: Text(
                        result.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () => _addLocalizacionFromSearch(result),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
            ],
            
            Divider(thickness: 2),
            SizedBox(height: 8),
            
            // Título de localizaciones
            Row(
              children: [
                Icon(Icons.list_alt, size: 18, color: Colors.grey[700]),
                SizedBox(width: 8),
                Text(
                  'Localizaciones de esta actividad (${_localizacionesActuales.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            // Lista de localizaciones actuales
            Expanded(
              child: _localizacionesActuales.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                          SizedBox(height: 12),
                          Text(
                            'No hay localizaciones añadidas',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _localizacionesActuales.length,
                      itemBuilder: (context, index) {
                        final loc = _localizacionesActuales[index];
                        final icono = _iconosLocalizaciones[loc.id] ?? 
                                     (loc.esPrincipal ? Icons.location_pin : Icons.location_on);
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          color: loc.esPrincipal 
                              ? Colors.red.withOpacity(0.05)
                              : null,
                          child: ListTile(
                            leading: Icon(
                              icono,
                              color: loc.esPrincipal ? Colors.red : Color(0xFF1976d2),
                              size: 28,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    loc.nombre,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: loc.esPrincipal ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (loc.esPrincipal)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'PRINCIPAL',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              loc.direccionCompleta.isEmpty 
                                  ? 'Sin dirección' 
                                  : loc.direccionCompleta,
                              style: TextStyle(fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, size: 20, color: Color(0xFF1976d2)),
                                  onPressed: () => _editLocalizacion(loc),
                                  tooltip: 'Editar',
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => _removeLocalizacion(loc),
                                  tooltip: 'Eliminar',
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
      actions: [
        ElevatedButton.icon(
          onPressed: _guardarYCerrar,
          icon: Icon(Icons.save),
          label: Text('Guardar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1976d2),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
