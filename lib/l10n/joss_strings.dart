import 'package:flutter/widgets.dart';

/// Contrato y proveedor de textos traducibles para los componentes de kit_joss.
/// Proporciona implementaciones predefinidas en Español ([JossStrings.es]) e Inglés ([JossStrings.en]),
/// y permite a cualquier app inyectar sus propias cadenas provenientes de intl, .arb o GetX.
class JossStrings {
  // Auth - General
  final String email;
  final String emailHint;
  final String password;
  final String passwordHint;
  final String back;

  // Login
  final String welcomeBack;
  final String login;
  final String forgotPassword;
  final String noAccountRegister;

  // Register
  final String createAccount;
  final String username;
  final String usernameHint;
  final String firstName;
  final String firstNameHint;
  final String lastName;
  final String lastNameHint;
  final String confirmPassword;
  final String confirmPasswordHint;
  final String register;
  final String alreadyHaveAccount;

  // Two Factor (2FA)
  final String twoFactorTitle;
  final String twoFactorDescription;
  final String twoFactorCodeLabel;
  final String twoFactorCodeHint;
  final String verifyAndContinue;
  final String backToLogin;

  // Validaciones
  final String emailRequired;
  final String emailNoSpaces;
  final String emailInvalid;
  final String passwordRequired;
  final String Function(int minLength) passwordTooShort;
  final String passwordsDoNotMatch;
  final String twoFactorCodeRequired;
  final String twoFactorCodeInvalid;
  final String Function(String fieldName) fieldRequired;

  // Indicador de seguridad de contraseña
  final String passwordStrengthPrefix;
  final String strengthVeryWeak;
  final String strengthWeak;
  final String strengthMedium;
  final String strengthStrong;
  final String passwordRequirementsTitle;
  final String reqMin8Chars;
  final String reqUppercase;
  final String reqLowercase;
  final String reqNumber;
  final String reqSpecialChar;

  // Diálogo de actualizaciones
  final String newVersionAvailable;
  final String Function(String version) versionAvailable;
  final String updateNow;
  final String later;

  const JossStrings({
    // Auth - General
    required this.email,
    required this.emailHint,
    required this.password,
    required this.passwordHint,
    required this.back,
    // Login
    required this.welcomeBack,
    required this.login,
    required this.forgotPassword,
    required this.noAccountRegister,
    // Register
    required this.createAccount,
    required this.username,
    required this.usernameHint,
    required this.firstName,
    required this.firstNameHint,
    required this.lastName,
    required this.lastNameHint,
    required this.confirmPassword,
    required this.confirmPasswordHint,
    required this.register,
    required this.alreadyHaveAccount,
    // Two Factor
    required this.twoFactorTitle,
    required this.twoFactorDescription,
    required this.twoFactorCodeLabel,
    required this.twoFactorCodeHint,
    required this.verifyAndContinue,
    required this.backToLogin,
    // Validaciones
    required this.emailRequired,
    required this.emailNoSpaces,
    required this.emailInvalid,
    required this.passwordRequired,
    required this.passwordTooShort,
    required this.passwordsDoNotMatch,
    required this.twoFactorCodeRequired,
    required this.twoFactorCodeInvalid,
    required this.fieldRequired,
    // Indicador
    required this.passwordStrengthPrefix,
    required this.strengthVeryWeak,
    required this.strengthWeak,
    required this.strengthMedium,
    required this.strengthStrong,
    required this.passwordRequirementsTitle,
    required this.reqMin8Chars,
    required this.reqUppercase,
    required this.reqLowercase,
    required this.reqNumber,
    required this.reqSpecialChar,
    // Actualizaciones
    required this.newVersionAvailable,
    required this.versionAvailable,
    required this.updateNow,
    required this.later,
  });

  /// Textos oficiales en Español (Predeterminado en el ecosistema Joss).
  factory JossStrings.es() => JossStrings(
        email: 'Correo electrónico',
        emailHint: 'ejemplo@joss.com',
        password: 'Contraseña',
        passwordHint: 'Tu contraseña',
        back: 'Volver',
        welcomeBack: 'Bienvenido de nuevo',
        login: 'Iniciar sesión',
        forgotPassword: '¿Olvidaste tu contraseña?',
        noAccountRegister: '¿No tienes cuenta? Regístrate aquí',
        createAccount: 'Crear cuenta',
        username: 'Nombre de usuario',
        usernameHint: 'usuario',
        firstName: 'Nombre',
        firstNameHint: 'Joss',
        lastName: 'Apellido',
        lastNameHint: 'Estrada',
        confirmPassword: 'Confirmar contraseña',
        confirmPasswordHint: 'Repite tu contraseña',
        register: 'Registrarse',
        alreadyHaveAccount: '¿Ya tienes cuenta? Inicia sesión',
        twoFactorTitle: 'Autenticación de dos factores',
        twoFactorDescription:
            'Ingresa el código de 6 dígitos generado por tu aplicación autenticadora.',
        twoFactorCodeLabel: 'Código de verificación',
        twoFactorCodeHint: '123456',
        verifyAndContinue: 'Verificar y continuar',
        backToLogin: 'Volver al inicio de sesión',
        emailRequired: 'El correo electrónico es requerido.',
        emailNoSpaces: 'El correo no debe contener espacios.',
        emailInvalid: 'Ingresa un correo electrónico válido.',
        passwordRequired: 'La contraseña es requerida.',
        passwordTooShort: (min) => 'La contraseña debe tener al menos $min caracteres.',
        passwordsDoNotMatch: 'Las contraseñas no coinciden.',
        twoFactorCodeRequired: 'Ingresa el código de 6 dígitos.',
        twoFactorCodeInvalid: 'Ingresa un código válido de 6 dígitos.',
        fieldRequired: (field) => '$field es requerido.',
        passwordStrengthPrefix: 'Seguridad',
        strengthVeryWeak: 'Muy débil',
        strengthWeak: 'Débil',
        strengthMedium: 'Media',
        strengthStrong: 'Fuerte',
        passwordRequirementsTitle: 'Requisitos de la contraseña:',
        reqMin8Chars: 'Mínimo 8 caracteres',
        reqUppercase: 'Una letra mayúscula',
        reqLowercase: 'Una letra minúscula',
        reqNumber: 'Al menos un número',
        reqSpecialChar: r'Un carácter especial (!@#$%^&*)',
        newVersionAvailable: 'Nueva versión disponible',
        versionAvailable: (v) => 'Versión disponible: v$v',
        updateNow: 'Actualizar ahora',
        later: 'Más tarde',
      );

  /// Textos oficiales en Inglés.
  factory JossStrings.en() => JossStrings(
        email: 'Email',
        emailHint: 'example@joss.com',
        password: 'Password',
        passwordHint: 'Your password',
        back: 'Back',
        welcomeBack: 'Welcome back',
        login: 'Sign in',
        forgotPassword: 'Forgot password?',
        noAccountRegister: "Don't have an account? Sign up here",
        createAccount: 'Create account',
        username: 'Username',
        usernameHint: 'username',
        firstName: 'First name',
        firstNameHint: 'Joss',
        lastName: 'Last name',
        lastNameHint: 'Estrada',
        confirmPassword: 'Confirm password',
        confirmPasswordHint: 'Repeat your password',
        register: 'Sign up',
        alreadyHaveAccount: 'Already have an account? Sign in',
        twoFactorTitle: 'Two-factor authentication',
        twoFactorDescription:
            'Enter the 6-digit code generated by your authenticator app.',
        twoFactorCodeLabel: 'Verification code',
        twoFactorCodeHint: '123456',
        verifyAndContinue: 'Verify and continue',
        backToLogin: 'Back to sign in',
        emailRequired: 'Email is required.',
        emailNoSpaces: 'Email must not contain spaces.',
        emailInvalid: 'Please enter a valid email address.',
        passwordRequired: 'Password is required.',
        passwordTooShort: (min) => 'Password must be at least $min characters long.',
        passwordsDoNotMatch: 'Passwords do not match.',
        twoFactorCodeRequired: 'Enter the 6-digit code.',
        twoFactorCodeInvalid: 'Enter a valid 6-digit code.',
        fieldRequired: (field) => '$field is required.',
        passwordStrengthPrefix: 'Security',
        strengthVeryWeak: 'Very weak',
        strengthWeak: 'Weak',
        strengthMedium: 'Medium',
        strengthStrong: 'Strong',
        passwordRequirementsTitle: 'Password requirements:',
        reqMin8Chars: 'At least 8 characters',
        reqUppercase: 'One uppercase letter',
        reqLowercase: 'One lowercase letter',
        reqNumber: 'At least one number',
        reqSpecialChar: r'One special character (!@#$%^&*)',
        newVersionAvailable: 'New version available',
        versionAvailable: (v) => 'Available version: v$v',
        updateNow: 'Update now',
        later: 'Later',
      );

  /// Permite crear una copia modificando cadenas específicas.
  JossStrings copyWith({
    String? email,
    String? emailHint,
    String? password,
    String? passwordHint,
    String? back,
    String? welcomeBack,
    String? login,
    String? forgotPassword,
    String? noAccountRegister,
    String? createAccount,
    String? username,
    String? usernameHint,
    String? firstName,
    String? firstNameHint,
    String? lastName,
    String? lastNameHint,
    String? confirmPassword,
    String? confirmPasswordHint,
    String? register,
    String? alreadyHaveAccount,
    String? twoFactorTitle,
    String? twoFactorDescription,
    String? twoFactorCodeLabel,
    String? twoFactorCodeHint,
    String? verifyAndContinue,
    String? backToLogin,
    String? emailRequired,
    String? emailNoSpaces,
    String? emailInvalid,
    String? passwordRequired,
    String Function(int minLength)? passwordTooShort,
    String? passwordsDoNotMatch,
    String? twoFactorCodeRequired,
    String? twoFactorCodeInvalid,
    String Function(String fieldName)? fieldRequired,
    String? passwordStrengthPrefix,
    String? strengthVeryWeak,
    String? strengthWeak,
    String? strengthMedium,
    String? strengthStrong,
    String? passwordRequirementsTitle,
    String? reqMin8Chars,
    String? reqUppercase,
    String? reqLowercase,
    String? reqNumber,
    String? reqSpecialChar,
    String? newVersionAvailable,
    String Function(String version)? versionAvailable,
    String? updateNow,
    String? later,
  }) {
    return JossStrings(
      email: email ?? this.email,
      emailHint: emailHint ?? this.emailHint,
      password: password ?? this.password,
      passwordHint: passwordHint ?? this.passwordHint,
      back: back ?? this.back,
      welcomeBack: welcomeBack ?? this.welcomeBack,
      login: login ?? this.login,
      forgotPassword: forgotPassword ?? this.forgotPassword,
      noAccountRegister: noAccountRegister ?? this.noAccountRegister,
      createAccount: createAccount ?? this.createAccount,
      username: username ?? this.username,
      usernameHint: usernameHint ?? this.usernameHint,
      firstName: firstName ?? this.firstName,
      firstNameHint: firstNameHint ?? this.firstNameHint,
      lastName: lastName ?? this.lastName,
      lastNameHint: lastNameHint ?? this.lastNameHint,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      confirmPasswordHint: confirmPasswordHint ?? this.confirmPasswordHint,
      register: register ?? this.register,
      alreadyHaveAccount: alreadyHaveAccount ?? this.alreadyHaveAccount,
      twoFactorTitle: twoFactorTitle ?? this.twoFactorTitle,
      twoFactorDescription: twoFactorDescription ?? this.twoFactorDescription,
      twoFactorCodeLabel: twoFactorCodeLabel ?? this.twoFactorCodeLabel,
      twoFactorCodeHint: twoFactorCodeHint ?? this.twoFactorCodeHint,
      verifyAndContinue: verifyAndContinue ?? this.verifyAndContinue,
      backToLogin: backToLogin ?? this.backToLogin,
      emailRequired: emailRequired ?? this.emailRequired,
      emailNoSpaces: emailNoSpaces ?? this.emailNoSpaces,
      emailInvalid: emailInvalid ?? this.emailInvalid,
      passwordRequired: passwordRequired ?? this.passwordRequired,
      passwordTooShort: passwordTooShort ?? this.passwordTooShort,
      passwordsDoNotMatch: passwordsDoNotMatch ?? this.passwordsDoNotMatch,
      twoFactorCodeRequired: twoFactorCodeRequired ?? this.twoFactorCodeRequired,
      twoFactorCodeInvalid: twoFactorCodeInvalid ?? this.twoFactorCodeInvalid,
      fieldRequired: fieldRequired ?? this.fieldRequired,
      passwordStrengthPrefix: passwordStrengthPrefix ?? this.passwordStrengthPrefix,
      strengthVeryWeak: strengthVeryWeak ?? this.strengthVeryWeak,
      strengthWeak: strengthWeak ?? this.strengthWeak,
      strengthMedium: strengthMedium ?? this.strengthMedium,
      strengthStrong: strengthStrong ?? this.strengthStrong,
      passwordRequirementsTitle: passwordRequirementsTitle ?? this.passwordRequirementsTitle,
      reqMin8Chars: reqMin8Chars ?? this.reqMin8Chars,
      reqUppercase: reqUppercase ?? this.reqUppercase,
      reqLowercase: reqLowercase ?? this.reqLowercase,
      reqNumber: reqNumber ?? this.reqNumber,
      reqSpecialChar: reqSpecialChar ?? this.reqSpecialChar,
      newVersionAvailable: newVersionAvailable ?? this.newVersionAvailable,
      versionAvailable: versionAvailable ?? this.versionAvailable,
      updateNow: updateNow ?? this.updateNow,
      later: later ?? this.later,
    );
  }
}

/// InheritedWidget para proveer JossStrings en el árbol de widgets opcionalmente.
class JossScope extends InheritedWidget {
  final JossStrings strings;

  const JossScope({
    super.key,
    required this.strings,
    required super.child,
  });

  static JossStrings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<JossScope>();
    return scope?.strings ?? JossStrings.es();
  }

  @override
  bool updateShouldNotify(JossScope oldWidget) => strings != oldWidget.strings;
}
