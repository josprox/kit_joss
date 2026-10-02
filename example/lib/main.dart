import 'package:flutter/material.dart';
import 'package:kit_joss/kit_joss.dart';

void main() {
  runApp(const JossExampleApp());
}

class JossExampleApp extends StatelessWidget {
  const JossExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const jossTheme = JossTheme();

    return MaterialApp(
      title: 'Joss Kit Showcase',
      theme: jossTheme.toThemeData(),
      home: const JossKitShowcaseScreen(),
    );
  }
}

class JossKitShowcaseScreen extends StatefulWidget {
  const JossKitShowcaseScreen({super.key});

  @override
  State<JossKitShowcaseScreen> createState() => _JossKitShowcaseScreenState();
}

class _JossKitShowcaseScreenState extends State<JossKitShowcaseScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ecosistema Joss • Kit Showcase'),
        centerTitle: true,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.touch_app_rounded), label: 'UI & Buttons'),
          NavigationDestination(icon: Icon(Icons.login_rounded), label: 'Auth Forms'),
          NavigationDestination(icon: Icon(Icons.system_update_rounded), label: 'Updates'),
        ],
      ),
      body: JossAnimatedBackground(
        child: IndexedStack(
          index: _currentTabIndex,
          children: const [
            _UiKitSection(),
            _AuthSection(),
            _UpdatesSection(),
          ],
        ),
      ),
    );
  }
}

class _UiKitSection extends StatelessWidget {
  const _UiKitSection();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Botones Oficiales (JossButton)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          JossButton(
            label: 'Botón Primario (Filled)',
            icon: Icons.check_circle_outline,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          JossButton(
            label: 'Botón con Estado de Carga',
            isLoading: true,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          JossButton.outlined(
            label: 'Botón Outlined',
            icon: Icons.refresh,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          JossButton.text(
            label: 'Botón Texto / Enlace',
            onPressed: () {},
          ),
          const SizedBox(height: 32),
          const Text(
            'Indicador de Contraseña',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const JossPasswordStrengthIndicator(password: 'Joss2026!'),
        ],
      ),
    );
  }
}

class _AuthSection extends StatelessWidget {
  const _AuthSection();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        color: const Color(0xFF1B1F33).withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: JossLoginForm(
            onLogin: (email, pass) async {
              await Future.delayed(const Duration(seconds: 1));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Simulación de login exitoso para: $email')),
                );
              }
            },
            onForgotPassword: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ir a recuperación de contraseña')),
              );
            },
            onRegisterPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ir a registro de usuario')),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UpdatesSection extends StatelessWidget {
  const _UpdatesSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_download_outlined, size: 64, color: Color(0xFF6C5CE7)),
            const SizedBox(height: 16),
            const Text(
              'Prueba de Diálogo de Actualización',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'Permite desplegar alertas modales o pantallas completas configurables con soporte SemVer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            JossButton(
              label: 'Ver Diálogo de Actualización',
              icon: Icons.open_in_new,
              onPressed: () {
                JossUpdateDialog.show(
                  context,
                  updateInfo: const JossUpdateInfo(
                    version: '2.5.0',
                    title: '¡Nueva Versión de JossRed / Estrella!',
                    description:
                        '• Nueva librería unificada kit_joss.\n• Mejoras de rendimiento en sincronización.\n• Corrección de seguridad en cifrado de contraseñas.',
                    downloadUrl: 'https://github.com/josprox',
                    isMandatory: false,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
