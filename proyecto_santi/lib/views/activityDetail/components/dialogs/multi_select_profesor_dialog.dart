import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/profesor.dart';

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
    return AlertDialog(
      title: Text('Agregar Profesores Participantes'),
      content: Container(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            // Buscador
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar profesor...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16),
            
            // Contador de seleccionados
            if (_selectedProfesores.isNotEmpty)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '${_selectedProfesores.length} profesor(es) seleccionado(s)',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 8),
            
            // Lista de profesores con checkboxes
            Expanded(
              child: _filteredProfesores.isEmpty
                  ? Center(child: Text('No se encontraron profesores'))
                  : ListView.builder(
                      itemCount: _filteredProfesores.length,
                      itemBuilder: (context, index) {
                        final profesor = _filteredProfesores[index];
                        final yaParticipante = _isProfesorYaParticipante(profesor);
                        final isSelected = _selectedProfesores.any((p) => p.uuid == profesor.uuid);
                        
                        return CheckboxListTile(
                          title: Text('${profesor.nombre} ${profesor.apellidos}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profesor.correo, style: TextStyle(fontSize: 12)),
                              if (yaParticipante)
                                Text(
                                  'Ya participa',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                          value: isSelected,
                          enabled: !yaParticipante,
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
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedProfesores.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selectedProfesores),
          child: Text('Agregar (${_selectedProfesores.length})'),
        ),
      ],
    );
  }
}
