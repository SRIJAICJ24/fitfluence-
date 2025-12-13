import 'package:flutter/material.dart';
import 'liquid_orb_nav.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Main content
          child,

          // Floating Orb Navigation
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(child: LiquidOrbNav()),
          ),
        ],
      ),
    );
  }
}
