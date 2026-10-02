import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../errors/joss_exceptions.dart';

/// Cliente HTTP base para el ecosistema Joss.
/// Gestiona headers estándar, prefijos `/api/`, autenticación Bearer y logs.
class JossApiClient {
  final String baseUrl;
  final String? apiToken;
  final http.Client _client;

  JossApiClient({
    required this.baseUrl,
    this.apiToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Retorna la URL raíz sin /api ni diagonal al final.
  String get rootUrl {
    var base = baseUrl.trim();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (base.endsWith('/api')) {
      base = base.substring(0, base.length - 4);
    }
    return base;
  }

  /// Normaliza la URL eliminando diagonales y manejando `/api`.
  Uri buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final finalUrl = '$rootUrl/api/$cleanEndpoint';

    final uri = Uri.parse(finalUrl);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())));
    }
    return uri;
  }

  /// Construye los headers HTTP agregando autorización Bearer (del token de app o de sesión).
  Map<String, String> defaultHeaders({String? userToken}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (userToken != null && userToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $userToken';
    } else if (apiToken != null && apiToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiToken';
    }

    return headers;
  }

  /// Petición GET tipada.
  Future<dynamic> get(
    String endpoint, {
    String? userToken,
    Map<String, dynamic>? queryParameters,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = buildUri(endpoint, queryParameters);
    try {
      if (kDebugMode) debugPrint('[JossApiClient GET] $uri');
      final response = await _client.get(
        uri,
        headers: defaultHeaders(userToken: userToken),
      ).timeout(timeout);

      return _processResponse(response);
    } on JossException {
      rethrow;
    } catch (e) {
      throw JossNetworkException('Error de conexión al consultar $endpoint: $e', details: e);
    }
  }

  /// Petición POST tipada.
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? userToken,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final uri = buildUri(endpoint);
    try {
      if (kDebugMode) debugPrint('[JossApiClient POST] $uri');
      final response = await _client.post(
        uri,
        headers: defaultHeaders(userToken: userToken),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(timeout);

      return _processResponse(response);
    } on JossException {
      rethrow;
    } catch (e) {
      throw JossNetworkException('Error de conexión al enviar datos a $endpoint: $e', details: e);
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = (decoded is Map && decoded['message'] != null)
        ? decoded['message'].toString()
        : 'Error HTTP ${response.statusCode}';

    throw JossNetworkException(
      message,
      statusCode: response.statusCode,
      details: decoded,
    );
  }
}
