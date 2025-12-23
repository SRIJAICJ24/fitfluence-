import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import 'dart:math' as math;

class PrismaticBorder extends StatefulWidget {
  final Widget child;
  final bool isPr;

  const PrismaticBorder({super.key, required this.child, required this.isPr});

  @override
  State<PrismaticBorder> createState() => _PrismaticBorderState();
}

class _PrismaticBorderState extends State<PrismaticBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPr) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: SweepGradient(
              colors: const [
                AppColors.volt,
                Colors.purple,
                Colors.cyan,
                AppColors.volt,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
          padding: const EdgeInsets.all(2), // Border width
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppColors.deepSlate,
            ),
            child: widget.child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
