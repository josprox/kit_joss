/// Comparador e inspector de versiones de aplicación (soporta SemVer, build numbers y sufijos v).
class JossVersion {
  final String raw;
  final List<int> parts;
  final int buildNumber;

  JossVersion._(this.raw, this.parts, this.buildNumber);

  factory JossVersion.parse(String versionString) {
    final clean = versionString.trim().replaceAll(RegExp(r'^[vV]'), '');
    final buildSplit = clean.split('+');
    final versionCore = buildSplit[0];
    final build = buildSplit.length > 1 ? int.tryParse(buildSplit[1]) ?? 0 : 0;

    final dotParts = versionCore.split('.');
    final parts = <int>[];
    for (final part in dotParts) {
      final sanitized = part.replaceAll(RegExp(r'[^0-9]'), '');
      parts.add(int.tryParse(sanitized) ?? 0);
    }

    return JossVersion._(versionString, parts, build);
  }

  /// Comprueba si esta versión es estrictamente mayor que [other].
  bool isGreaterThan(JossVersion other) {
    final maxLen = parts.length > other.parts.length ? parts.length : other.parts.length;
    for (int i = 0; i < maxLen; i++) {
      final p1 = i < parts.length ? parts[i] : 0;
      final p2 = i < other.parts.length ? other.parts[i] : 0;
      if (p1 > p2) return true;
      if (p1 < p2) return false;
    }
    return buildNumber > other.buildNumber;
  }

  /// Compara si [candidateStr] es mayor que [currentStr].
  static bool isVersionGreater(String candidateStr, String currentStr) {
    return JossVersion.parse(candidateStr).isGreaterThan(JossVersion.parse(currentStr));
  }

  @override
  String toString() => raw;
}
