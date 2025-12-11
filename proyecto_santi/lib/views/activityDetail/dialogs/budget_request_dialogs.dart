import 'package:flutter/material.dart';
void mostrarDialogoSolicitarPresupuestosTransporte(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Solicitar Presupuestos de Transporte'),
      content: Text(
        'Esta funcionalidad enviará solicitudes de presupuesto a las empresas de transporte configuradas.\n\n'
        'Próximamente disponible.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cerrar'),
        ),
      ],
    ),
  );
}
void mostrarDialogoSolicitarPresupuestosAlojamiento(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Solicitar Presupuestos de Alojamiento'),
      content: Text(
        'Esta funcionalidad enviará solicitudes de presupuesto a los alojamientos configurados.\n\n'
        'Próximamente disponible.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cerrar'),
        ),
      ],
    ),
  );
}