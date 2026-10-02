import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/client/joss_api_client.dart';
import '../core/storage/joss_storage.dart';
import '../models/joss_session.dart';
import '../models/joss_social_provider.dart';
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

  /// Establece manualmente la sesión activa (p.ej. tras un OAuth callback externo o deep link)
  void setSession(JossSession session) {
    _currentSession = session;
    notifyListeners();
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

  /// Obtiene la lista de proveedores sociales habilitados en el backend.
  Future<List<JossSocialProviderInfo>> getSocialProviders() async {
    try {
      final response = await client.get('auth/social/providers');
      if (response is Map && response['providers'] is List) {
        final list = response['providers'] as List;
        return list
            .map((e) => JossSocialProviderInfo.fromString(e.toString()))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('[JossAuthService] Error obteniendo proveedores OAuth: $e');
      return [];
    }
  }

  /// Obtiene la URL de redirección hacia el proveedor OAuth (Google, GitHub, etc.).
  Future<JossSocialRedirectResponse> getSocialAuthUrl({
    required String provider,
    String? redirectUri,
    String? state,
  }) async {
    final queryParams = <String, dynamic>{
      'provider': provider.trim().toLowerCase(),
    };
    if (redirectUri != null && redirectUri.isNotEmpty) {
      queryParams['redirect_uri'] = redirectUri;
    }
    if (state != null && state.isNotEmpty) {
      queryParams['state'] = state;
    }

    final response = await client.get('auth/social/redirect', queryParameters: queryParams);
    if (response is Map) {
      return JossSocialRedirectResponse.fromJson(Map<String, dynamic>.from(response));
    }
    throw Exception('Respuesta inválida al solicitar redirección OAuth');
  }

  /// Inicia el flujo OAuth abriendo el navegador del sistema o in-app webview.
  /// Retorna la URL de autorización que fue abierta.
  Future<String> launchSocialAuth({
    required String provider,
    String? redirectUri,
    String? state,
    LaunchMode launchMode = LaunchMode.externalApplication,
  }) async {
    final res = await getSocialAuthUrl(
      provider: provider,
      redirectUri: redirectUri,
      state: state,
    );

    final uri = Uri.parse(res.authUrl);
    final launched = await launchUrl(uri, mode: launchMode);
    if (!launched) {
      throw Exception('No se pudo abrir el navegador para autenticar con $provider');
    }
    return res.authUrl;
  }

  /// Procesa el callback del proveedor OAuth intercambiando el código de autorización
  /// por la sesión/token de usuario en Joss.
  Future<JossAuthResult> loginWithSocialCallback({
    required String provider,
    required String code,
    String? redirectUri,
  }) async {
    try {
      final body = <String, dynamic>{
        'provider': provider.trim().toLowerCase(),
        'code': code.trim(),
      };
      if (redirectUri != null && redirectUri.isNotEmpty) {
        body['redirect_uri'] = redirectUri.trim();
      }

      final response = await client.post(
        'auth/social/callback',
        body: body,
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

      final msg = data['message']?.toString() ?? 'Error al autenticar con $provider';
      return JossAuthResult.failure(msg);
    } catch (e) {
      return JossAuthResult.failure(_extractErrorMessage(e));
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
