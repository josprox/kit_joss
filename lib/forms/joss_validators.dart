/// Validadores reutilizables estándar para el ecosistema Joss.
class JossValidators {
  JossValidators._();

  /// Validador de correo electrónico sin espacios intermedios.
  static String? email(String? value, {String? requiredMsg, String? invalidMsg}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? 'El correo electrónico es requerido.';
    }
    final trimmed = value.trim();
    if (trimmed.contains(' ')) {
      return invalidMsg ?? 'El correo no debe contener espacios.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return invalidMsg ?? 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  /// Validador de contraseña obligatoria y longitud mínima.
  static String? password(String? value, {int minLength = 6, String? requiredMsg, String? minLengthMsg}) {
    if (value == null || value.isEmpty) {
      return requiredMsg ?? 'La contraseña es requerida.';
    }
    if (value.length < minLength) {
      return minLengthMsg ?? 'La contraseña debe tener al menos $minLength caracteres.';
    }
    return null;
  }

  /// Validador de confirmación de contraseña coincidente.
  static String? confirmPassword(String? value, String originalPassword, {String? mismatchMsg}) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña.';
    }
    if (value != originalPassword) {
      return mismatchMsg ?? 'Las contraseñas no coinciden.';
    }
    return null;
  }

  /// Validador de código de dos factores (TOTP / OTP de 6 dígitos numéricos).
  static String? twoFactorCode(String? value, {String? invalidMsg}) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el código de 6 dígitos.';
    }
    final regExp = RegExp(r'^\d{6}$');
    if (!regExp.hasMatch(value.trim())) {
      return invalidMsg ?? 'Ingresa un código válido de 6 dígitos.';
    }
    return null;
  }

  /// Validador de nombre o campo de texto general.
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido.';
    }
    return null;
  }
}
