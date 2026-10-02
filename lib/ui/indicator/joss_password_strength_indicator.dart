import 'package:flutter/material.dart';

/// Indicador visual de seguridad y fuerza de contraseñas para el ecosistema Joss.
/// Unifica la implementación duplicada entre Joss-Auth y JossRed-Flutter.
class JossPasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final String? title;
  final bool showRequirements;
  final Color validColor;
  final Color invalidColor;

  const JossPasswordStrengthIndicator({
    super.key,
    required this.password,
    this.title = 'Requisitos de la contraseña:',
    this.showRequirements = true,
    this.validColor = const Color(0xFF00B894),
    this.invalidColor = Colors.white38,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final hasMinLength = password.length >= 8;
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int score = 0;
    if (hasMinLength) score++;
    if (hasUpperCase) score++;
    if (hasLowerCase) score++;
    if (hasNumber) score++;
    if (hasSpecialChar) score++;

    final progress = score / 5.0;

    Color barColor = Colors.redAccent;
    String strengthText = 'Muy débil';

    if (score >= 4) {
      barColor = validColor;
      strengthText = 'Fuerte';
    } else if (score >= 3) {
      barColor = const Color(0xFFFDCB6E);
      strengthText = 'Media';
    } else if (score >= 2) {
      barColor = Colors.orangeAccent;
      strengthText = 'Débil';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Seguridad: $strengthText',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: barColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
          ),
        ),
        if (showRequirements) ...[
          const SizedBox(height: 12),
          if (title != null)
            Text(
              title!,
              style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 6),
          _buildItem('Mínimo 8 caracteres', hasMinLength),
          _buildItem('Una letra mayúscula', hasUpperCase),
          _buildItem('Una letra minúscula', hasLowerCase),
          _buildItem('Al menos un número', hasNumber),
          _buildItem('Un carácter especial (!@#\$%^&*)', hasSpecialChar),
        ],
      ],
    );
  }

  Widget _buildItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 14,
            color: isValid ? validColor : invalidColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isValid ? Colors.white : invalidColor,
            ),
          ),
        ],
      ),
    );
  }
}
