import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/joss_update_info.dart';
import '../buttons/joss_button.dart';

/// Diálogo reutilizable de actualización para el ecosistema Joss.
class JossUpdateDialog extends StatelessWidget {
  final JossUpdateInfo updateInfo;
  final VoidCallback? onDismiss;

  const JossUpdateDialog({
    super.key,
    required this.updateInfo,
    this.onDismiss,
  });

  /// Muestra el diálogo en el contexto provisto.
  static Future<void> show(
    BuildContext context, {
    required JossUpdateInfo updateInfo,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !updateInfo.isMandatory,
      builder: (context) => JossUpdateDialog(
        updateInfo: updateInfo,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1B1F33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFF6C5CE7),
                child: Icon(Icons.system_update_rounded, size: 36, color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              updateInfo.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versión disponible: v${updateInfo.version}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF00B894),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (updateInfo.description.isNotEmpty) ...[
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: SingleChildScrollView(
                  child: Text(
                    updateInfo.description,
                    style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            JossButton(
              label: 'Actualizar ahora',
              icon: Icons.download_rounded,
              onPressed: () async {
                final uri = Uri.tryParse(updateInfo.downloadUrl);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            if (!updateInfo.isMandatory) ...[
              const SizedBox(height: 10),
              JossButton.text(
                label: 'Más tarde',
                onPressed: onDismiss ?? () => Navigator.of(context).pop(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
