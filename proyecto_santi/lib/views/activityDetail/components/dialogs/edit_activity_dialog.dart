import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/profesor.dart';
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
  String _estadoActividad = 'Pendiente'; // Puede ser: Pendiente, Aprobada, Cancelada
  String _tipoActividad = 'Complementaria'; // Puede ser: Complementaria, Extraescolar
  
  // Variables para el folleto
  String? _folletoFileName;
  String? _folletoFilePath;
  bool _folletoChanged = false;
  
  List<Profesor> _profesores = [];
  bool _isLoading = true;
  late final ApiService _apiService;
  late final ProfesorService _profesorService;

  @override
  void initState() {
    super.initState();
    
    _apiService = ApiService();
    _profesorService = ProfesorService(_apiService);
    
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
    
    // Estado - Normalizar a uno de los tres valores permitidos
    final estadoActual = widget.actividad.estado.toLowerCase();
    if (estadoActual == 'aprobada') {
      _estadoActividad = 'Aprobada';
    } else if (estadoActual == 'cancelada') {
      _estadoActividad = 'Cancelada';
    } else {
      _estadoActividad = 'Pendiente';
    }
    
    // Tipo de actividad - Leer desde el modelo (normalizar)
    final tipoActual = widget.actividad.tipo.trim();
    if (tipoActual.toLowerCase() == 'extraescolar') {
      _tipoActividad = 'Extraescolar';
    } else if (tipoActual.toLowerCase() == 'complementaria') {
      _tipoActividad = 'Complementaria';
    } else {
      // Si no coincide con ninguno, usar Complementaria por defecto
      _tipoActividad = 'Complementaria';
    }
    
    print('[DEBUG] Tipo actividad cargado: "${widget.actividad.tipo}" -> $_tipoActividad');
    
    // Inicializar profesor responsable
    if (widget.actividad.responsable != null) {
      _selectedProfesorId = widget.actividad.responsable!.uuid;
      print('[DEBUG] Profesor seleccionado: ${widget.actividad.responsable!.nombre} (${_selectedProfesorId})');
    } else {
      print('[DEBUG] No hay profesor responsable en la actividad');
    }
    
    // Cargar datos
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Cargar profesores desde la API
      final profesores = await _profesorService.fetchProfesores();
      
      setState(() {
        _profesores = profesores;
        
        // Validar que el profesor seleccionado existe en la lista
        if (_selectedProfesorId != null) {
          final profesorExists = _profesores.any((p) => p.uuid == _selectedProfesorId);
          if (!profesorExists) {
            print('[Warning] Profesor con UUID $_selectedProfesorId no encontrado en la lista');
            _selectedProfesorId = null;
          }
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
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar datos: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        } catch (e) {
          print('[Error] No se pudo mostrar SnackBar: $e');
        }
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
    
    // Ya no comparamos departamento, ahora usamos responsable
    
    // Comparar estado
    print('[DIALOG] Comparando estado: "$_estadoActividad" vs "${widget.actividad.estado}"');
    if (_estadoActividad != widget.actividad.estado) {
      print('[DIALOG] CAMBIO en estado detectado');
      hasChanges = true;
    }
    
    // Comparar tipo de actividad
    // TODO: Cuando se agregue el campo al modelo, comparar aquí
    print('[DIALOG] Tipo de actividad: "$_tipoActividad" (nuevo campo, siempre se considera cambio)');
    hasChanges = true; // Por ahora siempre marcamos cambio hasta que el backend soporte este campo
    
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
        'estado': _estadoActividad, // Aprobada, Pendiente o Cancelada
        'tipoActividad': _tipoActividad, // Complementaria o Extraescolar
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

  // Layout especial para mobile landscape (2 columnas)
  Widget _buildLandscapeMobileLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // COLUMNA IZQUIERDA - Información básica y fechas
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información Básica
              _buildSectionTitle('Información Básica', Icons.info_rounded, true, true),
              SizedBox(height: 8),
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre',
                hint: 'Nombre de la actividad',
                icon: Icons.title_rounded,
                isRequired: true,
                isMobile: true,
                isMobileLandscape: true,
              ),
              SizedBox(height: 8),
              _buildTextField(
                controller: _descripcionController,
                label: 'Descripción',
                hint: 'Descripción breve',
                icon: Icons.description_rounded,
                maxLines: 2,
                isMobile: true,
                isMobileLandscape: true,
              ),
              SizedBox(height: 12),
              
              // Fechas y Horas
              _buildSectionTitle('Fechas y Horarios', Icons.event_rounded, true, true),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeButton(
                      label: 'Inicio',
                      icon: Icons.calendar_today_rounded,
                      value: '${_fechaInicio.day.toString().padLeft(2, '0')}/${_fechaInicio.month.toString().padLeft(2, '0')}',
                      onTap: () => _selectDate(context, true),
                      isMobile: true,
                      isMobileLandscape: true,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildDateTimeButton(
                      label: 'Hora',
                      icon: Icons.access_time_rounded,
                      value: '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}',
                      onTap: () => _selectTime(context, true),
                      isMobile: true,
                      isMobileLandscape: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeButton(
                      label: 'Fin',
                      icon: Icons.calendar_today_rounded,
                      value: '${_fechaFin.day.toString().padLeft(2, '0')}/${_fechaFin.month.toString().padLeft(2, '0')}',
                      onTap: () => _selectDate(context, false),
                      isMobile: true,
                      isMobileLandscape: true,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildDateTimeButton(
                      label: 'Hora',
                      icon: Icons.access_time_rounded,
                      value: '${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}',
                      onTap: () => _selectTime(context, false),
                      isMobile: true,
                      isMobileLandscape: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(width: 12),
        
        // COLUMNA DERECHA - Responsable, estado y tipo
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsable
              _buildSectionTitle('Responsable', Icons.people_rounded, true, true),
              SizedBox(height: 8),
              _buildDropdown<String>(
                value: _profesores.any((p) => p.uuid == _selectedProfesorId) 
                    ? _selectedProfesorId 
                    : null,
                label: 'Profesor',
                icon: Icons.person_rounded,
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('Seleccionar...', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ),
                  ..._profesores.map((profesor) {
                    return DropdownMenuItem<String>(
                      value: profesor.uuid,
                      child: Text(
                        '${profesor.nombre} ${profesor.apellidos}',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedProfesorId = value;
                  });
                },
                isMobile: true,
                isMobileLandscape: true,
              ),
              SizedBox(height: 12),
              
              // Estado
              _buildSectionTitle('Estado', Icons.check_circle_rounded, true, true),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioOption(
                      value: 'Pendiente',
                      groupValue: _estadoActividad,
                      label: 'Pend.',
                      icon: Icons.schedule_rounded,
                      color: Colors.orange,
                      onChanged: (value) {
                        setState(() {
                          _estadoActividad = value!;
                        });
                      },
                      isMobile: true,
                      isMobileLandscape: true,
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: _buildRadioOption(
                      value: 'Aprobada',
                      groupValue: _estadoActividad,
                      label: 'Aprob.',
                      icon: Icons.check_circle_rounded,
                      color: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          _estadoActividad = value!;
                        });
                      },
                      isMobile: true,
                      isMobileLandscape: true,
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: _buildRadioOption(
                      value: 'Cancelada',
                      groupValue: _estadoActividad,
                      label: 'Cancel.',
                      icon: Icons.cancel_rounded,
                      color: Colors.red,
                      onChanged: (value) {
                        setState(() {
                          _estadoActividad = value!;
                        });
                      },
                      isMobile: true,
                      isMobileLandscape: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              
              // Tipo
              _buildSectionTitle('Tipo', Icons.category_rounded, true, true),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioOption(
                      value: 'Complementaria',
                      groupValue: _tipoActividad,
                      label: 'Compl.',
                      icon: Icons.school_rounded,
                      color: Color(0xFF1976d2),
                      onChanged: (value) {
                        setState(() {
                          _tipoActividad = value!;
                        });
                      },
                      isMobile: true,
                      isMobileLandscape: true,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildRadioOption(
                      value: 'Extraescolar',
                      groupValue: _tipoActividad,
                      label: 'Extra.',
                      icon: Icons.sports_soccer_rounded,
                      color: Colors.purple,
                      onChanged: (value) {
                        setState(() {
                          _tipoActividad = value!;
                        });
                      },
                      isMobile: true,
                      isMobileLandscape: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final isMobile = screenWidth < 600;
    // Considerar landscape mobile si:
    // 1. Es mobile normal (< 600px) en landscape, O
    // 2. Está en landscape con altura pequeña (< 500px) - para tablets pequeños en landscape
    final isMobileLandscape = (isMobile && !isPortrait) || (!isPortrait && screenHeight < 500);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: isMobileLandscape
          ? EdgeInsets.symmetric(horizontal: 20, vertical: 16)
          : (isMobile 
              ? EdgeInsets.symmetric(horizontal: 16, vertical: 24)
              : EdgeInsets.symmetric(horizontal: 40, vertical: 24)),
      child: Container(
        width: isMobile ? double.infinity : 650,
        constraints: BoxConstraints(
          maxHeight: isMobileLandscape
              ? screenHeight * 0.95
              : (isMobile 
                  ? screenHeight * 0.92 
                  : screenHeight * 0.9)
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark 
              ? const Color.fromRGBO(255, 255, 255, 0.1) 
              : const Color.fromRGBO(0, 0, 0, 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                ? const Color.fromRGBO(0, 0, 0, 0.5) 
                : const Color.fromRGBO(0, 0, 0, 0.2),
              offset: const Offset(0, 8),
              blurRadius: 24.0,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header moderno
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 24), 
                vertical: isMobileLandscape ? 10 : (isMobile ? 14 : 20)
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1976d2).withOpacity(0.9),
                    Color(0xFF1565c0).withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
                  topRight: Radius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 20)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1976d2).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
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
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                    ),
                  ),
                  SizedBox(width: isMobileLandscape ? 10 : (isMobile ? 12 : 16)),
                  Expanded(
                    child: Text(
                      'Editar Actividad',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobileLandscape ? 16 : (isMobile ? 18 : 22),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.white),
                      iconSize: isMobileLandscape ? 18 : (isMobile ? 20 : 24),
                      padding: EdgeInsets.all(isMobileLandscape ? 4 : (isMobile ? 6 : 8)),
                      constraints: BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Cerrar',
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976d2)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando datos...',
                            style: TextStyle(
                              color: Color(0xFF1976d2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isMobileLandscape ? 12 : (isMobile ? 16 : 24)),
                      child: isMobileLandscape 
                          ? _buildLandscapeMobileLayout()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nombre
                                _buildSectionTitle('Información Básica', Icons.info_rounded, isMobile, isMobileLandscape),
                                SizedBox(height: isMobile ? 10 : 12),
                                _buildTextField(
                                  controller: _nombreController,
                                  label: 'Nombre de la actividad',
                                  hint: 'Ej: Visita al Museo del Prado',
                                  icon: Icons.title_rounded,
                                  isRequired: true,
                                  isMobile: isMobile,
                                  isMobileLandscape: isMobileLandscape,
                                ),
                                SizedBox(height: isMobile ? 12 : 16),
                                
                                // Descripción
                                _buildTextField(
                                  controller: _descripcionController,
                                  label: 'Descripción',
                                  hint: 'Describe brevemente la actividad...',
                                  icon: Icons.description_rounded,
                                  maxLines: 3,
                                  isMobile: isMobile,
                                  isMobileLandscape: isMobileLandscape,
                                ),
                                SizedBox(height: isMobile ? 16 : 24),
                                
                                // Fechas y Horas
                                _buildSectionTitle('Fechas y Horarios', Icons.event_rounded, isMobile, isMobileLandscape),
                                SizedBox(height: isMobile ? 10 : 12),
                                if (isMobile) ...[
                                  // Layout vertical para móviles portrait
                                  _buildDateTimeButton(
                                    label: 'Fecha Inicio',
                                    icon: Icons.calendar_today_rounded,
                                    value: '${_fechaInicio.day.toString().padLeft(2, '0')}/${_fechaInicio.month.toString().padLeft(2, '0')}/${_fechaInicio.year}',
                                    onTap: () => _selectDate(context, true),
                                    isMobile: isMobile,
                                    isMobileLandscape: isMobileLandscape,
                                  ),
                                  SizedBox(height: 10),
                                  _buildDateTimeButton(
                                    label: 'Hora Inicio',
                                    icon: Icons.access_time_rounded,
                                    value: '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}',
                                    onTap: () => _selectTime(context, true),
                                    isMobile: isMobile,
                                    isMobileLandscape: isMobileLandscape,
                                  ),
                                  SizedBox(height: 10),
                                  _buildDateTimeButton(
                                    label: 'Fecha Fin',
                                    icon: Icons.calendar_today_rounded,
                                    value: '${_fechaFin.day.toString().padLeft(2, '0')}/${_fechaFin.month.toString().padLeft(2, '0')}/${_fechaFin.year}',
                                    onTap: () => _selectDate(context, false),
                                    isMobile: isMobile,
                                    isMobileLandscape: isMobileLandscape,
                                  ),
                                  SizedBox(height: 10),
                                  _buildDateTimeButton(
                                    label: 'Hora Fin',
                                    icon: Icons.access_time_rounded,
                                    value: '${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}',
                                    onTap: () => _selectTime(context, false),
                                    isMobile: isMobile,
                                    isMobileLandscape: isMobileLandscape,
                                  ),
                                ] else ...[
                            // Layout horizontal para desktop
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateTimeButton(
                                    label: 'Fecha Inicio',
                                    icon: Icons.calendar_today_rounded,
                                    value: '${_fechaInicio.day.toString().padLeft(2, '0')}/${_fechaInicio.month.toString().padLeft(2, '0')}/${_fechaInicio.year}',
                                    onTap: () => _selectDate(context, true),
                                    isMobile: isMobile,
                                    isMobileLandscape: isMobileLandscape,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildDateTimeButton(
                                    label: 'Hora Inicio',
                                    icon: Icons.access_time_rounded,
                                    value: '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}',
                                    onTap: () => _selectTime(context, true),
                                    isMobile: isMobile,
                                    isMobileLandscape: isMobileLandscape,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateTimeButton(
                                    label: 'Fecha Fin',
                                    icon: Icons.calendar_today_rounded,
                                    value: '${_fechaFin.day.toString().padLeft(2, '0')}/${_fechaFin.month.toString().padLeft(2, '0')}/${_fechaFin.year}',
                                    onTap: () => _selectDate(context, false),
                                    isMobile: isMobile,
                                    isMobileLandscape: isMobileLandscape,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildDateTimeButton(
                                    label: 'Hora Fin',
                                    icon: Icons.access_time_rounded,
                                    value: '${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}',
                                    onTap: () => _selectTime(context, false),
                                    isMobile: isMobile,
                                    isMobileLandscape: isMobileLandscape,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: isMobileLandscape ? 12 : (isMobile ? 16 : 24)),
                          
                          // Responsables
                          _buildSectionTitle('Responsables', Icons.people_rounded, isMobile, isMobileLandscape),
                          SizedBox(height: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                          _buildDropdown<String>(
                            value: _profesores.any((p) => p.uuid == _selectedProfesorId) 
                                ? _selectedProfesorId 
                                : null,
                            label: 'Profesor Responsable',
                            icon: Icons.person_rounded,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text('Seleccionar profesor...', style: TextStyle(color: Colors.grey[600])),
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
                            isMobile: isMobile,
                            isMobileLandscape: isMobileLandscape,
                          ),
                          SizedBox(height: isMobileLandscape ? 12 : (isMobile ? 16 : 24)),
                          
                          // Estado de la Actividad
                          _buildSectionTitle('Estado y Tipo', Icons.check_circle_rounded, isMobile, isMobileLandscape),
                          SizedBox(height: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                          Container(
                            padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 16)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                              border: Border.all(
                                color: Color(0xFF1976d2).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estado de la Actividad',
                                  style: TextStyle(
                                    fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976d2),
                                  ),
                                ),
                                SizedBox(height: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildRadioOption(
                                        value: 'Pendiente',
                                        groupValue: _estadoActividad,
                                        label: 'Pendiente',
                                        icon: Icons.schedule_rounded,
                                        color: Colors.orange,
                                        onChanged: (value) {
                                          setState(() {
                                            _estadoActividad = value!;
                                          });
                                        },
                                        isMobile: isMobile,
                                        isMobileLandscape: isMobileLandscape,
                                      ),
                                    ),
                                    SizedBox(width: isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
                                    Expanded(
                                      child: _buildRadioOption(
                                        value: 'Aprobada',
                                        groupValue: _estadoActividad,
                                        label: 'Aprobada',
                                        icon: Icons.check_circle_rounded,
                                        color: Colors.green,
                                        onChanged: (value) {
                                          setState(() {
                                            _estadoActividad = value!;
                                          });
                                        },
                                        isMobile: isMobile,
                                        isMobileLandscape: isMobileLandscape,
                                      ),
                                    ),
                                    SizedBox(width: isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
                                    Expanded(
                                      child: _buildRadioOption(
                                        value: 'Cancelada',
                                        groupValue: _estadoActividad,
                                        label: 'Cancelada',
                                        icon: Icons.cancel_rounded,
                                        color: Colors.red,
                                        onChanged: (value) {
                                          setState(() {
                                            _estadoActividad = value!;
                                          });
                                        },
                                        isMobile: isMobile,
                                        isMobileLandscape: isMobileLandscape,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isMobileLandscape ? 10 : (isMobile ? 12 : 16)),
                          
                          // Tipo de Actividad
                          Container(
                            padding: EdgeInsets.all(isMobileLandscape ? 10 : (isMobile ? 12 : 16)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                              border: Border.all(
                                color: Color(0xFF1976d2).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tipo de Actividad',
                                  style: TextStyle(
                                    fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14),
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976d2),
                                  ),
                                ),
                                SizedBox(height: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildRadioOption(
                                        value: 'Complementaria',
                                        groupValue: _tipoActividad,
                                        label: 'Complementaria',
                                        icon: Icons.school_rounded,
                                        color: Color(0xFF1976d2),
                                        onChanged: (value) {
                                          setState(() {
                                            _tipoActividad = value!;
                                          });
                                        },
                                        isMobile: isMobile,
                                        isMobileLandscape: isMobileLandscape,
                                      ),
                                    ),
                                    SizedBox(width: isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
                                    Expanded(
                                      child: _buildRadioOption(
                                        value: 'Extraescolar',
                                        groupValue: _tipoActividad,
                                        label: 'Extraescolar',
                                        icon: Icons.sports_soccer_rounded,
                                        color: Colors.purple,
                                        onChanged: (value) {
                                          setState(() {
                                            _tipoActividad = value!;
                                          });
                                        },
                                        isMobile: isMobile,
                                        isMobileLandscape: isMobileLandscape,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            
            // Actions
            Container(
              padding: EdgeInsets.all(isMobileLandscape ? 12 : (isMobile ? 16 : 24)),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey[850]!.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 16)),
                  bottomRight: Radius.circular(isMobileLandscape ? 12 : (isMobile ? 16 : 16)),
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
                  // Botón Cancelar
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
                        borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            offset: Offset(0, isMobileLandscape ? 2 : (isMobile ? 2 : 4)),
                            blurRadius: isMobileLandscape ? 3 : (isMobile ? 4 : 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 24), 
                              vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                                ),
                                SizedBox(width: isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
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
                  SizedBox(width: isMobileLandscape ? 6 : (isMobile ? 8 : 12)),
                  // Botón Guardar
                  Expanded(
                    flex: isMobile ? 1 : 0,
                    child: Container(
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
                            offset: Offset(0, isMobileLandscape ? 2 : (isMobile ? 2 : 4)),
                            blurRadius: isMobileLandscape ? 3 : (isMobile ? 4 : 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleSave,
                          borderRadius: BorderRadius.circular(isMobileLandscape ? 6 : (isMobile ? 8 : 10)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobileLandscape ? 12 : (isMobile ? 16 : 24), 
                              vertical: isMobileLandscape ? 8 : (isMobile ? 10 : 12)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.save_rounded,
                                  color: Colors.white,
                                  size: isMobileLandscape ? 16 : (isMobile ? 18 : 20),
                                ),
                                SizedBox(width: isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
                                Text(
                                  isMobile ? 'Guardar' : 'Guardar Cambios',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionTitle(String title, IconData icon, bool isMobile, bool isMobileLandscape) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobileLandscape ? 5 : (isMobile ? 6 : 8)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976d2), Color(0xFF1565c0)],
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
            color: Color(0xFF1976d2),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    bool isRequired = false,
    bool isMobile = false,
    bool isMobileLandscape = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
        border: Border.all(
          color: Color(0xFF1976d2).withOpacity(0.3),
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
          prefixIcon: Icon(icon, color: Color(0xFF1976d2), size: isMobileLandscape ? 18 : (isMobile ? 20 : 24)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobileLandscape ? 10 : (isMobile ? 12 : 16), 
            vertical: isMobileLandscape ? 10 : (isMobile ? 12 : 16)
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeButton({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    bool isMobile = false,
    bool isMobileLandscape = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
        border: Border.all(
          color: Color(0xFF1976d2).withOpacity(0.3),
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
                    color: Color(0xFF1976d2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
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
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
        border: Border.all(
          color: Color(0xFF1976d2).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        style: TextStyle(fontSize: isMobileLandscape ? 13 : (isMobile ? 14 : 16), color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: isMobileLandscape ? 12 : (isMobile ? 13 : 14)),
          prefixIcon: Icon(icon, color: Color(0xFF1976d2), size: isMobileLandscape ? 18 : (isMobile ? 20 : 24)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobileLandscape ? 8 : (isMobile ? 10 : 12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobileLandscape ? 10 : (isMobile ? 12 : 16), 
            vertical: isMobileLandscape ? 10 : (isMobile ? 12 : 16)
          ),
        ),
        isExpanded: true,
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRadioOption({
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
          horizontal: isMobileLandscape ? 1 : (isMobile ? 2 : 4)
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
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
