import '../l10n/joss_strings.dart';

/// Validadores reutilizables estándar para el ecosistema Joss.
class JossValidators {
  JossValidators._();

  /// Validador de correo electrónico sin espacios intermedios.
  static String? email(String? value, {JossStrings? strings, String? requiredMsg, String? invalidMsg}) {
    final s = strings ?? JossStrings.es();
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? s.emailRequired;
    }
    final trimmed = value.trim();
    if (trimmed.contains(' ')) {
      return invalidMsg ?? s.emailNoSpaces;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return invalidMsg ?? s.emailInvalid;
    }
    return null;
  }

  /// Validador de contraseña obligatoria y longitud mínima.
  static String? password(String? value, {int minLength = 6, JossStrings? strings, String? requiredMsg, String? minLengthMsg}) {
    final s = strings ?? JossStrings.es();
    if (value == null || value.isEmpty) {
      return requiredMsg ?? s.passwordRequired;
    }
    if (value.length < minLength) {
      return minLengthMsg ?? s.passwordTooShort(minLength);
    }
    return null;
  }

  /// Validador de confirmación de contraseña coincidente.
  static String? confirmPassword(String? value, String originalPassword, {JossStrings? strings, String? mismatchMsg}) {
    final s = strings ?? JossStrings.es();
    if (value == null || value.isEmpty) {
      return s.confirmPassword;
    }
    if (value != originalPassword) {
      return mismatchMsg ?? s.passwordsDoNotMatch;
    }
    return null;
  }

  /// Validador de código de dos factores (TOTP / OTP de 6 dígitos numéricos).
  static String? twoFactorCode(String? value, {JossStrings? strings, String? requiredMsg, String? invalidMsg}) {
    final s = strings ?? JossStrings.es();
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? s.twoFactorCodeRequired;
    }
    final regExp = RegExp(r'^\d{6}$');
    if (!regExp.hasMatch(value.trim())) {
      return invalidMsg ?? s.twoFactorCodeInvalid;
    }
    return null;
  }

  /// Validador de nombre o campo de texto general.
  static String? requiredField(String? value, String fieldName, {JossStrings? strings}) {
    final s = strings ?? JossStrings.es();
    if (value == null || value.trim().isEmpty) {
      return s.fieldRequired(fieldName);
    }
    return null;
  }
}
