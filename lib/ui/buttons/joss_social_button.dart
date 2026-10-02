import 'package:flutter/material.dart';
import '../../models/joss_social_provider.dart';

/// Botón estilizado individual para un proveedor OAuth (Google, GitHub, Microsoft, Apple, etc.).
class JossSocialButton extends StatelessWidget {
  final JossSocialProviderInfo provider;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final BorderRadius? borderRadius;
  final bool iconOnly;

  const JossSocialButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
    this.height = 48.0,
    this.borderRadius,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(14.0);

    final bg = _getBackgroundColor(isDark);
    final fg = _getForegroundColor(isDark);
    final border = _getBorderColor(isDark);

    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          side: BorderSide(color: border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: EdgeInsets.symmetric(
            horizontal: iconOnly ? 12.0 : 16.0,
            vertical: 8.0,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProviderIcon(),
                  if (!iconOnly) ...[
                    const SizedBox(width: 10.0),
                    Flexible(
                      child: Text(
                        provider.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildProviderIcon() {
    final id = provider.id.toLowerCase();
    IconData iconData;
    Color? iconColor;

    switch (id) {
      case 'github':
        iconData = Icons.code_rounded;
        break;
      case 'google':
        iconData = Icons.g_mobiledata_rounded;
        break;
      case 'microsoft':
        iconData = Icons.window_rounded;
        break;
      case 'apple':
        iconData = Icons.apple_rounded;
        break;
      case 'facebook':
        iconData = Icons.facebook_rounded;
        break;
      default:
        iconData = Icons.account_circle_outlined;
    }

    return Icon(iconData, size: 22.0, color: iconColor);
  }

  Color _getBackgroundColor(bool isDark) {
    final id = provider.id.toLowerCase();
    if (id == 'apple') {
      return isDark ? Colors.white : Colors.black;
    }
    return isDark ? const Color(0xFF1E2430) : Colors.white;
  }

  Color _getForegroundColor(bool isDark) {
    final id = provider.id.toLowerCase();
    if (id == 'apple') {
      return isDark ? Colors.black : Colors.white;
    }
    return isDark ? Colors.white : const Color(0xFF1E2430);
  }

  Color _getBorderColor(bool isDark) {
    final id = provider.id.toLowerCase();
    if (id == 'apple') {
      return Colors.transparent;
    }
    return isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0);
  }
}
