import 'package:flutter/foundation.dart';
import '../core/client/joss_api_client.dart';
import '../core/storage/joss_storage.dart';
import '../models/joss_session.dart';
import '../models/joss_user.dart';

/// Servicio central de autenticación del ecosistema Joss.
/// Desacoplado de frameworks de UI o administradores de estado (GetX/Provider/BLoC).
/// Implementa [ChangeNotifier] para integrarse nativamente en cualquier proyecto.
class JossAuthService extends ChangeNotifier {
  static const _tokenKey = 'jwt_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _expirationKey = 'token_expiration';

  final JossApiClient client;
  final JossStorage storage;

  JossSession? _currentSession;
  bool _isLoading = true;

  JossAuthService({
    required this.client,
    JossStorage? storage,
  }) : storage = storage ?? JossStorage();

  JossSession? get currentSession => _currentSession;
  JossUser? get currentUser => _currentSession?.user;
  bool get isAuthenticated => _currentSession != null && !_currentSession!.isExpired;
  bool get isLoading => _isLoading;

  /// Inicializa cargando tokens almacenados y validando la sesión.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await storage.read(_tokenKey);
      if (token != null && token.isNotEmpty) {
        final refreshToken = await storage.read(_refreshTokenKey);
        final expString = await storage.read(_expirationKey);

        DateTime? expiresAt;
        if (expString != null) {
          final expSec = int.tryParse(expString);
          if (expSec != null) {
            expiresAt = DateTime.fromMillisecondsSinceEpoch(expSec * 1000);
          }
        }

        _currentSession = JossSession(
          token: token,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );

        // Intentar cargar perfil de usuario si el token sigue vigente
        if (!_currentSession!.isExpired) {
          await fetchUserProfile();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[JossAuthService] Error inicializando sesión: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inicia sesión con correo y contraseña.
  Future<JossAuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post(
        'login',
        body: {
          'email': email.trim(),
          'password': password.trim(),
        },
      );

      final data = Map<String, dynamic>.from(response is Map ? response : {});

      // Verificar si requiere 2FA
      final challengeToken = _extractTwoFactorChallenge(data);
      if (challengeToken != null) {
        return JossAuthResult.twoFactorRequired(challengeToken);
      }

      if (data['status'] == 'success' || data['token'] != null) {
        final session = JossSession.fromLoginResponse(data);
        await _saveSession(session);
        _currentSession = session;
        notifyListeners();
        return JossAuthResult.success(session);
      }

      final msg = data['message']?.toString() ?? 'Error al iniciar sesión';
      return JossAuthResult.failure(msg);
    } catch (e) {
      return JossAuthResult.failure(_extractErrorMessage(e));
    }
  }

  /// Verifica el código OTP de dos factores (2FA).
  Future<JossAuthResult> verifyTwoFactor({
    required String challengeToken,
    required String code,
  }) async {
    try {
      final response = await client.post(
        'verify_2fa',
        body: {
          'challenge_token': challengeToken.trim(),
          'code': code.trim(),
        },
      );

      final data = Map<String, dynamic>.from(response is Map ? response : {});

      if (data['status'] == 'success' || data['token'] != null) {
        final session = JossSession.fromLoginResponse(data);
        await _saveSession(session);
        _currentSession = session;
        notifyListeners();
        return JossAuthResult.success(session);
      }

      return JossAuthResult.failure(data['message']?.toString() ?? 'Código 2FA incorrecto.');
    } catch (e) {
      return JossAuthResult.failure(_extractErrorMessage(e));
    }
  }

  /// Registro de nuevo usuario.
  Future<JossAuthResult> register({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await client.post(
        'register',
        body: {
          'username': username.trim(),
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.trim(),
          'password': password.trim(),
          'confirmPassword': confirmPassword.trim(),
        },
      );

      final data = Map<String, dynamic>.from(response is Map ? response : {});

      if (data['status'] == 'success' || data['token'] != null) {
        if (data['token'] != null) {
          final session = JossSession.fromLoginResponse(data);
          await _saveSession(session);
          _currentSession = session;
          notifyListeners();
          return JossAuthResult.success(session);
        }
        return JossAuthResult.failure(data['message']?.toString() ?? 'Cuenta registrada con éxito.', 'REGISTER_PENDING');
      }

      return JossAuthResult.failure(data['message']?.toString() ?? 'No fue posible registrar la cuenta.');
    } catch (e) {
      return JossAuthResult.failure(_extractErrorMessage(e));
    }
  }

  /// Solicita el restablecimiento de contraseña.
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await client.post(
        'forgot-password',
        body: {'email': email.trim()},
      );
      return response is Map && (response['status'] == 'success' || response['success'] == true);
    } catch (e) {
      return false;
    }
  }

  /// Cierra la sesión activa y elimina las llaves seguras.
  Future<void> logout() async {
    _currentSession = null;
    await storage.delete(_tokenKey);
    await storage.delete(_refreshTokenKey);
    await storage.delete(_expirationKey);
    notifyListeners();
  }

  /// Consulta el perfil del usuario autenticado.
  Future<JossUser?> fetchUserProfile() async {
    final token = _currentSession?.token;
    if (token == null) return null;

    try {
      final response = await client.get('profile', userToken: token);
      if (response is Map) {
        final userData = response['user'] ?? response['profile'] ?? response;
        if (userData is Map) {
          final user = JossUser.fromJson(Map<String, dynamic>.from(userData));
          _currentSession = JossSession(
            token: token,
            refreshToken: _currentSession?.refreshToken,
            expiresAt: _currentSession?.expiresAt,
            user: user,
          );
          notifyListeners();
          return user;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[JossAuthService] Error obteniendo perfil: $e');
    }
    return null;
  }

  Future<void> _saveSession(JossSession session) async {
    await storage.write(_tokenKey, session.token);
    if (session.refreshToken != null) {
      await storage.write(_refreshTokenKey, session.refreshToken!);
    }
    if (session.expiresAt != null) {
      final seconds = session.expiresAt!.millisecondsSinceEpoch ~/ 1000;
      await storage.write(_expirationKey, seconds.toString());
    }
  }

  String? _extractTwoFactorChallenge(Map<String, dynamic> data) {
    final status = data['status']?.toString().trim().toLowerCase();
    final rawToken = data['challenge_token'] ??
        data['challengeToken'] ??
        data['temp_token'] ??
        data['tempToken'] ??
        (status == '2fa_required' ? data['token'] : null);
    final token = rawToken?.toString().trim();
    if (token == null || token.isEmpty) return null;

    final message = data['message']?.toString().toLowerCase() ?? '';
    final is2Fa = data['requires_2fa'] == true ||
        data['requires2FA'] == true ||
        status == '2fa_required' ||
        message.contains('two factor') ||
        message.contains('2fa');

    return is2Fa ? token : null;
  }

  String _extractErrorMessage(dynamic e) {
    final str = e.toString();
    if (str.contains('Invalid credentials') || str.contains('INVALID_CREDENTIALS')) {
      return 'Credenciales inválidas. Verifica tu correo y contraseña.';
    }
    if (str.contains('Account not verified')) {
      return 'Cuenta no verificada. Revisa tu bandeja de correo.';
    }
    return str.replaceAll('Exception:', '').trim();
  }
}
