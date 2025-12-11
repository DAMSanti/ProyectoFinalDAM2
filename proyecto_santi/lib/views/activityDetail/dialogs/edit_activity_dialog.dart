import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/shared/widgets/dialog_header.dart';
import 'package:proyecto_santi/shared/widgets/dialog_footer.dart';
import 'package:proyecto_santi/tema/tema.dart';
import '../widgets/forms/status_and_type_form.dart';
import '../widgets/forms/basic_info_form.dart';
import '../widgets/forms/datetime_form.dart';
import '../widgets/forms/responsable_form.dart';
import '../helpers/dialog_form_helpers.dart';
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
  String _estadoActividad = 'Pendiente'; 
  String _tipoActividad = 'Complementaria'; 
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
    _nombreController = TextEditingController(text: widget.actividad.titulo);
    _descripcionController = TextEditingController(text: widget.actividad.descripcion ?? '');
    _fechaInicio = DateTime.parse(widget.actividad.fini);
    _fechaFin = DateTime.parse(widget.actividad.ffin);
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
    final estadoActual = widget.actividad.estado.toLowerCase();
    if (estadoActual == 'aprobada') {
      _estadoActividad = 'Aprobada';
    } else if (estadoActual == 'cancelada') {
      _estadoActividad = 'Cancelada';
    } else {
      _estadoActividad = 'Pendiente';
    }
    final tipoActual = widget.actividad.tipo.trim();
    if (tipoActual.toLowerCase() == 'extraescolar') {
      _tipoActividad = 'Extraescolar';
    } else if (tipoActual.toLowerCase() == 'complementaria') {
      _tipoActividad = 'Complementaria';
    } else {
      _tipoActividad = 'Complementaria';
    }
    if (widget.actividad.responsable != null) {
      _selectedProfesorId = widget.actividad.responsable!.uuid;
    }
    _loadData();
  }
  Future<void> _loadData() async {
    try {
      final profesores = await _profesorService.fetchProfesores();
      setState(() {
        _profesores = profesores;
        if (_selectedProfesorId != null) {
          final profesorExists = _profesores.any((p) => p.uuid == _selectedProfesorId);
          if (!profesorExists) {
            _selectedProfesorId = null;
          }
        }
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        try {
          SnackBarHelper.showError(context, 'Error al cargar datos: ${e.toString()}');
        } catch (e) {
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
    if (_nombreController.text.trim().isEmpty) {
      SnackBarHelper.showWarning(context, 'El nombre es obligatorio');
      return;
    }
    bool hasChanges = false;
    if (_nombreController.text.trim() != widget.actividad.titulo.trim()) {
      hasChanges = true;
    }
    if (_descripcionController.text.trim() != (widget.actividad.descripcion ?? '').trim()) {
      hasChanges = true;
    }
    final fechaInicioOriginal = DateTime.parse(widget.actividad.fini);
    final fechaInicioNormalizada = DateTime(_fechaInicio.year, _fechaInicio.month, _fechaInicio.day,
                                            _fechaInicio.hour, _fechaInicio.minute, _fechaInicio.second);
    final fechaOriginalNormalizada = DateTime(fechaInicioOriginal.year, fechaInicioOriginal.month, fechaInicioOriginal.day,
                                               fechaInicioOriginal.hour, fechaInicioOriginal.minute, fechaInicioOriginal.second);
    if (fechaInicioNormalizada != fechaOriginalNormalizada) {
      hasChanges = true;
    }
    final fechaFinOriginal = DateTime.parse(widget.actividad.ffin);
    final fechaFinNormalizada = DateTime(_fechaFin.year, _fechaFin.month, _fechaFin.day,
                                         _fechaFin.hour, _fechaFin.minute, _fechaFin.second);
    final fechaFinOriginalNormalizada = DateTime(fechaFinOriginal.year, fechaFinOriginal.month, fechaFinOriginal.day,
                                                  fechaFinOriginal.hour, fechaFinOriginal.minute, fechaFinOriginal.second);
    if (fechaFinNormalizada != fechaFinOriginalNormalizada) {
      hasChanges = true;
    }
    final hiniNueva = '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}';
    String hiniOriginal = widget.actividad.hini;
    if (hiniOriginal.length > 5 && hiniOriginal.substring(5, 6) == ':') {
      hiniOriginal = hiniOriginal.substring(0, 5);
    }
    if (hiniNueva != hiniOriginal) {
      hasChanges = true;
    }
    final hfinNueva = '${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}';
    String hfinOriginal = widget.actividad.hfin;
    if (hfinOriginal.length > 5 && hfinOriginal.substring(5, 6) == ':') {
      hfinOriginal = hfinOriginal.substring(0, 5);
    }
    if (hfinNueva != hfinOriginal) {
      hasChanges = true;
    }
    String? profesorOriginalId;
    if (widget.actividad.responsable != null) {
      profesorOriginalId = widget.actividad.responsable!.uuid;
    }
    if (_selectedProfesorId != profesorOriginalId) {
      hasChanges = true;
    }
    if (_estadoActividad != widget.actividad.estado) {
      hasChanges = true;
    }
    hasChanges = true; 
    if (_folletoChanged) {
      hasChanges = true;
    }
    if (hasChanges) {
      final data = {
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'fechaInicio': _fechaInicio.toIso8601String(),
        'fechaFin': _fechaFin.toIso8601String(),
        'hini': '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}:00',
        'hfin': '${_horaFin.hour.toString().padLeft(2, '0')}:${_horaFin.minute.toString().padLeft(2, '0')}:00',
        'profesorId': _selectedProfesorId,
        'estado': _estadoActividad, 
        'tipoActividad': _tipoActividad, 
      };
      if (_folletoChanged && _folletoFilePath != null && _folletoFileName != null) {
        data['folletoFilePath'] = _folletoFilePath!;
        data['folletoFileName'] = _folletoFileName!;
      }
      widget.onSave(data);
    } else {
    }
    Navigator.of(context).pop();
  }
  Widget _buildLandscapeMobileLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BasicInfoSection(
                nombreController: _nombreController,
                descripcionController: _descripcionController,
                isMobile: true,
                isMobileLandscape: true,
                buildTextField: DialogFormHelpers.buildTextField,
                buildSectionTitle: DialogFormHelpers.buildSectionTitle,
              ),
              SizedBox(height: 12),
              DateTimeSection(
                fechaInicio: _fechaInicio,
                fechaFin: _fechaFin,
                horaInicio: _horaInicio,
                horaFin: _horaFin,
                onSelectDate: _selectDate,
                onSelectTime: _selectTime,
                isMobile: true,
                isMobileLandscape: true,
                buildSectionTitle: DialogFormHelpers.buildSectionTitle,
                buildDateTimeButton: DialogFormHelpers.buildDateTimeButton,
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsableSection(
                selectedProfesorId: _selectedProfesorId,
                profesores: _profesores,
                onChanged: (value) {
                  setState(() {
                    _selectedProfesorId = value;
                  });
                },
                isMobile: true,
                isMobileLandscape: true,
                buildSectionTitle: DialogFormHelpers.buildSectionTitle,
                buildDropdown: DialogFormHelpers.buildDropdown,
              ),
              SizedBox(height: 12),
              DialogFormHelpers.buildSectionTitle('Estado', Icons.check_circle_rounded, true, true),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DialogFormHelpers.buildRadioOption(
                      value: 'Pendiente',
                      groupValue: _estadoActividad,
                      label: 'Pend.',
                      icon: Icons.schedule_rounded,
                      color: AppColors.estadoPendiente,
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
                    child: DialogFormHelpers.buildRadioOption(
                      value: 'Aprobada',
                      groupValue: _estadoActividad,
                      label: 'Aprob.',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.estadoAprobado,
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
                    child: DialogFormHelpers.buildRadioOption(
                      value: 'Cancelada',
                      groupValue: _estadoActividad,
                      label: 'Cancel.',
                      icon: Icons.cancel_rounded,
                      color: AppColors.estadoRechazado,
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
              DialogFormHelpers.buildSectionTitle('Tipo', Icons.category_rounded, true, true),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DialogFormHelpers.buildRadioOption(
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
                    child: DialogFormHelpers.buildRadioOption(
                      value: 'Extraescolar',
                      groupValue: _tipoActividad,
                      label: 'Extra.',
                      icon: Icons.sports_soccer_rounded,
                      color: AppColors.tipoComplementaria,
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
            EditDialogHeader(
              isMobile: isMobile,
              isMobileLandscape: isMobileLandscape,
              onClose: () => Navigator.of(context).pop(),
            ),
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
                                BasicInfoSection(
                                  nombreController: _nombreController,
                                  descripcionController: _descripcionController,
                                  isMobile: isMobile,
                                  isMobileLandscape: isMobileLandscape,
                                  buildTextField: DialogFormHelpers.buildTextField,
                                  buildSectionTitle: DialogFormHelpers.buildSectionTitle,
                                ),
                                SizedBox(height: isMobile ? 16 : 24),
                                DateTimeSection(
                                  fechaInicio: _fechaInicio,
                                  fechaFin: _fechaFin,
                                  horaInicio: _horaInicio,
                                  horaFin: _horaFin,
                                  onSelectDate: _selectDate,
                                  onSelectTime: _selectTime,
                                  isMobile: isMobile,
                                  isMobileLandscape: isMobileLandscape,
                                  buildDateTimeButton: DialogFormHelpers.buildDateTimeButton,
                                  buildSectionTitle: DialogFormHelpers.buildSectionTitle,
                                ),
                                SizedBox(height: isMobile ? 16 : 24),
                                ResponsableSection(
                                  selectedProfesorId: _selectedProfesorId,
                                  profesores: _profesores,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedProfesorId = value;
                                    });
                                  },
                                  isMobile: isMobile,
                                  isMobileLandscape: isMobileLandscape,
                                  buildDropdown: DialogFormHelpers.buildDropdown,
                                  buildSectionTitle: DialogFormHelpers.buildSectionTitle,
                                ),
                                SizedBox(height: isMobile ? 16 : 24),
                                DialogFormHelpers.buildSectionTitle('Estado y Tipo', Icons.check_circle_rounded, isMobile, isMobileLandscape),
                                SizedBox(height: isMobile ? 10 : 12),
                                ActivityStatusAndTypeSection(
                                  estadoActividad: _estadoActividad,
                                  tipoActividad: _tipoActividad,
                                  onEstadoChanged: (value) {
                                    setState(() {
                                      _estadoActividad = value;
                                    });
                                  },
                                  onTipoChanged: (value) {
                                    setState(() {
                                      _tipoActividad = value;
                                    });
                                  },
                                  isMobile: isMobile,
                                  isMobileLandscape: isMobileLandscape,
                                  buildRadioOption: DialogFormHelpers.buildRadioOption,
                                ),
                        ],
                      ),
                    ),
            ),
            EditDialogFooter(
              isMobile: isMobile,
              isMobileLandscape: isMobileLandscape,
              isDark: isDark,
              onCancel: () => Navigator.of(context).pop(),
              onSave: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}