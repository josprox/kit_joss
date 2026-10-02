import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento seguro resistente y blindado contra fallos del SO.
/// Inspirado en SafeSecureStorage de Estrella Music y probado para prevenir
/// caídas abruptas cuando el Keystore de Android o DPAPI en Windows falla.
class JossStorage {
  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryFallback = {};

  JossStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              wOptions: WindowsOptions(),
            );

  /// Lee un valor de almacenamiento seguro con fallback tolerante.
  Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) return value;
      return _memoryFallback[key];
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[JossStorage] Fallo al leer clave "$key": $e');
        debugPrint(stack.toString());
      }
      return _memoryFallback[key];
    }
  }

  /// Guarda un valor de forma segura.
  Future<bool> write(String key, String value) async {
    _memoryFallback[key] = value;
    try {
      await _storage.write(key: key, value: value);
      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[JossStorage] Fallo al escribir clave "$key": $e');
        debugPrint(stack.toString());
      }
      return false;
    }
  }

  /// Elimina una clave.
  Future<bool> delete(String key) async {
    _memoryFallback.remove(key);
    try {
      await _storage.delete(key: key);
      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[JossStorage] Fallo al eliminar clave "$key": $e');
        debugPrint(stack.toString());
      }
      return false;
    }
  }

  /// Elimina todas las claves.
  Future<bool> deleteAll() async {
    _memoryFallback.clear();
    try {
      await _storage.deleteAll();
      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[JossStorage] Fallo al vaciar almacenamiento: $e');
        debugPrint(stack.toString());
      }
      return false;
    }
  }

  /// Comprueba si existe una clave.
  Future<bool> containsKey(String key) async {
    if (_memoryFallback.containsKey(key)) return true;
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      return _memoryFallback.containsKey(key);
    }
  }
}
