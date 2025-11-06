class Curso {
  final int id;
  final String nombre; // Formato: "CODIGO - TITULO"
  final String nivel;
  final bool activo;

  Curso({
    required this.id,
    required this.nombre,
    required this.nivel,
    this.activo = true,
  });

  // Extrae el código del curso desde el nombre (antes del " - ")
  String get codCurso {
    if (nombre.contains(' - ')) {
      return nombre.split(' - ').first.trim();
    }
    return nombre.split(' ').first;
  }

  // Extrae el título del curso desde el nombre (después del " - ")
  String get titulo {
    if (nombre.contains(' - ')) {
      return nombre.split(' - ').sublist(1).join(' - ').trim();
    }
    return nombre;
  }

  // Intenta detectar la etapa desde el código del curso
  String get etapa {
    final codigo = codCurso.toUpperCase();
    if (codigo.startsWith('ESO')) return 'ESO';
    if (codigo.startsWith('BACH')) return 'BACH';
    if (codigo.startsWith('FPB')) return 'FPB';
    if (codigo.startsWith('FPGM') || ['SMR', 'MEC', 'GAD'].any((p) => codigo.startsWith(p))) return 'FPGM';
    if (codigo.startsWith('FPGS') || ['DAM', 'DAW', 'ASIR', 'AYF', 'PPFM', 'DPFM'].any((p) => codigo.startsWith(p))) return 'FPGS';
    if (codigo.startsWith('FPCE')) return 'FPCE';
    return '';
  }

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      nivel: json['nivel']?.toString() ?? '',
      activo: json['activo'] == 1 || json['activo'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nivel': nivel,
      'activo': activo,
    };
  }

  // Helper para obtener la descripción completa de la etapa
  String get etapaDescripcion {
    switch (etapa) {
      case 'ESO':
        return 'ESO';
      case 'BACH':
        return 'Bachillerato';
      case 'FPGS':
        return 'FP Grado Superior';
      case 'FPGM':
        return 'FP Grado Medio';
      case 'FPB':
        return 'FP Básica';
      case 'FPCE':
        return 'FP Curso Especialización';
      default:
        return etapa.isEmpty ? 'Sin etapa' : etapa;
    }
  }
}
