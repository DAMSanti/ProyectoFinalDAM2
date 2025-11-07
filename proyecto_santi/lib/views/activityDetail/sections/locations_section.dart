import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/localizacion.dart';
import 'package:proyecto_santi/services/localizacion_service.dart';
import 'package:proyecto_santi/widgets/localizaciones_map_widget.dart';
import 'package:proyecto_santi/tema/tema.dart';
import '../dialogs/add_localizacion_dialog.dart';
import '../dialogs/edit_localizacion_dialog.dart';

/// Widget que maneja toda la secci�n de localizaciones de una actividad.
/// 
/// Responsabilidades:
/// - Mostrar mapa interactivo con todas las localizaciones
/// - Lista de localizaciones con cards detalladas
/// - Permitir agregar, editar y eliminar localizaciones
/// - Cargar �conos din�micamente seg�n tipo de localizaci�n
class ActivityLocationsSection extends StatefulWidget {
  final int actividadId;
  final bool isAdminOrSolicitante;
  final LocalizacionService localizacionService;
  final Function(Map<String, dynamic>)? onDataChanged;

  const ActivityLocationsSection({
    super.key,
    required this.actividadId,
    required this.isAdminOrSolicitante,
    required this.localizacionService,
    this.onDataChanged,
  });

  @override
  State<ActivityLocationsSection> createState() => _ActivityLocationsSectionState();
}

class _ActivityLocationsSectionState extends State<ActivityLocationsSection> {
  List<Localizacion> _localizaciones = [];
  Map<int, IconData> _iconosLocalizaciones = {};
  bool _loadingLocalizaciones = false;

  @override
  void initState() {
    super.initState();
    _loadLocalizaciones();
  }

  Future<void> _loadLocalizaciones() async {
    if (widget.actividadId == null) return;

    setState(() {
      _loadingLocalizaciones = true;
    });

    try {
      final localizacionesData = await widget.localizacionService.fetchLocalizaciones(
        widget.actividadId,
      );

      // Mapear a objetos Localizacion
      final localizaciones = localizacionesData
          .map((data) => Localizacion.fromJson(data))
          .toList();

      // Cargar �conos para cada localizaci�n
      final iconos = <int, IconData>{};
      for (var loc in localizaciones) {
        if (loc.icono != null) {
          final iconData = _getIconFromString(loc.icono!);
          if (iconData != null) {
            iconos[loc.id] = iconData;
          }
        }
      }

      if (mounted) {
        setState(() {
          _localizaciones = localizaciones;
          _iconosLocalizaciones = iconos;
          _loadingLocalizaciones = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingLocalizaciones = false;
        });
        SnackBarHelper.showError(context, 'Error al cargar localizaciones: $e');
      }
    }
  }

  IconData? _getIconFromString(String iconName) {
    // Mapeo b�sico de nombres a �conos
    final iconMap = <String, IconData>{
      'place': Icons.place,
      'restaurant': Icons.restaurant,
      'hotel': Icons.hotel,
      'museum': Icons.museum,
      'park': Icons.park,
      'school': Icons.school,
      'stadium': Icons.stadium,
      'theater': Icons.theater_comedy,
      'shopping': Icons.shopping_cart,
      'hospital': Icons.local_hospital,
      'airport': Icons.flight,
      'train': Icons.train,
      'bus': Icons.directions_bus,
      'church': Icons.church,
      'castle': Icons.castle,
      'beach': Icons.beach_access,
      'mountain': Icons.terrain,
      'forest': Icons.forest,
      'city': Icons.location_city,
      'sports': Icons.sports_soccer,
    };

    return iconMap[iconName.toLowerCase()] ?? Icons.place;
  }

  void _notifyChanges() {
    if (widget.onDataChanged != null) {
      widget.onDataChanged!({
        'localizaciones_changed': true,
        'localizaciones': _localizaciones,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildLocalizacionContainer(context, constraints);
      },
    );
  }

  Widget _buildLocalizacionContainer(BuildContext context, BoxConstraints constraints) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final isMobile = constraints.maxWidth < 600;
    
    return Container(
      constraints: BoxConstraints(minHeight: 500),
      padding: EdgeInsets.all(20),
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
                Color.fromRGBO(187, 222, 251, 0.85),
                Color.fromRGBO(144, 202, 249, 0.75),
              ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
            ? const Color.fromRGBO(255, 255, 255, 0.1) 
            : const Color.fromRGBO(0, 0, 0, 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? const Color.fromRGBO(0, 0, 0, 0.4) 
              : const Color.fromRGBO(0, 0, 0, 0.15),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(25, 118, 210, 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF1976d2),
                      size: isWeb ? 18 : 20.0,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Localizaciones',
                    style: TextStyle(
                      fontSize: isWeb ? 14 : 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976d2),
                    ),
                  ),
                  if (_localizaciones.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(left: 12),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1976d2).withValues(alpha: 0.8),
                            Color(0xFF1565c0).withValues(alpha: 0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF1976d2).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${_localizaciones.length}',
                        style: TextStyle(
                          fontSize: isWeb ? 12 : 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.isAdminOrSolicitante)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1976d2).withValues(alpha: 0.8),
                        Color(0xFF1565c0).withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1976d2).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _loadingLocalizaciones ? null : () {
                        _showAddLocalizacionDialog(context);
                      },
                      child: Tooltip(
                        message: 'A�adir localizaci�n',
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 10 : 12),
                          child: isMobile
                              ? Icon(
                                  Icons.add_location_rounded,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_location_rounded,
                                      color: Colors.white,
                                      size: isWeb ? 18 : 20.0,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'A�adir',
                                      style: TextStyle(
                                        fontSize: isWeb ? 13 : 15.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
          SizedBox(height: 16),
          
          // Loading state
          if (_loadingLocalizaciones)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          // Mapa interactivo
          else ...[
            Container(
              height: 600,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              clipBehavior: Clip.antiAlias,
              child: LocalizacionesMapWidget(
                localizaciones: _localizaciones,
                iconosLocalizaciones: _iconosLocalizaciones,
                onLocalizacionTapped: (localizacion) {
                  // Abrir diálogo de edición si es administrador o solicitante
                  if (widget.isAdminOrSolicitante) {
                    _showEditLocalizacionDialog(context, localizacion);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddLocalizacionDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddLocalizacionDialog(
          actividadId: widget.actividadId,
          localizacionesExistentes: _localizaciones,
          onLocalizacionAdded: () {
            // Este callback se llama desde el diálogo cuando hay cambios
          },
        );
      },
    );

    // El diálogo devuelve las localizaciones modificadas, iconos y un flag de cambios
    if (result != null && result['hasChanges'] == true) {
      final localizacionesModificadas = result['localizaciones'] as List<Localizacion>?;
      final iconosModificados = result['iconos'] as Map<int, IconData>?;
      
      if (localizacionesModificadas != null) {
        setState(() {
          _localizaciones = localizacionesModificadas;
          if (iconosModificados != null) {
            _iconosLocalizaciones = iconosModificados;
          }
        });
        
        // Notificar cambios al padre para activar botón guardar
        _notifyChanges();
        
        if (mounted) {
          SnackBarHelper.showSuccess(context, 'Localizaciones modificadas (pendientes de guardar)');
        }
      }
    }
  }

  void _showEditLocalizacionDialog(BuildContext context, Localizacion localizacion) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return EditLocalizacionDialog(
          localizacion: localizacion,
          iconosDisponibles: const [
            Icons.location_on,
            Icons.place,
            Icons.pin_drop,
            Icons.map,
            Icons.hotel,
            Icons.restaurant,
            Icons.local_activity,
          ],
          iconoActual: _iconosLocalizaciones[localizacion.id],
          puedeSerPrincipal: true,
        );
      },
    );

    if (result != null && result['success'] == true) {
      await _loadLocalizaciones();
      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Localizaci�n actualizada correctamente');
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Localizacion localizacion) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.estadoPendiente),
              SizedBox(width: 12),
              Text('Confirmar eliminación'),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar la localización "${localizacion.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.estadoRechazado,
                foregroundColor: Colors.white,
              ),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await widget.localizacionService.removeLocalizacion(widget.actividadId, localizacion.id);
        await _loadLocalizaciones();
        _notifyChanges();
        
        if (mounted) {
          SnackBarHelper.showSuccess(context, 'Localizaci�n eliminada correctamente');
        }
      } catch (e) {
        if (mounted) {
          SnackBarHelper.showError(context, 'Error al eliminar localizaci�n: $e');
        }
      }
    }
  }

  /// Recargar localizaciones desde el exterior
  Future<void> reload() async {
    await _loadLocalizaciones();
  }

  /// Obtener las localizaciones actuales
  List<Localizacion> getLocalizaciones() {
    return List.from(_localizaciones);
  }
}
