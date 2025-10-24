/// Utilidades para validación de formularios

class Validators {
  /// Valida que un campo no esté vacío
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? "Este campo"} es obligatorio';
    }
    return null;
  }

  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }

  /// Valida longitud mínima de contraseña
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    
    if (value.length < minLength) {
      return 'La contraseña debe tener al menos $minLength caracteres';
    }
    
    return null;
  }

  /// Valida que dos contraseñas coincidan
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  /// Valida formato de DNI español
  static String? dni(String? value) {
    if (value == null || value.isEmpty) {
      return 'El DNI es obligatorio';
    }
    
    final dniRegex = RegExp(r'^\d{8}[A-Z]$');
    
    if (!dniRegex.hasMatch(value.toUpperCase())) {
      return 'Formato de DNI inválido (ej: 12345678A)';
    }
    
    return null;
  }

  /// Valida que un número esté en un rango
  static String? numberInRange(
    String? value, {
    required double min,
    required double max,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? "Este campo"} es obligatorio';
    }
    
    final number = double.tryParse(value);
    
    if (number == null) {
      return 'Ingresa un número válido';
    }
    
    if (number < min || number > max) {
      return '${fieldName ?? "El valor"} debe estar entre $min y $max';
    }
    
    return null;
  }

  /// Valida longitud mínima
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? "Este campo"} es obligatorio';
    }
    
    if (value.length < min) {
      return '${fieldName ?? "Este campo"} debe tener al menos $min caracteres';
    }
    
    return null;
  }

  /// Valida longitud máxima
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? "Este campo"} no puede tener más de $max caracteres';
    }
    
    return null;
  }
}
