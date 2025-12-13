import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';

class PhotoUploadScreen extends StatelessWidget {
  const PhotoUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Photos')),
      body: Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt, size: 48),
              SizedBox(height: 16),
              Text('Tap to upload photo'),
            ],
          ),
        ),
      ),
    );
  }
}
