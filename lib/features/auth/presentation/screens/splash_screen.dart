import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: const Text('SplashScreen'),
        ),
      ),
    );
  }
}
