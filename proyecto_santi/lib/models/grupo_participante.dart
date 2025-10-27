import 'package:proyecto_santi/models/grupo.dart';

/// Representa un grupo participante en una actividad con el número de alumnos que asistirán
class GrupoParticipante {
  final Grupo grupo;
  int numeroParticipantes; // Número de alumnos que van a asistir

  GrupoParticipante({
    required this.grupo,
    required this.numeroParticipantes,
  });

  /// Verifica si el número de participantes es válido
  bool get isValid => numeroParticipantes > 0 && numeroParticipantes <= grupo.numeroAlumnos;
}
