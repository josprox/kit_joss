import 'package:flutter/material.dart';
import '../../forms/joss_validators.dart';
import '../buttons/joss_button.dart';
import '../fields/joss_text_field.dart';

/// Formulario reutilizable para el desafío de doble factor (2FA/TOTP).
class JossTwoFactorForm extends StatefulWidget {
  final Future<void> Function(String code) onVerify;
  final VoidCallback onBack;
  final String title;
  final String description;

  const JossTwoFactorForm({
    super.key,
    required this.onVerify,
    required this.onBack,
    this.title = 'Autenticación de dos factores',
    this.description = 'Ingresa el código de 6 dígitos generado por tu aplicación autenticadora.',
  });

  @override
  State<JossTwoFactorForm> createState() => _JossTwoFactorFormState();
}

class _JossTwoFactorFormState extends State<JossTwoFactorForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      await widget.onVerify(_codeController.text.trim());
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
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 14),
          ),
          const SizedBox(height: 28),
          JossTextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            labelText: 'Código de verificación',
            hintText: '123456',
            prefixIcon: Icons.security_rounded,
            validator: JossValidators.twoFactorCode,
          ),
          const SizedBox(height: 24),
          JossButton(
            label: 'Verificar y continuar',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: widget.onBack,
              child: const Text('Volver al inicio de sesión', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }
}
