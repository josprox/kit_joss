import 'package:flutter_test/flutter_test.dart';
import 'package:kit_joss/kit_joss.dart';

void main() {
  group('JossVersion Tests', () {
    test('compara versiones SemVer correctamente', () {
      expect(JossVersion.isVersionGreater('1.2.0', '1.1.9'), isTrue);
      expect(JossVersion.isVersionGreater('2.0.0', '1.9.9'), isTrue);
      expect(JossVersion.isVersionGreater('1.0.0', '1.0.0'), isFalse);
      expect(JossVersion.isVersionGreater('1.0.0', '1.0.1'), isFalse);
    });

    test('soporta prefijo v/V y build numbers (+)', () {
      expect(JossVersion.isVersionGreater('v1.2.0', '1.1.0'), isTrue);
      expect(JossVersion.isVersionGreater('1.1.3+14', '1.1.3+13'), isTrue);
      expect(JossVersion.isVersionGreater('1.1.3+10', '1.1.3+12'), isFalse);
    });
  });

  group('JossValidators Tests', () {
    test('valida correos electrónicos', () {
      expect(JossValidators.email('test@joss.com'), isNull);
      expect(JossValidators.email('test joss@domain.com'), isNotNull);
      expect(JossValidators.email('invalido'), isNotNull);
      expect(JossValidators.email(''), isNotNull);
    });

    test('valida contraseñas y coincidencia', () {
      expect(JossValidators.password('12345678', minLength: 8), isNull);
      expect(JossValidators.password('123', minLength: 6), isNotNull);
      expect(JossValidators.confirmPassword('pass1', 'pass1'), isNull);
      expect(JossValidators.confirmPassword('pass1', 'pass2'), isNotNull);
    });

    test('valida códigos 2FA', () {
      expect(JossValidators.twoFactorCode('123456'), isNull);
      expect(JossValidators.twoFactorCode('12345'), isNotNull);
      expect(JossValidators.twoFactorCode('abcdef'), isNotNull);
    });
  });

  group('JossCrypto Tests', () {
    test('cifra y descifra texto plano con clave', () {
      final crypto = JossCrypto();
      const secretMessage = 'Clave-Secreta-TOTP-Joss-2026';
      const password = 'SuperSecurePassword#123';

      final encrypted = crypto.encryptData(secretMessage, password);
      expect(encrypted, contains(':'));

      final decrypted = crypto.decryptData(encrypted, password);
      expect(decrypted, equals(secretMessage));
    });

    test('falla al descifrar con contraseña incorrecta', () {
      final crypto = JossCrypto();
      final encrypted = crypto.encryptData('Mensaje', 'passCorrecto');

      expect(
        () => crypto.decryptData(encrypted, 'passErroneo'),
        throwsA(isA<JossCryptoException>()),
      );
    });
  });

  group('JossUser & Serialization Tests', () {
    test('deserializa json plano', () {
      final json = {
        'id': 42,
        'username': 'jossprox',
        'email': 'joss@example.com',
        'first_name': 'Joss',
        'last_name': 'Estrada',
      };
      final user = JossUser.fromJson(json);
      expect(user.id, 42);
      expect(user.username, 'jossprox');
      expect(user.displayName, 'Joss Estrada');
    });

    test('deserializa json envuelto en Fields (formato JossRed API)', () {
      final json = {
        'Fields': {
          'id': 99,
          'username': 'music_user',
          'email': 'music@joss.com',
          'firstName': 'Estrella',
          'lastName': 'Fan',
        }
      };
      final user = JossUser.fromJson(json);
      expect(user.id, 99);
      expect(user.username, 'music_user');
      expect(user.displayName, 'Estrella Fan');
    });
  });
}
