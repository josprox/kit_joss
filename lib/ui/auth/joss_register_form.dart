import 'package:flutter/material.dart';
import '../../forms/joss_validators.dart';
import '../buttons/joss_button.dart';
import '../fields/joss_text_field.dart';
import '../indicator/joss_password_strength_indicator.dart';

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

  const JossRegisterForm({
    super.key,
    required this.onRegister,
    required this.onBack,
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Crear cuenta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24.0),
          JossTextField(
            controller: _usernameController,
            labelText: 'Nombre de usuario',
            hintText: 'jossdev',
            prefixIcon: Icons.alternate_email,
            validator: (v) => JossValidators.requiredField(v, 'El nombre de usuario'),
          ),
          const SizedBox(height: 14.0),
          Row(
            children: [
              Expanded(
                child: JossTextField(
                  controller: _firstNameController,
                  labelText: 'Nombre',
                  hintText: 'Joss',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => JossValidators.requiredField(v, 'El nombre'),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: JossTextField(
                  controller: _lastNameController,
                  labelText: 'Apellido',
                  hintText: 'Estrada',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => JossValidators.requiredField(v, 'El apellido'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          JossTextField(
            controller: _emailController,
            labelText: 'Correo electrónico',
            hintText: 'usuario@joss.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: JossValidators.email,
          ),
          const SizedBox(height: 14.0),
          JossTextField(
            controller: _passwordController,
            labelText: 'Contraseña',
            hintText: 'Crea una contraseña segura',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            onChanged: (val) => setState(() => _currentPassword = val),
            validator: (v) => JossValidators.password(v, minLength: 8),
          ),
          JossPasswordStrengthIndicator(password: _currentPassword),
          const SizedBox(height: 14.0),
          JossTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirmar contraseña',
            hintText: 'Repite tu contraseña',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (v) => JossValidators.confirmPassword(v, _passwordController.text),
          ),
          const SizedBox(height: 24.0),
          JossButton(
            label: 'Registrarse',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 12.0),
          Center(
            child: TextButton(
              onPressed: widget.onBack,
              child: const Text('¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }
}
