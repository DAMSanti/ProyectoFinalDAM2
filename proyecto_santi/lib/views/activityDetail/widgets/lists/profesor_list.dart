import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_santi/models/profesor.dart';

/// Widget especializado para mostrar y gestionar la lista de profesores participantes.
/// 
/// Responsabilidades:
/// - Renderizar lista de profesores con avatares
/// - Mostrar información de contacto (email)
/// - Permitir eliminar profesores (si isAdmin)
/// - Botón para agregar nuevos profesores
/// - Empty state cuando no hay profesores
class ProfesorListWidget extends StatelessWidget {
  final List<Profesor> profesores;
  final bool isAdminOrSolicitante;
  final VoidCallback onAddProfesor;
  final Function(Profesor) onRemoveProfesor;
  final bool isLoading;

  const ProfesorListWidget({
    super.key,
    required this.profesores,
    required this.isAdminOrSolicitante,
    required this.onAddProfesor,
    required this.onRemoveProfesor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWeb = kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    
    return Container(
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
        ],
        border: Border.all(
          color: isDark 
              ? const Color.fromRGBO(255, 255, 255, 0.1) 
              : const Color.fromRGBO(0, 0, 0, 0.05),
          width: 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Patrón decorativo de fondo
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: isDark ? 0.03 : 0.02,
              child: Icon(
                Icons.people_rounded,
                size: 120,
                color: Color(0xFF1976d2),
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con título y botón agregar
                _buildHeader(context, isDark, isWeb),
                SizedBox(height: 16),
                // Lista de profesores o empty state
                profesores.isEmpty
                    ? _buildEmptyState(isWeb)
                    : _buildProfesorList(context, isDark, isWeb),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isWeb) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color.fromRGBO(25, 118, 210, 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.people_rounded,
                color: Color(0xFF1976d2),
                size: isWeb ? 18 : 20.0,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Profesores Participantes',
              style: TextStyle(
                fontSize: isWeb ? 14 : 16.0,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Color(0xFF1976d2),
              ),
            ),
          ],
        ),
        if (isAdminOrSolicitante)
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF1976d2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: Color(0xFF1976d2),
                size: 20,
              ),
              onPressed: isLoading ? null : onAddProfesor,
              tooltip: 'Agregar profesor',
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(bool isWeb) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 8),
            Text(
              'Sin profesores participantes',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                fontSize: isWeb ? 12 : 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfesorList(BuildContext context, bool isDark, bool isWeb) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Column(
          children: profesores.map((profesor) {
            return _buildProfesorCard(context, profesor, isDark, isWeb);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProfesorCard(BuildContext context, Profesor profesor, bool isDark, bool isWeb) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _buildAvatar(profesor, isWeb),
        title: Text(
          '${profesor.nombre} ${profesor.apellidos}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isWeb ? 13 : 15.0,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 14,
                color: Colors.grey[600],
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  profesor.correo,
                  style: TextStyle(
                    fontSize: isWeb ? 11 : 13.0,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        trailing: isAdminOrSolicitante
            ? _buildDeleteButton(context, profesor)
            : null,
      ),
    );
  }

  Widget _buildAvatar(Profesor profesor, bool isWeb) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1976d2),
            Color(0xFF42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1976d2).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          profesor.nombre.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isWeb ? 16 : 18.0,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, Profesor profesor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: Colors.red,
          size: 18,
        ),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Confirmar eliminación'),
                  ],
                ),
                content: Text(
                  '¿Estás seguro de que deseas eliminar al profesor "${profesor.nombre} ${profesor.apellidos}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Eliminar'),
                  ),
                ],
              );
            },
          );

          if (confirmed == true) {
            onRemoveProfesor(profesor);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Profesor eliminado'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        tooltip: 'Eliminar profesor',
      ),
    );
  }
}
