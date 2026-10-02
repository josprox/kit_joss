/// Información y metadatos de un proveedor de autenticación social OAuth soportado.
class JossSocialProviderInfo {
  final String id;
  final String name;

  const JossSocialProviderInfo({
    required this.id,
    required this.name,
  });

  factory JossSocialProviderInfo.fromString(String raw) {
    final cleanId = raw.trim().toLowerCase();
    String displayName = cleanId;
    switch (cleanId) {
      case 'google':
        displayName = 'Google';
        break;
      case 'github':
        displayName = 'GitHub';
        break;
      case 'microsoft':
        displayName = 'Microsoft';
        break;
      case 'apple':
        displayName = 'Apple';
        break;
      case 'facebook':
        displayName = 'Facebook';
        break;
      case 'x':
      case 'twitter':
        displayName = 'X (Twitter)';
        break;
      case 'twitch':
        displayName = 'Twitch';
        break;
      case 'yahoo':
        displayName = 'Yahoo';
        break;
      default:
        if (cleanId.isNotEmpty) {
          displayName = '${cleanId[0].toUpperCase()}${cleanId.substring(1)}';
        }
    }

    return JossSocialProviderInfo(
      id: cleanId,
      name: displayName,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JossSocialProviderInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Respuesta de la API al solicitar la URL de redirección OAuth.
class JossSocialRedirectResponse {
  final String provider;
  final String authUrl;
  final String redirectUri;

  const JossSocialRedirectResponse({
    required this.provider,
    required this.authUrl,
    required this.redirectUri,
  });

  factory JossSocialRedirectResponse.fromJson(Map<String, dynamic> json) {
    return JossSocialRedirectResponse(
      provider: json['provider']?.toString() ?? '',
      authUrl: json['auth_url']?.toString() ?? json['authUrl']?.toString() ?? '',
      redirectUri: json['redirect_uri']?.toString() ?? json['redirectUri']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'auth_url': authUrl,
        'redirect_uri': redirectUri,
      };
}
