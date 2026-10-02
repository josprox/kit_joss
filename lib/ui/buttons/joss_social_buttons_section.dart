import 'package:flutter/material.dart';
import '../../l10n/joss_strings.dart';
import '../../models/joss_social_provider.dart';
import 'joss_social_button.dart';

/// Barra de botones sociales para autenticación OAuth (Google, GitHub, Apple, etc.).
/// Muestra un divisor configurable ("O continuar con") y botones con rejilla o fila flexible.
class JossSocialButtonsSection extends StatelessWidget {
  final List<JossSocialProviderInfo> providers;
  final void Function(JossSocialProviderInfo provider)? onProviderSelected;
  final String? loadingProviderId;
  final String? dividerText;
  final JossStrings? strings;
  final bool iconOnly;

  const JossSocialButtonsSection({
    super.key,
    required this.providers,
    this.onProviderSelected,
    this.loadingProviderId,
    this.dividerText,
    this.strings,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) return const SizedBox.shrink();

    final s = strings ?? JossScope.of(context);
    final text = dividerText ?? s.orContinueWith;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20.0),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.18))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.white.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.18))),
          ],
        ),
        const SizedBox(height: 18.0),
        if (iconOnly || providers.length > 2)
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.center,
            children: providers.map((p) {
              return JossSocialButton(
                provider: p,
                iconOnly: iconOnly,
                isLoading: loadingProviderId == p.id,
                onPressed: () => onProviderSelected?.call(p),
              );
            }).toList(),
          )
        else
          Row(
            children: providers.map((p) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: JossSocialButton(
                    provider: p,
                    iconOnly: false,
                    isLoading: loadingProviderId == p.id,
                    onPressed: () => onProviderSelected?.call(p),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
