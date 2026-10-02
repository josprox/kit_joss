import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../errors/joss_exceptions.dart';

/// Implementación estándar de criptografía para el ecosistema Joss.
/// Utiliza PBKDF2 (150,000 iteraciones), cifrado AES-256-CBC y HMAC-SHA256
/// para garantizar la integridad y confidencialidad en copias de seguridad
/// y transmisión de secretos.
class JossCrypto {
  static const _version = 'v2';
  static const _iterations = 150000;
  static const _saltLength = 16;
  static const _ivLength = 16;
  static const _keyLength = 32;

  final Random _secureRandom;

  JossCrypto({Random? random}) : _secureRandom = random ?? Random.secure();

  Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _secureRandom.nextInt(256)),
    );
  }

  Uint8List _pbkdf2(String password, Uint8List salt, int iterations) {
    var blockIndex = 1;
    final result = <int>[];
    final passwordBytes = utf8.encode(password);

    while (result.length < _keyLength * 2) {
      final block = BytesBuilder()
        ..add(salt)
        ..add([
          (blockIndex >> 24) & 0xff,
          (blockIndex >> 16) & 0xff,
          (blockIndex >> 8) & 0xff,
          blockIndex & 0xff,
        ]);

      var u = Hmac(sha256, passwordBytes).convert(block.toBytes()).bytes;
      final output = List<int>.from(u);

      for (var i = 1; i < iterations; i++) {
        u = Hmac(sha256, passwordBytes).convert(u).bytes;
        for (var j = 0; j < output.length; j++) {
          output[j] ^= u[j];
        }
      }

      result.addAll(output);
      blockIndex++;
    }

    return Uint8List.fromList(result.take(_keyLength * 2).toList());
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  /// Cifra texto plano utilizando una contraseña maestra.
  String encryptData(String plainText, String password) {
    try {
      final salt = _randomBytes(_saltLength);
      final keyMaterial = _pbkdf2(password, salt, _iterations);
      final encryptionKey = encrypt.Key(keyMaterial.sublist(0, _keyLength));
      final macKey = keyMaterial.sublist(_keyLength, _keyLength * 2);
      final iv = encrypt.IV(_randomBytes(_ivLength));
      final encrypter = encrypt.Encrypter(
        encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc),
      );

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      final salt64 = base64Encode(salt);
      final iv64 = iv.base64;
      final cipher64 = encrypted.base64;
      final payload = '$_version:$_iterations:$salt64:$iv64:$cipher64';
      final mac = Hmac(sha256, macKey).convert(utf8.encode(payload));

      return '$payload:${base64Encode(mac.bytes)}';
    } catch (e) {
      throw JossCryptoException('Error al cifrar datos: $e', details: e);
    }
  }

  /// Descifra una cadena previamente cifrada con formato v2 o retrocompatible.
  String decryptData(String encryptedText, String password) {
    try {
      final parts = encryptedText.split(':');

      if (parts.length == 6 && parts[0] == _version) {
        final iterations = int.parse(parts[1]);
        final salt = Uint8List.fromList(base64Decode(parts[2]));
        final keyMaterial = _pbkdf2(password, salt, iterations);
        final encryptionKey = encrypt.Key(keyMaterial.sublist(0, _keyLength));
        final macKey = keyMaterial.sublist(_keyLength, _keyLength * 2);

        final payload = parts.take(5).join(':');
        final expectedMac = Hmac(sha256, macKey).convert(utf8.encode(payload));
        final actualMac = base64Decode(parts[5]);

        if (!_constantTimeEquals(expectedMac.bytes, actualMac)) {
          throw const JossCryptoException('Los datos cifrados han sido alterados (MAC inválido).');
        }

        final iv = encrypt.IV.fromBase64(parts[3]);
        final encryptedData = encrypt.Encrypted.fromBase64(parts[4]);
        final encrypter = encrypt.Encrypter(
          encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc),
        );
        return encrypter.decrypt(encryptedData, iv: iv);
      }

      // Soporte retrocompatible legado (versión de 2 partes sin HMAC)
      if (parts.length == 2) {
        final legacyKeyBytes = sha256.convert(utf8.encode(password)).bytes;
        final legacyKey = encrypt.Key(Uint8List.fromList(legacyKeyBytes));
        final iv = encrypt.IV.fromBase64(parts[0]);
        final encryptedData = encrypt.Encrypted.fromBase64(parts[1]);
        final encrypter = encrypt.Encrypter(
          encrypt.AES(legacyKey, mode: encrypt.AESMode.cbc),
        );
        return encrypter.decrypt(encryptedData, iv: iv);
      }

      throw const JossCryptoException('Formato de datos cifrados no reconocido.');
    } on JossCryptoException {
      rethrow;
    } catch (e) {
      throw JossCryptoException('Contraseña incorrecta o contenido corrupto: $e', details: e);
    }
  }
}
