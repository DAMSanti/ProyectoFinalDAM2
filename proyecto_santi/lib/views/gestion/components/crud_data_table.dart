import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Componente reutilizable para mostrar tablas de datos en las vistas CRUD
class CrudDataTable<T> extends StatefulWidget {
  final List<T> items;
  final List<DataColumn> columns;
  final List<DataCell> Function(T item) buildCells;
  final void Function(T item)? onEdit;
  final void Function(T item)? onDelete;
  final bool isLoading;
  final String emptyMessage;

  const CrudDataTable({
    Key? key,
    required this.items,
    required this.columns,
    required this.buildCells,
    this.onEdit,
    this.onDelete,
    this.isLoading = false,
    this.emptyMessage = 'No hay datos disponibles',
  }) : super(key: key);

  @override
  State<CrudDataTable<T>> createState() => _CrudDataTableState<T>();
}

class _CrudDataTableState<T> extends State<CrudDataTable<T>> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(kIsWeb ? 8.sp : 20.dg),
          child: Text(
            widget.emptyMessage,
            style: TextStyle(
              fontSize: kIsWeb ? 4.sp : 14.dg,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            ...widget.columns,
            DataColumn(
              label: Text(
                'Acciones',
                style: TextStyle(
                  fontSize: kIsWeb ? 4.sp : 14.dg,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          rows: widget.items.map((item) {
            return DataRow(
              cells: [
                ...widget.buildCells(item),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.onEdit != null)
                        IconButton(
                          icon: Icon(Icons.edit, size: kIsWeb ? 4.sp : 20.dg),
                          color: Colors.blue,
                          tooltip: 'Editar',
                          onPressed: () => widget.onEdit!(item),
                        ),
                      if (widget.onDelete != null)
                        IconButton(
                          icon: Icon(Icons.delete, size: kIsWeb ? 4.sp : 20.dg),
                          color: Colors.red,
                          tooltip: 'Eliminar',
                          onPressed: () => widget.onDelete!(item),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
