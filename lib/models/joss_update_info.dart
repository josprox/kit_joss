/// Información de una actualización remota disponible.
class JossUpdateInfo {
  final String version;
  final String title;
  final String description;
  final String downloadUrl;
  final bool isMandatory;
  final String channel;

  const JossUpdateInfo({
    required this.version,
    required this.title,
    required this.description,
    required this.downloadUrl,
    this.isMandatory = false,
    this.channel = 'release',
  });

  factory JossUpdateInfo.fromJson(Map<String, dynamic> json, {String channel = 'release'}) {
    return JossUpdateInfo(
      version: json['Version']?.toString() ?? json['version']?.toString() ?? '1.0.0',
      title: json['Titulo']?.toString() ?? json['title']?.toString() ?? 'Nueva versión disponible',
      description: json['Descripcion']?.toString() ?? json['description']?.toString() ?? '',
      downloadUrl: json['Descarga']?.toString() ?? json['download_url']?.toString() ?? '',
      isMandatory: json['Obligatoria'] == true || json['mandatory'] == true,
      channel: channel,
    );
  }
}
