import 'package:flutter/material.dart';
import '../../forms/joss_validators.dart';
import '../../l10n/joss_strings.dart';
import '../buttons/joss_button.dart';
import '../fields/joss_text_field.dart';
import '../indicator/joss_password_strength_indicator.dart';
import '../buttons/joss_social_buttons_section.dart';
import '../../models/joss_social_provider.dart';

/// Formulario configurable y reutilizable de registro del ecosistema Joss.
class JossRegisterForm extends StatefulWidget {
  final Future<void> Function({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) onRegister;
  final VoidCallback onBack;
  final JossStrings? strings;
  final List<JossSocialProviderInfo>? socialProviders;
  final void Function(JossSocialProviderInfo provider)? onSocialLogin;
  final String? loadingSocialProviderId;

  const JossRegisterForm({
    super.key,
    required this.onRegister,
    required this.onBack,
    this.strings,
    this.socialProviders,
    this.onSocialLogin,
    this.loadingSocialProviderId,
  });

  @override
  State<JossRegisterForm> createState() => _JossRegisterFormState();
}

class _JossRegisterFormState extends State<JossRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _currentPassword = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      await widget.onRegister(
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
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
            s.createAccount,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24.0),
          JossTextField(
            controller: _usernameController,
            labelText: s.username,
            hintText: s.usernameHint,
            prefixIcon: Icons.alternate_email,
            validator: (v) => JossValidators.requiredField(v, s.username, strings: s),
          ),
          const SizedBox(height: 14.0),
          Row(
            children: [
              Expanded(
                child: JossTextField(
                  controller: _firstNameController,
                  labelText: s.firstName,
                  hintText: s.firstNameHint,
                  prefixIcon: Icons.person_outline,
                  validator: (v) => JossValidators.requiredField(v, s.firstName, strings: s),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: JossTextField(
                  controller: _lastNameController,
                  labelText: s.lastName,
                  hintText: s.lastNameHint,
                  prefixIcon: Icons.person_outline,
                  validator: (v) => JossValidators.requiredField(v, s.lastName, strings: s),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          JossTextField(
            controller: _emailController,
            labelText: s.email,
            hintText: s.emailHint,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => JossValidators.email(v, strings: s),
          ),
          const SizedBox(height: 14.0),
          JossTextField(
            controller: _passwordController,
            labelText: s.password,
            hintText: s.passwordHint,
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            onChanged: (val) => setState(() => _currentPassword = val),
            validator: (v) => JossValidators.password(v, minLength: 8, strings: s),
          ),
          JossPasswordStrengthIndicator(password: _currentPassword, strings: s),
          const SizedBox(height: 14.0),
          JossTextField(
            controller: _confirmPasswordController,
            labelText: s.confirmPassword,
            hintText: s.confirmPasswordHint,
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (v) => JossValidators.confirmPassword(v, _passwordController.text, strings: s),
          ),
          const SizedBox(height: 24.0),
          JossButton(
            label: s.register,
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 12.0),
          Center(
            child: TextButton(
              onPressed: widget.onBack,
              child: Text(s.alreadyHaveAccount, style: const TextStyle(color: Colors.white70)),
            ),
          ),
          if (widget.socialProviders != null && widget.socialProviders!.isNotEmpty)
            JossSocialButtonsSection(
              providers: widget.socialProviders!,
              onProviderSelected: widget.onSocialLogin,
              loadingProviderId: widget.loadingSocialProviderId,
              dividerText: s.orSignUpWith,
              strings: s,
            ),
        ],
      ),
    );
  }
}
