import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/localizacion.dart';

/// Diálogo para editar una localización existente
/// Permite cambiar el icono y marcar/desmarcar como principal
class EditLocalizacionDialog extends StatefulWidget {
  final Localizacion localizacion;
  final List<IconData> iconosDisponibles;
  final IconData? iconoActual;
  final bool puedeSerPrincipal;

  const EditLocalizacionDialog({
    Key? key,
    required this.localizacion,
    required this.iconosDisponibles,
    this.iconoActual,
    required this.puedeSerPrincipal,
  }) : super(key: key);

  @override
  EditLocalizacionDialogState createState() => EditLocalizacionDialogState();
}

class EditLocalizacionDialogState extends State<EditLocalizacionDialog> {
  late bool _esPrincipal;
  IconData? _iconoSeleccionado;

  @override
  void initState() {
    super.initState();
    _esPrincipal = widget.localizacion.esPrincipal;
    _iconoSeleccionado = widget.iconoActual;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: Color(0xFF1976d2)),
          SizedBox(width: 8),
          Text('Editar Localización'),
        ],
      ),
      content: Container(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre de la localización
            Text(
              widget.localizacion.nombre,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.localizacion.direccionCompleta,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            
            // Checkbox para marcar como principal
            if (widget.puedeSerPrincipal)
              CheckboxListTile(
                title: Text('Marcar como localización principal'),
                subtitle: Text(
                  'Desmarcará la localización principal actual',
                  style: TextStyle(fontSize: 11),
                ),
                value: _esPrincipal,
                onChanged: (value) {
                  setState(() {
                    _esPrincipal = value ?? false;
                  });
                },
                activeColor: Colors.red,
              ),
            
            SizedBox(height: 16),
            
            // Selector de icono
            Text(
              'Seleccionar icono:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: widget.iconosDisponibles.length,
                itemBuilder: (context, index) {
                  final icono = widget.iconosDisponibles[index];
                  final isSelected = _iconoSeleccionado == icono;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _iconoSeleccionado = icono;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Color(0xFF1976d2).withOpacity(0.2)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                              ? Color(0xFF1976d2)
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        icono,
                        size: 32,
                        color: isSelected ? Color(0xFF1976d2) : Colors.grey[700],
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'esPrincipal': _esPrincipal,
              'icono': _iconoSeleccionado,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1976d2),
          ),
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
