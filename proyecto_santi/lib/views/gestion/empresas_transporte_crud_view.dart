import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proyecto_santi/models/empresa_transporte.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/tema/gradient_background.dart';
import '../gestion/components/crud_data_table.dart';
import '../gestion/components/crud_delete_dialog.dart';
import '../gestion/components/crud_search_bar.dart';

class EmpresasTransporteCrudView extends StatefulWidget {
  const EmpresasTransporteCrudView({Key? key}) : super(key: key);

  @override
  State<EmpresasTransporteCrudView> createState() => _EmpresasTransporteCrudViewState();
}

class _EmpresasTransporteCrudViewState extends State<EmpresasTransporteCrudView> {
  final ApiService _apiService = ApiService();
  late final ActividadService _actividadService;
  
  List<EmpresaTransporte> _empresas = [];
  List<EmpresaTransporte> _filteredEmpresas = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _actividadService = ActividadService(_apiService);
    _loadEmpresas();
  }

  Future<void> _loadEmpresas() async {
    setState(() => _isLoading = true);
    
    try {
      final empresas = await _actividadService.fetchEmpresasTransporte();
      setState(() {
        _empresas = empresas;
        _filteredEmpresas = empresas;
        _isLoading = false;
      });
    } catch (e) {
      print('[ERROR] Error al cargar empresas de transporte: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar empresas de transporte: $e')),
        );
      }
    }
  }

  void _filterEmpresas(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredEmpresas = _empresas;
      } else {
        _filteredEmpresas = _empresas.where((empresa) {
          final searchLower = query.toLowerCase();
          return empresa.nombre.toLowerCase().contains(searchLower) ||
                 empresa.cif.toLowerCase().contains(searchLower) ||
                 (empresa.localidad?.toLowerCase().contains(searchLower) ?? false);
        }).toList();
      }
    });
  }

  void _addEmpresa() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de añadir empresa en desarrollo')),
    );
  }

  void _editEmpresa(EmpresaTransporte empresa) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar empresa: ${empresa.nombre}')),
    );
  }

  Future<void> _deleteEmpresa(EmpresaTransporte empresa) async {
    await CrudDeleteDialog.show(
      context: context,
      title: 'Eliminar Empresa de Transporte',
      content: '¿Estás seguro de que deseas eliminar la empresa "${empresa.nombre}"?',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionalidad de eliminar empresa en desarrollo')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Fondo con degradado
        isDark 
          ? GradientBackgroundDark(child: Container()) 
          : GradientBackgroundLight(child: Container()),
        // Contenido
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              CrudSearchBar(
                hintText: 'Buscar por nombre, CIF o localidad...',
                onSearch: _filterEmpresas,
                onAdd: _addEmpresa,
                addButtonText: 'Nueva Empresa',
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(kIsWeb ? 4.sp : 16.dg),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(kIsWeb ? 4.sp : 16.dg),
                    child: CrudDataTable<EmpresaTransporte>(
                      items: _filteredEmpresas,
                      isLoading: _isLoading,
                      emptyMessage: _searchQuery.isEmpty
                          ? 'No hay empresas de transporte disponibles'
                          : 'No se encontraron empresas que coincidan con "$_searchQuery"',
                      columns: [
                        DataColumn(
                          label: Text(
                            'ID',
                            style: TextStyle(
                              fontSize: kIsWeb ? 4.sp : 14.dg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nombre',
                            style: TextStyle(
                              fontSize: kIsWeb ? 4.sp : 14.dg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'CIF',
                            style: TextStyle(
                              fontSize: kIsWeb ? 4.sp : 14.dg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Localidad',
                            style: TextStyle(
                              fontSize: kIsWeb ? 4.sp : 14.dg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Contacto',
                            style: TextStyle(
                              fontSize: kIsWeb ? 4.sp : 14.dg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      buildCells: (empresa) => [
                        DataCell(Text(
                          empresa.id.toString(),
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          empresa.nombre,
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          empresa.cif,
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          empresa.localidad ?? 'N/A',
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                        DataCell(Text(
                          empresa.contacto ?? 'N/A',
                          style: TextStyle(fontSize: kIsWeb ? 3.5.sp : 12.dg),
                        )),
                      ],
                      onEdit: _editEmpresa,
                      onDelete: _deleteEmpresa,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
