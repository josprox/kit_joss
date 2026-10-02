import 'package:flutter/material.dart';
import '../../forms/joss_validators.dart';
import '../../l10n/joss_strings.dart';
import '../buttons/joss_button.dart';
import '../fields/joss_text_field.dart';

import '../buttons/joss_social_buttons_section.dart';
import '../../models/joss_social_provider.dart';

/// Formulario configurable y reutilizable de inicio de sesión del ecosistema Joss.
class JossLoginForm extends StatefulWidget {
  final Future<void> Function(String email, String password) onLogin;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onRegisterPressed;
  final VoidCallback? onBack;
  final String? title;
  final String? submitText;
  final JossStrings? strings;
  final List<JossSocialProviderInfo>? socialProviders;
  final void Function(JossSocialProviderInfo provider)? onSocialLogin;
  final String? loadingSocialProviderId;

  const JossLoginForm({
    super.key,
    required this.onLogin,
    this.onForgotPassword,
    this.onRegisterPressed,
    this.onBack,
    this.title,
    this.submitText,
    this.strings,
    this.socialProviders,
    this.onSocialLogin,
    this.loadingSocialProviderId,
  });

  @override
  State<JossLoginForm> createState() => _JossLoginFormState();
}

class _JossLoginFormState extends State<JossLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      await widget.onLogin(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings ?? JossScope.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title ?? s.welcomeBack,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 28.0),
          JossTextField(
            controller: _emailController,
            labelText: s.email,
            hintText: s.emailHint,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => JossValidators.email(v, strings: s),
          ),
          const SizedBox(height: 16.0),
          JossTextField(
            controller: _passwordController,
            labelText: s.password,
            hintText: s.passwordHint,
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (v) => JossValidators.password(v, minLength: 1, strings: s),
          ),
          const SizedBox(height: 24.0),
          JossButton(
            label: widget.submitText ?? s.login,
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.onBack != null)
                TextButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.white70),
                  label: Text(s.back, style: const TextStyle(color: Colors.white70)),
                )
              else
                const SizedBox.shrink(),
              if (widget.onForgotPassword != null)
                TextButton(
                  onPressed: widget.onForgotPassword,
                  child: Text(s.forgotPassword, style: const TextStyle(color: Colors.white70)),
                ),
            ],
          ),
          if (widget.onRegisterPressed != null) ...[
            const SizedBox(height: 8.0),
            Center(
              child: TextButton(
                onPressed: widget.onRegisterPressed,
                child: Text(
                  s.noAccountRegister,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
          if (widget.socialProviders != null && widget.socialProviders!.isNotEmpty)
            JossSocialButtonsSection(
              providers: widget.socialProviders!,
              onProviderSelected: widget.onSocialLogin,
              loadingProviderId: widget.loadingSocialProviderId,
              dividerText: s.orSignInWith,
              strings: s,
            ),
        ],
      ),
    );
  }
}
