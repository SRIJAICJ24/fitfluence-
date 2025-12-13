import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';

class PhoneOtpScreen extends StatelessWidget {
  const PhoneOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: const Text('PhoneOtpScreen'),
        ),
      ),
    );
  }
}
