import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/departamento.dart';
import 'package:proyecto_santi/services/services.dart';

/// Diálogo para editar los datos básicos de una actividad
class EditActivityDialog extends StatefulWidget {
  final Actividad actividad;
  final Function(Map<String, dynamic>) onSave;

  const EditActivityDialog({
    Key? key,
    required this.actividad,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late DateTime _fechaInicio;
  late DateTime _fechaFin;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFin;
  String? _selectedProfesorId;
  int? _selectedDepartamentoId;
  bool _aprobada = false;
  
  // Variables para el folleto
  String? _folletoFileName;
  String? _folletoFilePath;
  bool _folletoChanged = false;
  
  List<Profesor> _profesores = [];
  List<Departamento> _departamentos = [];
  bool _isLoading = true;
  late final ApiService _apiService;
  late final ProfesorService _profesorService;
  late final CatalogoService _catalogoService;

  @override
  void initState() {
    super.initState();
    
    _apiService = ApiService();
    _profesorService = ProfesorService(_apiService);
    _catalogoService = CatalogoService(_apiService);
    
    // Inicializar controladores
    _nombreController = TextEditingController(text: widget.actividad.titulo);
    _descripcionController = TextEditingController(text: widget.actividad.descripcion ?? '');
    
    // Parsear fechas y horas
    _fechaInicio = DateTime.parse(widget.actividad.fini);
    _fechaFin = DateTime.parse(widget.actividad.ffin);
    
    // Parsear horas (formato HH:mm:ss o HH:mm)
    final horaIniParts = widget.actividad.hini.split(':');
    _horaInicio = TimeOfDay(
      hour: int.parse(horaIniParts[0]),
      minute: int.parse(horaIniParts[1]),
    );
    
    final horaFinParts = widget.actividad.hfin.split(':');
    _horaFin = TimeOfDay(
      hour: int.parse(horaFinParts[0]),
      minute: int.parse(horaFinParts[1]),
    );
    
    // Estado
    _aprobada = widget.actividad.estado.toLowerCase() == 'aprobada';
    
    // Cargar datos
    _loadData();
  }

  Future<void> _loadData() async {
    try {

      
      // Cargar profesores desde la API
      final profesores = await _profesorService.fetchProfesores();

      for (var p in profesores) {

      }
      
      // Cargar departamentos desde la API
      final departamentos = await _catalogoService.fetchDepartamentos();

      for (var d in departamentos) {

      }
      
      setState(() {
        _profesores = profesores;
        _departamentos = departamentos;
        
        // Seleccionar valores actuales
        if (widget.actividad.solicitante != null) {
          // Buscar el profesor por correo electrónico ya que el UUID puede no coincidir
          final profesor = _profesores.firstWhere(
            (p) => p.correo.toLowerCase() == widget.actividad.solicitante!.correo.toLowerCase(),
            orElse: () => _profesores.first,
          );
          _selectedProfesorId = profesor.uuid;


        }
        if (widget.actividad.departamento != null) {
          _selectedDepartamentoId = widget.actividad.departamento!.id;

        }
        
        _isLoading = false;
      });
      

    } catch (e, stackTrace) {
      print('[Error] Cargando datos: $e');
      print('[Error] StackTrace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _horaInicio : _horaFin,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _horaInicio = picked;
        } else {
          _horaFin = picked;
        }
      });
    }
  }

  void _handleSave() {
    // Validar campos
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }
    
    print('[DIALOG] ========== Verificando cambios en el diálogo ==========');
    
    // Verificar si hubo cambios reales antes de notificar
    bool hasChanges = false;
    
    // Comparar nombre
    print('[DIALOG] Comparando nombre: "${_nombreController.text.trim()}" vs "${widget.actividad.titulo.trim()}"');
    if (_nombreController.text.trim() != widget.actividad.titulo.trim()) {
      print('[DIALOG] CAMBIO en nombre detectado');
      hasChanges = true;
    }
    
    // Comparar descripción
    print('[DIALOG] Comparando descripción: "${_descripcionController.text.trim()}" vs "${(widget.actividad.descripcion ?? '').trim()}"');
    if (_descripcionController.text.trim() != (widget.actividad.descripcion ?? '').trim()) {
      print('[DIALOG] CAMBIO en descripción detectado');
      hasChanges = true;
    }
    
    // Comparar fechas (solo hasta segundos)
    final fechaInicioOriginal = DateTime.parse(widget.actividad.fini);
    final fechaInicioNormalizada = DateTime(_fechaInicio.year, _fechaInicio.month, _fechaInicio.day,
                                            _fechaInicio.hour, _fechaInicio.minute, _fechaInicio.second);
    final fechaOriginalNormalizada = DateTime(fechaInicioOriginal.year, fechaInicioOriginal.month, fechaInicioOriginal.day,
                                               fechaInicioOriginal.hour, fechaInicioOriginal.minute, fechaInicioOriginal.second);
    print('[DIALOG] Comparando fechaInicio: $fechaInicioNormalizada vs $fechaOriginalNormalizada');
    if (fechaInicioNormalizada != fechaOriginalNormalizada) {
      print('[DIALOG] CAMBIO en fechaInicio detectado');
      hasChanges = true;
    }
    
    final fechaFinOriginal = DateTime.parse(widget.actividad.ffin);
    final fechaFinNormalizada = DateTime(_fechaFin.year, _fechaFin.month, _fechaFin.day,
                                         _fechaFin.hour, _fechaFin.minute, _fechaFin.second);
    final fechaFinOriginalNormalizada = DateTime(fechaFinOriginal.year, fechaFinOriginal.month, fechaFinOriginal.day,
                                                  fechaFinOriginal.hour, fechaFinOriginal.minute, fechaFinOriginal.second);
    print('[DIALOG] Comparando fechaFin: $fechaFinNormalizada vs $fechaFinOriginalNormalizada');
    if (fechaFinNormalizada != fechaFinOriginalNormalizada) {
      print('[DIALOG] CAMBIO en fechaFin detectado');
      hasChanges = true;
    }
    
    // Comparar horas (normalizar a formato HH:mm)
    final hiniNueva = '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}';
    String hiniOriginal = widget.actividad.hini;
    // Si la hora original tiene formato HH:mm:ss, quitarle los segundos
    if (hiniOriginal.length > 5 && hiniOriginal.substring(5, 6) == ':') {
      hiniOriginal = hiniOriginal.substring(0, 5);
    }
    print('[DIALOG] Comparando hini: "$hiniNueva" vs "$hiniOriginal"');
    if (hiniNueva != hiniOriginal) {
      print('[DIALOG] CAMBIO en hini detectado');
      hasChanges = true;
    }
    
    final hfinNueva = '${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}';
    String hfinOriginal = widget.actividad.hfin;
    // Si la hora original tiene formato HH:mm:ss, quitarle los segundos
    if (hfinOriginal.length > 5 && hfinOriginal.substring(5, 6) == ':') {
      hfinOriginal = hfinOriginal.substring(0, 5);
    }
    print('[DIALOG] Comparando hfin: "$hfinNueva" vs "$hfinOriginal"');
    if (hfinNueva != hfinOriginal) {
      print('[DIALOG] CAMBIO en hfin detectado');
      hasChanges = true;
    }
    
    // Comparar profesor - buscar por email en lugar de UUID
    String? profesorOriginalId;
    if (widget.actividad.solicitante != null && _profesores.isNotEmpty) {
      final profesor = _profesores.firstWhere(
        (p) => p.correo.toLowerCase() == widget.actividad.solicitante!.correo.toLowerCase(),
        orElse: () => _profesores.first,
      );
      profesorOriginalId = profesor.uuid;
    }
    print('[DIALOG] Comparando profesorId: "$_selectedProfesorId" vs "$profesorOriginalId"');
    if (_selectedProfesorId != profesorOriginalId) {
      print('[DIALOG] CAMBIO en profesorId detectado');
      hasChanges = true;
    }
    
    print('[DIALOG] Comparando departamentoId: "$_selectedDepartamentoId" vs "${widget.actividad.departamento?.id}"');
    if (_selectedDepartamentoId != widget.actividad.departamento?.id) {
      print('[DIALOG] CAMBIO en departamentoId detectado');
      hasChanges = true;
    }
    
    // Comparar estado (aprobada se mapea a estado "Aprobada" o "Pendiente")
    final estadoOriginal = (widget.actividad.estado == 'Aprobada');
    print('[DIALOG] Comparando aprobada: "$_aprobada" vs "$estadoOriginal" (estado: "${widget.actividad.estado}")');
    if (_aprobada != estadoOriginal) {
      print('[DIALOG] CAMBIO en aprobada detectado');
      hasChanges = true;
    }
    
    // Comparar folleto
    if (_folletoChanged) {
      print('[DIALOG] CAMBIO en folleto detectado');
      hasChanges = true;
    }
    
    print('[DIALOG] ¿Hay cambios?: $hasChanges');
    
    // Solo notificar si hubo cambios
    if (hasChanges) {
      print('[DIALOG] Notificando cambios al padre');
      final data = {
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'fechaInicio': _fechaInicio.toIso8601String(),
        'fechaFin': _fechaFin.toIso8601String(),
        'hini': '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}:00',
        'hfin': '${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}:00',
        'profesorId': _selectedProfesorId,
        'departamentoId': _selectedDepartamentoId,
        'aprobada': _aprobada,
      };
      
      // Añadir folleto si cambió
      if (_folletoChanged && _folletoFilePath != null && _folletoFileName != null) {
        data['folletoFilePath'] = _folletoFilePath!;
        data['folletoFileName'] = _folletoFileName!;
      }
      
      widget.onSave(data);
    } else {
      print('[DIALOG] No hay cambios, no se notifica al padre');
    }
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1976d2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editar Actividad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre
                          TextField(
                            controller: _nombreController,
                            decoration: InputDecoration(
                              labelText: 'Nombre *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Descripción
                          TextField(
                            controller: _descripcionController,
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 16),
                          
                          // Fecha Inicio
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _selectDate(context, true),
                                  icon: Icon(Icons.calendar_today),
                                  label: Text(
                                    'Fecha Inicio: ${_fechaInicio.day.toString().padLeft(2, '0')}/${_fechaInicio.month.toString().padLeft(2, '0')}/${_fechaInicio.year}',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.all(12),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _selectTime(context, true),
                                  icon: Icon(Icons.access_time),
                                  label: Text(
                                    'Hora: ${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.all(12),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          
                          // Fecha Fin
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _selectDate(context, false),
                                  icon: Icon(Icons.calendar_today),
                                  label: Text(
                                    'Fecha Fin: ${_fechaFin.day.toString().padLeft(2, '0')}/${_fechaFin.month.toString().padLeft(2, '0')}/${_fechaFin.year}',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.all(12),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _selectTime(context, false),
                                  icon: Icon(Icons.access_time),
                                  label: Text(
                                    'Hora: ${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.all(12),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          
                          // Profesor Responsable
                          DropdownButtonFormField<String>(
                            value: _profesores.any((p) => p.uuid == _selectedProfesorId) 
                                ? _selectedProfesorId 
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Profesor Responsable',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text('Seleccionar profesor...'),
                              ),
                              ..._profesores.map((profesor) {
                                return DropdownMenuItem<String>(
                                  value: profesor.uuid,
                                  child: Text('${profesor.nombre} ${profesor.apellidos}'),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedProfesorId = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          
                          // Departamento
                          DropdownButtonFormField<int>(
                            value: _departamentos.any((d) => d.id == _selectedDepartamentoId) 
                                ? _selectedDepartamentoId 
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Departamento',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text('Seleccionar departamento...'),
                              ),
                              ..._departamentos.map((departamento) {
                                return DropdownMenuItem<int>(
                                  value: departamento.id,
                                  child: Text(departamento.nombre),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedDepartamentoId = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          
                          // Estado (Radio Buttons)
                          Text(
                            'Estado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: Text('Pendiente'),
                                  value: false,
                                  groupValue: _aprobada,
                                  onChanged: (value) {
                                    setState(() {
                                      _aprobada = value!;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: Text('Aprobada'),
                                  value: true,
                                  groupValue: _aprobada,
                                  onChanged: (value) {
                                    setState(() {
                                      _aprobada = value!;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
            
            // Actions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1976d2),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Guardar'),
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
