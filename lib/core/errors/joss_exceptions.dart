/// Excepciones base y específicas para el ecosistema Joss.
class JossException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const JossException(this.message, {this.code, this.details});

  @override
  String toString() => 'JossException(code: $code, message: $message)';
}

/// Error de red o comunicación HTTP con APIs Joss.
class JossNetworkException extends JossException {
  final int? statusCode;

  const JossNetworkException(
    super.message, {
    super.code = 'NETWORK_ERROR',
    this.statusCode,
    super.details,
  });

  @override
  String toString() =>
      'JossNetworkException(status: $statusCode, code: $code, message: $message)';
}

/// Error específico durante el flujo de autenticación o validación de tokens.
class JossAuthException extends JossException {
  const JossAuthException(
    super.message, {
    super.code = 'AUTH_ERROR',
    super.details,
  });
}

/// Error durante operaciones criptográficas (cifrado, descifrado, MAC).
class JossCryptoException extends JossException {
  const JossCryptoException(
    super.message, {
    super.code = 'CRYPTO_ERROR',
    super.details,
  });
}
