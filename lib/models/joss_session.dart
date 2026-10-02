import 'joss_user.dart';

/// Modelo de sesión y tokens de autenticación Joss.
class JossSession {
  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final JossUser? user;

  const JossSession({
    required this.token,
    this.refreshToken,
    this.expiresAt,
    this.user,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  factory JossSession.fromLoginResponse(
    Map<String, dynamic> data, {
    JossUser? user,
  }) {
    final token = data['token']?.toString() ?? '';
    final refreshToken = data['refresh_token']?.toString() ?? data['refreshToken']?.toString();
    final expiresIn = data['expires_in'] ?? data['expiresIn'];

    DateTime? expires;
    if (expiresIn != null) {
      final seconds = expiresIn is int ? expiresIn : int.tryParse(expiresIn.toString()) ?? 0;
      if (seconds > 0) {
        expires = DateTime.now().add(Duration(seconds: seconds));
      }
    }

    final parsedUser = user ??
        (data['user'] is Map ? JossUser.fromJson(Map<String, dynamic>.from(data['user'])) : null);

    return JossSession(
      token: token,
      refreshToken: refreshToken,
      expiresAt: expires,
      user: parsedUser,
    );
  }
}

/// Resultado de una operación de autenticación (Login, Registro, 2FA).
class JossAuthResult {
  final bool success;
  final bool requiresTwoFactor;
  final String? challengeToken;
  final JossSession? session;
  final String? errorMessage;
  final String? errorCode;

  const JossAuthResult._({
    required this.success,
    this.requiresTwoFactor = false,
    this.challengeToken,
    this.session,
    this.errorMessage,
    this.errorCode,
  });

  factory JossAuthResult.success(JossSession session) => JossAuthResult._(
        success: true,
        session: session,
      );

  factory JossAuthResult.twoFactorRequired(String challengeToken) => JossAuthResult._(
        success: false,
        requiresTwoFactor: true,
        challengeToken: challengeToken,
      );

  factory JossAuthResult.failure(String message, [String? code]) => JossAuthResult._(
        success: false,
        errorMessage: message,
        errorCode: code,
      );
}
