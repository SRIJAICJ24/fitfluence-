import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/theme.dart';
import '../glassmorphic/glass_container.dart';

class VitalityOrb extends StatefulWidget {
  const VitalityOrb({super.key});

  @override
  State<VitalityOrb> createState() => _VitalityOrbState();
}

class _VitalityOrbState extends State<VitalityOrb> with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _rotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
  }

  @override
  void dispose() {
    _expandController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 250,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Energy Tendrils
          AnimatedBuilder(
            animation: _expandController,
            builder: (context, _) => CustomPaint(
              size: const Size(300, 250),
              painter: _TendrilPainter(
                progress: CurvedAnimation(
                  parent: _expandController,
                  curve: Curves.easeOutBack,
                ).value,
                color: AppColors.volt.withOpacity(0.3),
              ),
            ),
          ),

          // Satellites
          
          // 1. Center (Pulse)
          _buildSatellite(
            targetAngle: 270, 
            distance: 90,
            icon: Icons.bolt_rounded,
            label: 'Pulse',
            color: Colors.white,
            glowColor: AppColors.volt,
            onTap: () => context.push('/pulses'),
            delay: 0,
          ),

          // 2. Left (Home)
          _buildSatellite(
            targetAngle: 210, 
            distance: 80,
            icon: Icons.home_rounded,
            label: 'Home',
            color: Colors.white,
            glowColor: AppColors.cyan,
            onTap: () => context.go('/home'),
            delay: 50,
          ),

          // 3. Right (Profile)
          _buildSatellite(
            targetAngle: 330, 
            distance: 80,
            icon: Icons.person_rounded,
            label: 'Profile',
            color: Colors.white,
            glowColor: AppColors.electricPurple,
            onTap: () {
               final user = Supabase.instance.client.auth.currentUser;
               if (user != null) {
                 context.push('/profile');
               }
            },
            delay: 100,
          ),

          // Central Core
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _toggle();
              },
              onLongPress: () {
                HapticFeedback.heavyImpact();
              },
              child: AnimatedBuilder(
                animation: _expandController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - (_expandController.value * 0.1),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Plasma Ring
                      RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                AppColors.volt.withOpacity(0.0),
                                AppColors.volt.withOpacity(0.5),
                                AppColors.volt.withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      
                      // Glass Sphere
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.indigo.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: -5,
                            ),
                            BoxShadow(
                              color: AppColors.teal.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(color: Colors.white.withOpacity(0.05)),
                          ),
                        ),
                      ),

                      // Icon
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: _isExpanded
                            ? const Icon(Icons.close_rounded, key: ValueKey('close'), color: Colors.white, size: 32)
                            : const Icon(Icons.fitness_center_rounded, key: ValueKey('dumbbell'), color: AppColors.volt, size: 32)
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scaleXY(begin: 1.0, end: 1.2, duration: 800.ms, curve: Curves.easeInOut)
                                .effect(duration: 800.ms, curve: Curves.easeInOut),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatellite({
    required double targetAngle,
    required double distance,
    required IconData icon,
    required String label,
    required Color color,
    required Color glowColor,
    required VoidCallback onTap,
    required int delay,
  }) {
    return AnimatedBuilder(
      animation: _expandController,
      builder: (context, child) {
        final curve = CurvedAnimation(
          parent: _expandController,
          curve: Interval(delay / 600, 1.0, curve: Curves.elasticOut),
        );
        
        final progress = curve.value;
        final rad = targetAngle * (math.pi / 180);
        
        final dx = math.cos(rad) * distance * progress;
        final dy = math.sin(rad) * distance * progress;
        
        return Positioned(
          bottom: 30 - dy, 
          left: 150 + dx - 28, 
          
          child: Transform.scale(
            scale: progress.clamp(0.0, 1.0),
            child: Opacity(
              opacity: progress.clamp(0.0, 1.0),
              child: _GlassButton(
                icon: icon,
                label: label,
                color: color,
                glowColor: glowColor,
                onTap: () {
                   HapticFeedback.lightImpact();
                   onTap();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color glowColor;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.deepSlate.withOpacity(0.6),
              border: Border.all(
                color: _isPressed ? widget.glowColor : Colors.white.withOpacity(0.2),
                width: _isPressed ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isPressed ? widget.glowColor.withOpacity(0.5) : Colors.black26,
                  blurRadius: _isPressed ? 15 : 10,
                  spreadRadius: _isPressed ? 2 : 0,
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: _isPressed ? widget.glowColor : Colors.white70,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: TextStyle(
              color: _isPressed ? widget.glowColor : AppColors.slateGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }
}

class _TendrilPainter extends CustomPainter {
  final double progress;
  final Color color;

  _TendrilPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.1) return;

    final paint = Paint()
      ..color = color.withOpacity((1.0 - progress).clamp(0.0, 1.0))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height - 40);

    final satelliteAngles = [270, 210, 330];
    for (final angle in satelliteAngles) {
      final rad = angle * (math.pi / 180);
      final dist = 80.0 * progress;
      final dx = math.cos(rad) * dist;
      final dy = math.sin(rad) * dist;
      
      canvas.drawLine(center, center + Offset(dx, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TendrilPainter oldDelegate) => 
    oldDelegate.progress != progress;
}
