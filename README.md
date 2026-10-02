# Kit Joss

Librería central, reutilizable y estándar para los proyectos del ecosistema Joss (**Estrella Music**, **Joss Auth**, **JossRed** y futuras aplicaciones).

---

## 🚀 Propósito

`kit_joss` resuelve el problema de la fragmentación y duplicación de código en el ecosistema, estableciendo un **Single Source of Truth** para:
- Autenticación completa (Login, Registro, Recuperación de contraseña y verificación 2FA).
- Criptografía estándar para copias de seguridad de contraseñas y cuentas OTP (PBKDF2 v2, AES-256-CBC y HMAC-SHA256).
- Persistencia tolerante a fallos contra corrupciones de Keystore/DPAPI en Android y Windows (`JossStorage`).
- Cliente HTTP unificado con normalización de rutas y autorización Bearer (`JossApiClient`).
- Detección y gestión de actualizaciones de aplicaciones con soporte SemVer y detección de tiendas oficiales (`JossUpdateService`).
- Componentes visuales y temas adaptables (`JossButton`, `JossTextField`, `JossLoginForm`, `JossTwoFactorForm`, `JossTheme`).

---

## 📦 Instalación

Agrega `kit_joss` a las dependencias de tu proyecto `pubspec.yaml`:

```yaml
dependencies:
  kit_joss:
    path: ../kit_joss # O enlace de repositorio Git / paquete
```

---

## 🛠️ Guía de Uso

### 1. Inicialización y Autenticación

```dart
import 'package:kit_joss/kit_joss.dart';

// Configurar cliente de API central
final apiClient = JossApiClient(
  baseUrl: 'https://tu-api.jossred.com',
  apiToken: 'TU_API_TOKEN',
);

// Inicializar servicio de autenticación
final authService = JossAuthService(client: apiClient);
await authService.initialize();

// Iniciar sesión
final result = await authService.login(
  email: 'usuario@joss.com',
  password: 'Password123!',
);

if (result.success) {
  print('Sesión iniciada: ${result.session?.user?.displayName}');
} else if (result.requiresTwoFactor) {
  print('2FA Requerido. Token temporal: ${result.challengeToken}');
} else {
  print('Error: ${result.errorMessage}');
}
```

### 2. Formularios Listos y Desacoplados (UI)

```dart
JossLoginForm(
  onLogin: (email, password) async {
    final res = await authService.login(email: email, password: password);
    // Gestionar resultado...
  },
  onForgotPassword: () => Navigator.pushNamed(context, '/forgot'),
  onRegisterPressed: () => Navigator.pushNamed(context, '/register'),
)
```

### 3. Diálogos y Actualizaciones Remotas

```dart
final updateService = JossUpdateService(
  updateCheckUrl: 'https://tu-servidor.com/check_update',
);

final updateInfo = await updateService.checkForUpdate();
if (updateInfo != null) {
  JossUpdateDialog.show(context, updateInfo: updateInfo);
}
```

### 4. Cifrado y Descifrado Seguro de Datos

```dart
final crypto = JossCrypto();

// Cifrar datos con PBKDF2 (150k iteraciones) + AES-CBC + HMAC
final encrypted = crypto.encryptData('Mis contraseñas secretas', 'miPassword123');

// Descifrar con validación de autenticidad en tiempo constante
final plainText = crypto.decryptData(encrypted, 'miPassword123');
```

---

## 🧪 Pruebas Unitarias

Para ejecutar el suite de pruebas:

```bash
flutter test
```
