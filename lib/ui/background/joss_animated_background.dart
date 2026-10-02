import 'dart:math';
import 'package:flutter/material.dart';

/// Fondo animado atmosférico para pantallas de autenticación o portadas.
/// Reutilizable en todas las aplicaciones del ecosistema Joss.
class JossAnimatedBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const JossAnimatedBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  State<JossAnimatedBackground> createState() => _JossAnimatedBackgroundState();
}

class _JossAnimatedBackgroundState extends State<JossAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        const [
          Color(0xFF0F121E),
          Color(0xFF1E1738),
          Color(0xFF14192D),
        ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * pi;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(cos(angle), sin(angle)),
              end: Alignment(-cos(angle), -sin(angle)),
              colors: colors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
