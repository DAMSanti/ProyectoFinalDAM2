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
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Calcular total de gastos personalizados
    final totalGastos = gastos.fold<double>(
      0.0, 
      (sum, gasto) => sum + gasto.cantidad
    );
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
        border: Border.all(
          color: Colors.amber.withOpacity(0.4),
          width: isMobile ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: isMobile ? 6 : 12,
            offset: Offset(0, isMobile ? 2 : 4),
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
                  // Ocultar icono en móvil
                  if (!isMobile)
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
                  if (!isMobile) SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gastos Varios',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : (isWeb ? 14 : 16.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                      if (totalGastos > 0)
                        Text(
                          '${totalGastos.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : (isWeb ? 16 : 18.0),
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
                    borderRadius: BorderRadius.circular(isMobile ? 6 : 10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: isMobile ? 4 : 6,
                        offset: Offset(0, isMobile ? 1 : 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(isMobile ? 6 : 10),
                      onTap: onAddGasto,
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 4 : 8),
                        child: Icon(
                          Icons.add_circle_rounded, 
                          color: Colors.white,
                          size: isMobile ? 16 : 24,
                        ),
                      ),
                    ),
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
              margin: EdgeInsets.only(top: isMobile ? 8 : 12),
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
                    margin: EdgeInsets.only(bottom: isMobile ? 4 : 8),
                    padding: EdgeInsets.all(isMobile ? 6 : 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.amber.withOpacity(0.15),
                          Colors.amber.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(isMobile ? 6 : 10),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                        width: isMobile ? 0.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Ocultar icono en móvil
                        if (!isMobile)
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
                        if (!isMobile) SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            gasto.concepto,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : (isWeb ? 13 : 15.0),
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Text(
                          '${gasto.cantidad.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : (isWeb ? 14 : 16.0),
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        if (isAdminOrSolicitante) ...[
                          SizedBox(width: isMobile ? 4 : 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
                                onTap: () => onDeleteGasto(gasto),
                                child: Padding(
                                  padding: EdgeInsets.all(isMobile ? 3 : 6),
                                  child: Icon(
                                    Icons.delete_rounded, 
                                    color: Colors.red[700], 
                                    size: isMobile ? 14 : (isWeb ? 18 : 20.0)
                                  ),
                                ),
                              ),
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
