import 'package:flutter/material.dart';

enum JossButtonVariant { filled, outlined, tonal, text }

/// Botón oficial y configurable del ecosistema Joss.
/// Provee soporte nativo para estados de carga (loading), iconos, variantes visuales
/// y full-width responsivo.
class JossButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final JossButtonVariant variant;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const JossButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = JossButtonVariant.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.width = double.infinity,
    this.height = 52.0,
    this.borderRadius,
  });

  const JossButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width = double.infinity,
    this.height = 52.0,
    this.borderRadius,
  }) : variant = JossButtonVariant.outlined;

  const JossButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 44.0,
    this.borderRadius,
  }) : variant = JossButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(16);

    Widget content;
    if (isLoading) {
      content = const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      );
    }

    Widget button;
    switch (variant) {
      case JossButtonVariant.filled:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? theme.colorScheme.primary,
            foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: radius),
            elevation: 0,
          ),
          child: content,
        );
        break;

      case JossButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? theme.colorScheme.primary,
            side: BorderSide(color: backgroundColor ?? theme.colorScheme.primary),
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: content,
        );
        break;

      case JossButtonVariant.tonal:
        button = FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: content,
        );
        break;

      case JossButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? theme.colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: content,
        );
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: button,
    );
  }
}
