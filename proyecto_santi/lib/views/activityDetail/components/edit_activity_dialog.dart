import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/services/api_service.dart';

class EditActivityDialog extends StatefulWidget {
  final Actividad actividad;
  final Function(Map<String, dynamic>) onSave;

  const EditActivityDialog({
    super.key,
    required this.actividad,
    required this.onSave,
  });

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late DateTime _fechaInicio;
  late DateTime _fechaFin;
  late String _estado;
  String? _profesorResponsableUuid;
  
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _hasChanges = false;
  bool _isLoadingProfesores = true;
  List<Profesor> _profesores = [];
  
  // Variables para guardar los valores originales
  late String _originalTitulo;
  late String _originalDescripcion;
  late DateTime _originalFechaInicio;
  late DateTime _originalFechaFin;
  late String _originalEstado;
  String? _originalProfesorUuid;

  @override
  void initState() {
    super.initState();
    
    // Inicializar valores actuales
    _tituloController = TextEditingController(text: widget.actividad.titulo);
    _descripcionController = TextEditingController(text: widget.actividad.descripcion ?? '');
    _fechaInicio = DateTime.parse(widget.actividad.fini);
    _fechaFin = DateTime.parse(widget.actividad.ffin);
    _estado = widget.actividad.estado;
    _profesorResponsableUuid = widget.actividad.profesorResponsableUuid;
    
    // Guardar valores originales
    _originalTitulo = widget.actividad.titulo;
    _originalDescripcion = widget.actividad.descripcion ?? '';
    _originalFechaInicio = DateTime.parse(widget.actividad.fini);
    _originalFechaFin = DateTime.parse(widget.actividad.ffin);
    _originalEstado = widget.actividad.estado;
    _originalProfesorUuid = widget.actividad.profesorResponsableUuid;

    // Detectar cambios
    _tituloController.addListener(_checkForChanges);
    _descripcionController.addListener(_checkForChanges);
    
    // Cargar profesores
    _loadProfesores();
  }
  
  Future<void> _loadProfesores() async {
    try {
      print('[EditActivityDialog] Iniciando carga de profesores...');
      final profesores = await _apiService.fetchProfesores();
      print('[EditActivityDialog] Profesores recibidos de la API: ${profesores.length}');
      
      if (profesores.isEmpty) {
        print('[EditActivityDialog] ADVERTENCIA: No se recibieron profesores de la API');
      }
      
      // Eliminar duplicados basados en UUID
      final Map<String, Profesor> profesoresMap = {};
      for (var profesor in profesores) {
        print('[EditActivityDialog] Procesando profesor: ${profesor.nombre} ${profesor.apellidos} - UUID: ${profesor.uuid}');
        if (!profesoresMap.containsKey(profesor.uuid)) {
          profesoresMap[profesor.uuid] = profesor;
        } else {
          print('[EditActivityDialog] Duplicado encontrado: ${profesor.uuid}');
        }
      }
      
      print('[EditActivityDialog] Total profesores únicos: ${profesoresMap.length}');
      
      setState(() {
        _profesores = profesoresMap.values.toList();
        _isLoadingProfesores = false;
      });
      
      print('[EditActivityDialog] Estado actualizado - Profesores en lista: ${_profesores.length}');
      print('[EditActivityDialog] Profesor responsable actual: $_profesorResponsableUuid');
      
      // Verificar si el profesor responsable actual existe en la lista
      if (_profesorResponsableUuid != null) {
        final existe = _profesores.any((p) => p.uuid == _profesorResponsableUuid);
        print('[EditActivityDialog] ¿Profesor responsable existe en lista? $existe');
      }
      
    } catch (e, stackTrace) {
      print('[EditActivityDialog] Error cargando profesores: $e');
      print('[EditActivityDialog] StackTrace: $stackTrace');
      setState(() {
        _profesores = [];
        _isLoadingProfesores = false;
      });
    }
  }

  void _checkForChanges() {
    final hasChanges = 
        _tituloController.text != _originalTitulo ||
        _descripcionController.text != _originalDescripcion ||
        _fechaInicio != _originalFechaInicio ||
        _fechaFin != _originalFechaFin ||
        _estado != _originalEstado ||
        _profesorResponsableUuid != _originalProfesorUuid;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }
  
  void _revertChanges() {
    setState(() {
      _tituloController.text = _originalTitulo;
      _descripcionController.text = _originalDescripcion;
      _fechaInicio = _originalFechaInicio;
      _fechaFin = _originalFechaFin;
      _estado = _originalEstado;
      _profesorResponsableUuid = _originalProfesorUuid;
      _hasChanges = false;
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _fechaInicio = picked;
          // Si la fecha de inicio es posterior a la de fin, ajustar
          if (_fechaInicio.isAfter(_fechaFin)) {
            _fechaFin = _fechaInicio;
          }
        } else {
          _fechaFin = picked;
          // Si la fecha de fin es anterior a la de inicio, ajustar
          if (_fechaFin.isBefore(_fechaInicio)) {
            _fechaInicio = _fechaFin;
          }
        }
        _checkForChanges();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: Theme.of(context).primaryColor),
          SizedBox(width: 8),
          Text('Editar Actividad'),
        ],
      ),
      contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
      content: Container(
        width: screenWidth * 0.8,
        height: screenHeight * 0.7,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Título
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es obligatorio';
                  }
                  return null;
                },
                maxLines: 1,
              ),
              SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              SizedBox(height: 16),

              // Fecha de inicio
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de inicio',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    dateFormat.format(_fechaInicio),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Fecha de fin
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de fin',
                    prefixIcon: Icon(Icons.event),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    dateFormat.format(_fechaFin),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Estado
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                  DropdownMenuItem(value: 'Aprobada', child: Text('Aprobada')),
                  DropdownMenuItem(value: 'Rechazada', child: Text('Rechazada')),
                  DropdownMenuItem(value: 'Finalizada', child: Text('Finalizada')),
                  DropdownMenuItem(value: 'Cancelada', child: Text('Cancelada')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _estado = value;
                      _checkForChanges();
                    });
                  }
                },
              ),
              SizedBox(height: 16),

              // Profesor Responsable
              _isLoadingProfesores
                  ? Center(child: CircularProgressIndicator())
                  : Builder(
                      builder: (context) {
                        print('[EditActivityDialog BUILD] Construyendo dropdown con ${_profesores.length} profesores');
                        print('[EditActivityDialog BUILD] isLoading: $_isLoadingProfesores');
                        
                        final items = [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Sin asignar', style: TextStyle(color: Colors.grey)),
                          ),
                          ..._profesores.map((profesor) {
                            print('[EditActivityDialog BUILD] Añadiendo item: ${profesor.nombre} ${profesor.apellidos}');
                            return DropdownMenuItem<String?>(
                              value: profesor.uuid,
                              child: Text('${profesor.nombre} ${profesor.apellidos}'),
                            );
                          }).toList(),
                        ];
                        
                        print('[EditActivityDialog BUILD] Total items en dropdown: ${items.length}');
                        
                        return DropdownButtonFormField<String?>(
                          value: _profesorResponsableUuid != null && 
                                 _profesores.any((p) => p.uuid == _profesorResponsableUuid)
                              ? _profesorResponsableUuid
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Profesor Responsable',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          hint: Text('Seleccione un profesor'),
                          items: items,
                          onChanged: (value) {
                            print('[EditActivityDialog] Profesor seleccionado: $value');
                            setState(() {
                              _profesorResponsableUuid = value;
                              _checkForChanges();
                            });
                          },
                        );
                      },
                    ),
              SizedBox(height: 16),

              // Solicitante (solo lectura)
              if (widget.actividad.solicitante != null)
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Solicitante',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '${widget.actividad.solicitante!.nombre} ${widget.actividad.solicitante!.apellidos}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
            ],
          ), // Cierre del Column
        ), // Cierre del Form
      ), // Cierre del SingleChildScrollView
    ), // Cierre del Container
    actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        if (_hasChanges)
          TextButton(
            onPressed: _revertChanges,
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.undo, size: 18),
                SizedBox(width: 4),
                Text('Revertir'),
              ],
            ),
          ),
        ElevatedButton(
          onPressed: _hasChanges
              ? () {
                  if (_formKey.currentState!.validate()) {
                    // Preparar los datos para enviar
                    final Map<String, dynamic> updatedData = {
                      'nombre': _tituloController.text,
                      'descripcion': _descripcionController.text,
                      'fechaInicio': _fechaInicio.toIso8601String(),
                      'fechaFin': _fechaFin.toIso8601String(),
                      'aprobada': _estado == 'Aprobada',
                      'profesorResponsableUuid': _profesorResponsableUuid,
                    };
                    
                    widget.onSave(updatedData);
                    Navigator.of(context).pop();
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
