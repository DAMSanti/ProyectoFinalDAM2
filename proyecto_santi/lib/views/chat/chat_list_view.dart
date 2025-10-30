import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/views/chat/vistas/chat_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ChatListView extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;

  const ChatListView({
    super.key,
    required this.onToggleTheme,
    required this.isDarkTheme,
  });

  @override
  ChatListViewState createState() => ChatListViewState();
}

class ChatListViewState extends State<ChatListView> {
  late Future<List<Actividad>> _futureActivities;
  late final ApiService _apiService;
  late final ActividadService _actividadService;
  final TextEditingController _searchController = TextEditingController();
  List<Actividad> _allActividades = [];
  List<Actividad> _filteredActividades = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _actividadService = ActividadService(_apiService);
    _futureActivities = _actividadService.fetchFutureActivities();
    _loadActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    try {
      final activities = await _futureActivities;
      setState(() {
        _allActividades = activities;
        _filteredActividades = activities;
      });
    } catch (e) {
      print('[ERROR] Error cargando actividades: $e');
    }
  }

  void _filterActivities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredActividades = _allActividades;
      } else {
        _filteredActividades = _allActividades.where((actividad) {
          return actividad.titulo.toLowerCase().contains(query.toLowerCase()) ||
              (actividad.descripcion?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: isDark 
            ? const Color(0xFF0A0E21)
            : const Color(0xFFF5F7FA),
        body: Column(
          children: [
            // Search Bar (sin header)
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
              ),
              child: _buildSearchBar(context, isDark, isWeb),
            ),
            
            // Activities List
            Expanded(
              child: _buildActivitiesList(context, isDark, isWeb),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark, bool isWeb) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterActivities,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: !isWeb ? 14.dg : 4.5.sp,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar actividades...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: !isWeb ? 14.dg : 4.5.sp,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark
                ? Colors.white.withOpacity(0.5)
                : const Color(0xFF1976d2).withOpacity(0.7),
            size: !isWeb ? 22.dg : 7.sp,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDark ? Colors.white54 : Colors.black54,
                    size: !isWeb ? 20.dg : 6.sp,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _filterActivities('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesList(BuildContext context, bool isDark, bool isWeb) {
    return FutureBuilder<List<Actividad>>(
      future: _futureActivities,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF1976d2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cargando chats...',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: !isWeb ? 14.dg : 4.5.sp,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: !isWeb ? 48.dg : 16.sp,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar los chats',
                  style: TextStyle(
                    fontSize: !isWeb ? 16.dg : 5.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(
                    fontSize: !isWeb ? 12.dg : 4.sp,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (_filteredActividades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFF1976d2).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _searchController.text.isEmpty
                        ? Icons.chat_bubble_outline_rounded
                        : Icons.search_off_rounded,
                    size: !isWeb ? 64.dg : 20.sp,
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : const Color(0xFF1976d2).withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _searchController.text.isEmpty
                      ? 'No hay actividades disponibles'
                      : 'No se encontraron resultados',
                  style: TextStyle(
                    fontSize: !isWeb ? 16.dg : 5.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchController.text.isEmpty
                      ? 'Aún no hay actividades para chatear'
                      : 'Intenta con otra búsqueda',
                  style: TextStyle(
                    fontSize: !isWeb ? 13.dg : 4.sp,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _futureActivities = _actividadService.fetchFutureActivities();
            });
            await _loadActivities();
          },
          color: const Color(0xFF1976d2),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filteredActividades.length,
            itemBuilder: (context, index) {
              final actividad = _filteredActividades[index];
              return ActividadCard(
                actividad: actividad,
                isDark: isDark,
                isWeb: isWeb,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatView(
                        activityId: actividad.id.toString(),
                        displayName: actividad.titulo,
                        onToggleTheme: widget.onToggleTheme,
                        isDarkTheme: widget.isDarkTheme,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class ActividadCard extends StatelessWidget {
  final Actividad actividad;
  final bool isDark;
  final bool isWeb;
  final VoidCallback onTap;

  const ActividadCard({
    super.key,
    required this.actividad,
    required this.isDark,
    required this.isWeb,
    required this.onTap,
  });

  String _formatDateRange() {
    try {
      final inicio = DateFormat('dd/MM/yyyy').parse(actividad.fini);
      final fin = DateFormat('dd/MM/yyyy').parse(actividad.ffin);
      
      if (inicio.year == fin.year && inicio.month == fin.month && inicio.day == fin.day) {
        return DateFormat('dd MMM yyyy', 'es_ES').format(inicio);
      }
      
      return '${DateFormat('dd MMM', 'es_ES').format(inicio)} - ${DateFormat('dd MMM yyyy', 'es_ES').format(fin)}';
    } catch (e) {
      return '${actividad.fini} - ${actividad.ffin}';
    }
  }

  Color _getStatusColor() {
    switch (actividad.estado.toLowerCase()) {
      case 'aprobada':
        return const Color(0xFF4CAF50);
      case 'pendiente':
        return const Color(0xFFFFA726);
      case 'rechazada':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF42A5F5);
    }
  }

  IconData _getStatusIcon() {
    switch (actividad.estado.toLowerCase()) {
      case 'aprobada':
        return Icons.check_circle_rounded;
      case 'pendiente':
        return Icons.pending_rounded;
      case 'rechazada':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color.fromRGBO(25, 118, 210, 0.25),
                  Color.fromRGBO(21, 101, 192, 0.20),
                ]
              : const [
                  Color.fromRGBO(187, 222, 251, 0.85),
                  Color.fromRGBO(144, 202, 249, 0.75),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? const Color.fromRGBO(0, 0, 0, 0.4) 
                : const Color.fromRGBO(0, 0, 0, 0.15),
            offset: const Offset(0, 4),
            blurRadius: 12.0,
            spreadRadius: -1,
          ),
          // Sombra adicional para más profundidad
          BoxShadow(
            color: const Color(0xFF1976d2).withOpacity(isDark ? 0.15 : 0.1),
            offset: const Offset(0, 8),
            blurRadius: 16.0,
            spreadRadius: -2,
          ),
        ],
        border: Border.all(
          color: isDark 
              ? const Color.fromRGBO(255, 255, 255, 0.1) 
              : const Color.fromRGBO(0, 0, 0, 0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar con más sombra
                Container(
                  width: !isWeb ? 52.dg : 17.sp,
                  height: !isWeb ? 52.dg : 17.sp,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1976d2),
                        Color(0xFF42A5F5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1976d2).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      actividad.titulo.isNotEmpty
                          ? actividad.titulo[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: !isWeb ? 20.dg : 7.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title con más contraste
                      Text(
                        actividad.titulo,
                        style: TextStyle(
                          fontSize: !isWeb ? 15.dg : 5.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1565c0),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Description con mejor contraste
                      if (actividad.descripcion != null && actividad.descripcion!.isNotEmpty)
                        Text(
                          actividad.descripcion!,
                          style: TextStyle(
                            fontSize: !isWeb ? 12.dg : 4.sp,
                            color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      
                      // Date and Status con más visibilidad
                      Row(
                        children: [
                          // Date con fondo más sólido
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: !isWeb ? 11.dg : 3.5.sp,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.9)
                                      : const Color(0xFF1976d2),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDateRange(),
                                  style: TextStyle(
                                    fontSize: !isWeb ? 10.dg : 3.5.sp,
                                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Status con más opacidad
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getStatusColor().withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getStatusColor().withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(),
                                  size: !isWeb ? 11.dg : 3.5.sp,
                                  color: _getStatusColor(),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  actividad.estado,
                                  style: TextStyle(
                                    fontSize: !isWeb ? 10.dg : 3.5.sp,
                                    color: _getStatusColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : const Color(0xFF1976d2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: !isWeb ? 16.dg : 5.sp,
                    color: isDark
                        ? Colors.white54
                        : const Color(0xFF1976d2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}