import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kit_joss/kit_joss.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Domain Independence & URL resolution in JossApiClient', () {
    test('normaliza URLs con diagonales o sufijo /api dinámicamente', () {
      final client1 = JossApiClient(baseUrl: 'https://joss.red/');
      expect(client1.rootUrl, equals('https://joss.red'));

      final client2 = JossApiClient(baseUrl: 'https://custom-domain.org/api');
      expect(client2.rootUrl, equals('https://custom-domain.org'));

      final client3 = JossApiClient(baseUrl: 'https://otro-dominio.com/api/');
      expect(client3.rootUrl, equals('https://otro-dominio.com'));

      final client4 = JossApiClient(baseUrl: 'http://192.168.1.100:9000');
      expect(client4.rootUrl, equals('http://192.168.1.100:9000'));
    });

    test('construye URIs API correctamente para cualquier endpoint', () {
      final client = JossApiClient(baseUrl: 'https://mi-dominio-nuevo.com');
      final uri = client.buildUri('auth/social/callback');
      expect(uri.toString(), equals('https://mi-dominio-nuevo.com/api/auth/social/callback'));

      final uriWithQuery = client.buildUri('auth/social/redirect', {'provider': 'google', 'state': 'mobile'});
      expect(uriWithQuery.queryParameters['provider'], equals('google'));
      expect(uriWithQuery.queryParameters['state'], equals('mobile'));
    });
  });

  group('OAuth Social Redirect URL Tests', () {
    test('obtiene URL de redirección con parámetros completos', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/api/auth/social/redirect'));
        expect(request.url.queryParameters['provider'], equals('google'));
        expect(request.url.queryParameters['state'], equals('mobile'));

        return http.Response(
          jsonEncode({
            'status': 'success',
            'provider': 'google',
            'auth_url': 'https://accounts.google.com/o/oauth2/v2/auth?client_id=123&redirect_uri=https://mi-dominio.com/auth/google/callback&state=mobile',
            'redirect_uri': 'https://mi-dominio.com/auth/google/callback',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = JossApiClient(baseUrl: 'https://mi-dominio.com', client: mockClient);
      final authService = JossAuthService(client: apiClient);

      final res = await authService.getSocialAuthUrl(
        provider: 'google',
        state: 'mobile',
      );

      expect(res.provider, equals('google'));
      expect(res.authUrl, contains('https://accounts.google.com'));
      expect(res.redirectUri, equals('https://mi-dominio.com/auth/google/callback'));
    });
  });

  group('loginWithSocialCallback Tests', () {
    test('construye redirect_uri dinámicamente con el dominio activo y procesa login exitoso', () async {
      const activeDomain = 'https://mi-app-empresa.com';
      late Map<String, dynamic> capturedBody;

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/social/callback') {
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'status': 'success',
              'token': 'jwt_mock_token_12345',
              'refresh_token': 'refresh_mock_token_abc',
              'expires_in': 3600,
              'user': {
                'id': 42,
                'email': 'developer@joss.red',
                'username': 'joss_dev',
                'first_name': 'Joss',
                'last_name': 'Estrada',
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = JossApiClient(baseUrl: activeDomain, client: mockClient);
      final authService = JossAuthService(client: apiClient);

      final result = await authService.loginWithSocialCallback(
        provider: 'Google',
        code: 'auth_code_sample_987',
      );

      // Verifica que el redirect_uri generado dinámicamente coincida con el dominio del cliente
      expect(capturedBody['provider'], equals('google'));
      expect(capturedBody['code'], equals('auth_code_sample_987'));
      expect(capturedBody['redirect_uri'], equals('$activeDomain/auth/google/callback'));

      // Verifica resultado y sesión
      expect(result.success, isTrue);
      expect(result.requiresTwoFactor, isFalse);
      expect(result.session, isNotNull);
      expect(result.session!.token, equals('jwt_mock_token_12345'));
      expect(result.session!.user?.email, equals('developer@joss.red'));
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUser?.username, equals('joss_dev'));
    });

    test('soporta redirectUri personalizado explícito sin alterarlo', () async {
      late Map<String, dynamic> capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'status': 'success',
            'token': 'jwt_custom_token',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = JossApiClient(baseUrl: 'https://joss.red', client: mockClient);
      final authService = JossAuthService(client: apiClient);

      await authService.loginWithSocialCallback(
        provider: 'github',
        code: 'gh_code_123',
        redirectUri: 'https://otro-host.com/auth/github/callback',
      );

      expect(capturedBody['redirect_uri'], equals('https://otro-host.com/auth/github/callback'));
    });

    test('detecta requerimiento de segundo factor (2FA) en social auth', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': '2fa_required',
            'message': 'Two-factor authentication code required.',
            'challenge_token': 'mfa_temp_challenge_token_999',
            'expires_in': 300,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = JossApiClient(baseUrl: 'https://joss.red', client: mockClient);
      final authService = JossAuthService(client: apiClient);

      final result = await authService.loginWithSocialCallback(
        provider: 'google',
        code: 'sample_code',
      );

      expect(result.success, isFalse);
      expect(result.requiresTwoFactor, isTrue);
      expect(result.challengeToken, equals('mfa_temp_challenge_token_999'));
      expect(authService.isAuthenticated, isFalse);
    });

    test('maneja errores de autenticación social adecuadamente', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': 'error',
            'message': 'Authentication failed with google: invalid_grant',
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = JossApiClient(baseUrl: 'https://joss.red', client: mockClient);
      final authService = JossAuthService(client: apiClient);

      final result = await authService.loginWithSocialCallback(
        provider: 'google',
        code: 'expired_code',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('invalid_grant'));
      expect(authService.isAuthenticated, isFalse);
    });
  });

  group('loginWithToken Tests', () {
    test('inicia sesión correctamente a partir de un token directo', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/profile') {
          return http.Response(
            jsonEncode({
              'status': 'success',
              'user': {
                'id': 10,
                'email': 'tokenuser@joss.red',
                'username': 'token_user',
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = JossApiClient(baseUrl: 'https://joss.red', client: mockClient);
      final authService = JossAuthService(client: apiClient);

      final result = await authService.loginWithToken(
        'direct_jwt_sample_token',
        refreshToken: 'refresh_sample',
        expiresIn: 3600,
      );

      expect(result.success, isTrue);
      expect(result.session?.token, equals('direct_jwt_sample_token'));
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUser?.username, equals('token_user'));
    });

    test('rechaza token vacío', () async {
      final authService = JossAuthService(client: JossApiClient(baseUrl: 'https://joss.red'));
      final result = await authService.loginWithToken('');
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Token inválido'));
    });
  });

  group('Multi-domain compatibility guarantee', () {
    test('diferentes instancias con diferentes dominios no se cruzan', () async {
      final clientDomainA = JossApiClient(baseUrl: 'https://app-ventas.com');
      final clientDomainB = JossApiClient(baseUrl: 'https://joss-red.org');

      final authA = JossAuthService(client: clientDomainA);
      final authB = JossAuthService(client: clientDomainB);

      expect(authA.client.rootUrl, equals('https://app-ventas.com'));
      expect(authB.client.rootUrl, equals('https://joss-red.org'));
    });
  });
}
