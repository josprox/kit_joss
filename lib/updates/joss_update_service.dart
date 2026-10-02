import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../core/utils/joss_version.dart';
import '../models/joss_update_info.dart';

/// Servicio centralizado de comprobación y gestión de actualizaciones del ecosistema Joss.
class JossUpdateService {
  final String updateCheckUrl;
  final http.Client _client;

  JossUpdateService({
    required this.updateCheckUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Comprueba si la compilación proviene de Google Play Store o Windows Store
  /// para delegar la actualización a la tienda oficial.
  static Future<bool> isStoreBuild() async {
    try {
      final pInfo = await PackageInfo.fromPlatform();
      final store = pInfo.installerStore?.toLowerCase() ?? '';
      if (store.contains('vending') || store.contains('google') || store.contains('microsoft')) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Consulta el endpoint de actualización y determina si hay una nueva versión.
  Future<JossUpdateInfo?> checkForUpdate({
    String channel = 'release',
    String? currentVersionOverride,
  }) async {
    try {
      if (!kIsWeb && await isStoreBuild()) {
        if (kDebugMode) debugPrint('[JossUpdateService] Compilación gestionada por Store. Omitiendo.');
        return null;
      }

      final uri = Uri.parse(updateCheckUrl).replace(
        queryParameters: {'channel': channel},
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data == null || (data['Version'] == null && data['version'] == null)) return null;

      final updateInfo = JossUpdateInfo.fromJson(data, channel: channel);

      final currentVersion = currentVersionOverride ?? (await PackageInfo.fromPlatform()).version;

      if (JossVersion.isVersionGreater(updateInfo.version, currentVersion)) {
        return updateInfo;
      }

      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('[JossUpdateService] Error al verificar actualizaciones: $e');
      return null;
    }
  }
}
