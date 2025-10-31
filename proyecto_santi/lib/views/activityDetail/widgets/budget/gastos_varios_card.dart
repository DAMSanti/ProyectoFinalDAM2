import 'package:flutter/material.dart';
import '../../../../models/gasto_personalizado.dart';

/// Widget reutilizable para mostrar la tarjeta de gastos personalizados
class GastosVariosCardWidget extends StatelessWidget {
  final List<GastoPersonalizado> gastos;
  final bool isAdminOrSolicitante;
  final bool isLoading;
  final bool isWeb;
  final VoidCallback onAddGasto;
  final Function(GastoPersonalizado) onDeleteGasto;

  const GastosVariosCardWidget({
    Key? key,
    required this.gastos,
    required this.isAdminOrSolicitante,
    required this.isLoading,
    required this.isWeb,
    required this.onAddGasto,
    required this.onDeleteGasto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcular total de gastos personalizados
    final totalGastos = gastos.fold<double>(
      0.0, 
      (sum, gasto) => sum + gasto.cantidad
    );
    
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.amber.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título y botón agregar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.amber.withOpacity(0.8),
                          Colors.amber.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: isWeb ? 22 : 24.0,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gastos Varios',
                        style: TextStyle(
                          fontSize: isWeb ? 14 : 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                      if (totalGastos > 0)
                        Text(
                          '${totalGastos.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: isWeb ? 16 : 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (isAdminOrSolicitante)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.8),
                        Colors.amber.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add_circle_rounded, color: Colors.white),
                    onPressed: onAddGasto,
                    tooltip: 'Agregar gasto',
                  ),
                ),
            ],
          ),
          
          if (isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            )
          else if (gastos.isEmpty)
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.amber.withOpacity(0.5),
                      size: isWeb ? 40 : 44.0,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No hay gastos personalizados',
                      style: TextStyle(
                        fontSize: isWeb ? 12 : 14.0,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              margin: EdgeInsets.only(top: 12),
              constraints: BoxConstraints(
                maxHeight: gastos.length > 5 ? 300 : double.infinity,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: gastos.length > 5 
                    ? AlwaysScrollableScrollPhysics() 
                    : NeverScrollableScrollPhysics(),
                itemCount: gastos.length,
                itemBuilder: (context, index) {
                  final gasto = gastos[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.amber.withOpacity(0.15),
                          Colors.amber.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.withOpacity(0.6),
                                Colors.amber.withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.receipt_rounded, 
                            color: Colors.white, 
                            size: isWeb ? 18 : 20.0
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            gasto.concepto,
                            style: TextStyle(
                              fontSize: isWeb ? 13 : 15.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Text(
                          '${gasto.cantidad.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: isWeb ? 14 : 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        if (isAdminOrSolicitante) ...[
                          SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.delete_rounded, color: Colors.red[700], size: isWeb ? 18 : 20.0),
                              onPressed: () => onDeleteGasto(gasto),
                              padding: EdgeInsets.all(6),
                              constraints: BoxConstraints(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
