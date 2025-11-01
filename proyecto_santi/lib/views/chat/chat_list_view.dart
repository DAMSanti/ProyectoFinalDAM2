import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/auth.dart';
import 'package:proyecto_santi/services/services.dart';
import 'package:proyecto_santi/views/chat/vistas/chat_view.dart';
import 'package:proyecto_santi/components/desktop_shell.dart';
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xFF0A0E21),
                      Color(0xFF1A1F3A),
                    ]
                  : const [
                      Color(0xFFE3F2FD),
                      Color(0xFFBBDEFB),
                    ],
            ),
          ),
          child: Column(
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
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark, bool isWeb) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.05),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterActivities,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar actividades...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : const Color(0xFF1976d2).withValues(alpha: 0.7),
            size: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDark ? Colors.white54 : Colors.black54,
                    size: 20,
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
                    fontSize: 14,
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
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar los chats',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(
                    fontSize: 13,
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
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFF1976d2).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _searchController.text.isEmpty
                        ? Icons.chat_bubble_outline_rounded
                        : Icons.search_off_rounded,
                    size: 64,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : const Color(0xFF1976d2).withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _searchController.text.isEmpty
                      ? 'No hay actividades disponibles'
                      : 'No se encontraron resultados',
                  style: TextStyle(
                    fontSize: 16,
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
                    fontSize: 13,
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
                  // Navegar usando el shell en lugar de Navigator.push
                  navigateToChatInShell(context, {
                    'activityId': actividad.id.toString(),
                    'displayName': actividad.titulo,
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}

class ActividadCard extends StatefulWidget {
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

  @override
  State<ActividadCard> createState() => _ActividadCardState();
}

class _ActividadCardState extends State<ActividadCard> {
  bool _isHovered = false;

  String _formatDateRange() {
    try {
      final inicio = DateTime.parse(widget.actividad.fini);
      return DateFormat('dd/MM/yyyy').format(inicio);
    } catch (e) {
      return widget.actividad.fini;
    }
  }

  Color _getStatusColor() {
    switch (widget.actividad.estado.toLowerCase()) {
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
    switch (widget.actividad.estado.toLowerCase()) {
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
    final estadoColor = _getStatusColor();
    final estadoIcon = _getStatusIcon();
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: _isHovered 
              ? (Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..setTranslationRaw(8.0, 0.0, 0.0)
                ..multiply(Matrix4.diagonal3Values(1.005, 1.005, 1.0)))
              : Matrix4.identity(),
          child: Container(
            height: 95, // Altura fija para el surco horizontal
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: widget.isDark
                    ? const [
                        Color.fromRGBO(25, 118, 210, 0.20),
                        Color.fromRGBO(21, 101, 192, 0.15),
                      ]
                    : const [
                        Color.fromRGBO(187, 222, 251, 0.75),
                        Color.fromRGBO(144, 202, 249, 0.65),
                      ],
              ),
              boxShadow: [
                // Sombra principal
                BoxShadow(
                  color: _isHovered 
                      ? const Color.fromRGBO(25, 118, 210, 0.30)
                      : (widget.isDark ? const Color.fromRGBO(0, 0, 0, 0.35) : const Color.fromRGBO(0, 0, 0, 0.12)),
                  offset: _isHovered ? const Offset(6, 8) : const Offset(2, 3),
                  blurRadius: _isHovered ? 20.0 : 10.0,
                  spreadRadius: _isHovered ? 0 : -1,
                ),
                // Sombra secundaria en hover
                if (_isHovered)
                  const BoxShadow(
                    color: Color.fromRGBO(25, 118, 210, 0.15),
                    offset: Offset(3, 4),
                    blurRadius: 12.0,
                  ),
              ],
              border: Border.all(
                color: _isHovered
                    ? const Color.fromRGBO(25, 118, 210, 0.5)
                    : (widget.isDark ? const Color.fromRGBO(255, 255, 255, 0.08) : const Color.fromRGBO(0, 0, 0, 0.04)),
                width: _isHovered ? 1.5 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Stack(
                  children: [
                    // Barra lateral izquierda decorativa
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: widget.actividad.tipo == 'Complementaria'
                              ? [
                                  Color(0xFF1976d2), // Azul oscuro
                                  Color(0xFF42A5F5), // Azul medio
                                  Color(0xFF64B5F6), // Azul claro
                                ]
                              : [
                                  Color(0xFFE65100), // Naranja oscuro
                                  Color(0xFFFF6F00), // Naranja medio
                                  Color(0xFFFF9800), // Naranja claro
                                ],
                          ),
                        ),
                      ),
                    ),
                    // Efecto de brillo en hover
                    if (_isHovered)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color.fromRGBO(25, 118, 210, 0.08),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Icono decorativo de fondo
                    Positioned(
                      right: -15,
                      top: -15,
                      child: Opacity(
                        opacity: widget.isDark ? 0.04 : 0.03,
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 90,
                          color: Color(0xFF1976d2),
                        ),
                      ),
                    ),
                    // Contenido principal
                    InkWell(
                      onTap: widget.onTap,
                      borderRadius: BorderRadius.circular(16.0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                        child: Row(
                          children: [
                            // Icono del tipo de actividad
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(25, 118, 210, 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color.fromRGBO(25, 118, 210, 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.chat_rounded,
                                color: Color(0xFF1976d2),
                                size: 24,
                              ),
                            ),
                            
                            const SizedBox(width: 14),
                            
                            // Información de la actividad
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Título
                                  Text(
                                    widget.actividad.titulo,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: widget.isDark ? Colors.white : Color(0xFF1A237E),
                                      letterSpacing: -0.3,
                                      height: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  
                                  const SizedBox(height: 4),
                                  
                                  // Descripción
                                  Text(
                                    widget.actividad.descripcion?.isNotEmpty == true 
                                        ? widget.actividad.descripcion! 
                                        : 'Sin descripción',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.isDark ? Colors.white60 : Colors.black54,
                                      height: 1.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 14),
                            
                            // Fecha y estado
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Fecha con icono
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: widget.isDark ? Colors.white54 : Colors.black45,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDateRange(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: widget.isDark ? Colors.white60 : Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 6),
                                
                                // Badge de estado
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(
                                      (estadoColor.r * 255.0).round(),
                                      (estadoColor.g * 255.0).round(),
                                      (estadoColor.b * 255.0).round(),
                                      0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color.fromRGBO(
                                        (estadoColor.r * 255.0).round(),
                                        (estadoColor.g * 255.0).round(),
                                        (estadoColor.b * 255.0).round(),
                                        0.4,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        estadoIcon,
                                        size: 12,
                                        color: estadoColor,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        widget.actividad.estado,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: estadoColor,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
