import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.dark = false});

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: dark
                  ? const [AppTheme.bgDark, AppTheme.bgMid, Color(0xFF24164F)]
                  : const [
                      Color(0xFFF8FAFC),
                      Color(0xFFEFF6FF),
                      Color(0xFFF5F3FF),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -70,
          child: _GlowBlob(
            size: 220,
            color: dark
                ? AppTheme.cyan.withValues(alpha: 0.25)
                : AppTheme.cyan.withValues(alpha: 0.18),
          ),
        ),
        Positioned(
          bottom: -90,
          left: -80,
          child: _GlowBlob(
            size: 260,
            color: dark
                ? AppTheme.violet.withValues(alpha: 0.28)
                : AppTheme.violet.withValues(alpha: 0.14),
          ),
        ),
        Positioned(
          top: 180,
          left: -45,
          child: _GlowBlob(
            size: 120,
            color: dark
                ? AppTheme.lime.withValues(alpha: 0.14)
                : AppTheme.lime.withValues(alpha: 0.20),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 18)],
      ),
    );
  }
}
