/// Modelo inmutable de usuario en el ecosistema Joss.
/// Resuelve las diferencias de deserialización de la API (`Fields` vs propiedades planas).
class JossUser {
  final int? id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final Map<String, dynamic> raw;

  const JossUser({
    this.id,
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.avatarUrl,
    this.raw = const {},
  });

  /// Nombre completo formateado o username / email como fallback.
  String get displayName {
    final full = '$firstName $lastName'.trim();
    if (full.isNotEmpty) return full;
    if (username.isNotEmpty) return username;
    if (email.isNotEmpty) return email;
    return 'Usuario Joss';
  }

  factory JossUser.fromJson(Map<String, dynamic> json) {
    // Normalizar si viene anidado en 'Fields' (backend JossRed)
    Map<String, dynamic> data = json;
    if (json.containsKey('Fields') && json['Fields'] is Map) {
      data = Map<String, dynamic>.from(json['Fields']);
    }

    final rawId = data['id'] ?? data['ID'] ?? data['userId'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    return JossUser(
      id: id,
      username: data['username']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      firstName: data['first_name']?.toString() ?? data['firstName']?.toString() ?? '',
      lastName: data['last_name']?.toString() ?? data['lastName']?.toString() ?? '',
      avatarUrl: data['avatar']?.toString() ?? data['avatar_url']?.toString(),
      raw: Map<String, dynamic>.unmodifiable(data),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'avatar_url': avatarUrl,
        ...raw,
      };
}
