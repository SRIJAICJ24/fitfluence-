import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../glassmorphic/glass_container.dart';

class LiquidOrbNav extends StatefulWidget {
  const LiquidOrbNav({super.key});

  @override
  State<LiquidOrbNav> createState() => _LiquidOrbNavState();
}

class _LiquidOrbNavState extends State<LiquidOrbNav> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _expandAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _rotateAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    ); // 0.125 * 360 = 45 degrees
  }

  void _toggleMenu() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return SizedBox(
      height: 200, // Touch area
      width: 300,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Satellite Buttons (Home)
          _buildSatellite(
            angle: -1, // Left
            icon: Icons.home_rounded,
            label: 'Home',
            isActive: location == '/home',
            onTap: () => context.go('/home'),
          ),
          // Satellite Buttons (Pulse/Gym)
          _buildSatellite(
            angle: 0, // Center Top
            icon: Icons.flash_on_rounded, // Pulse / Gyms
            label: 'Pulse',
            isActive: location.startsWith('/gym-search'),
            onTap: () => context.go('/gym-search'),
          ),
           // Satellite Buttons (Profile)
          _buildSatellite(
            angle: 1, // Right
            icon: Icons.person_rounded,
            label: 'Profile',
            isActive: location.startsWith('/profile'),
            onTap: () => context.go('/profile'),
          ),

          // The Liquid Orb (Main FAB)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              height: 70,
              width: 70,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.volt, AppColors.teal],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.volt.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: RotationTransition(
                turns: _rotateAnimation,
                child: const Icon(Icons.fitness_center_rounded, color: AppColors.deepSlate, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatellite({
    required double angle, // -1 (left), 0 (top), 1 (right)
    required IconData icon, 
    required String label, 
    required bool isActive,
    required VoidCallback onTap,
  }) {
    // Calculate position based on angle
    // Radius = 90
    final double rad = 90;
    // Map -1..1 to angles: -45 deg, 0 deg (actually 90 up), 45 deg? 
    // Let's optimize: Left (-80, -60), Top (0, -100), Right (80, -60)
    
    double dx = 0;
    double dy = 0;
    if (angle == -1) { dx = -80; dy = -60; }
    if (angle == 0) { dx = 0; dy = -110; }
    if (angle == 1) { dx = 80; dy = -60; }

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final double animVal = _expandAnimation.value;
        return Positioned(
          bottom: 20 + (dy * animVal).abs(), // Move UP
          left: 150 - 25 + (dx * animVal), // Center X (150) - half width (25) + offset
          child: Opacity(
            opacity: animVal,
            child: Transform.scale(
              scale: animVal,
              child: GestureDetector(
                onTap: () {
                   _toggleMenu();
                   onTap();
                },
                child: Column(
                  children: [
                    GlassContainer(
                       padding: const EdgeInsets.all(12),
                       borderRadius: 50,
                       child: Icon(icon, color: isActive ? AppColors.volt : Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                      child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
