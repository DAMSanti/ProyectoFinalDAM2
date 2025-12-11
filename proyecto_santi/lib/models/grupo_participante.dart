import 'package:proyecto_santi/models/grupo.dart';
class GrupoParticipante {
  final Grupo grupo;
  int numeroParticipantes; 
  GrupoParticipante({
    required this.grupo,
    required this.numeroParticipantes,
  });
  bool get isValid => numeroParticipantes > 0 && numeroParticipantes <= grupo.numeroAlumnos;
}