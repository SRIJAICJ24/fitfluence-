import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';

class GymDetailScreen extends StatelessWidget {
  final String gymId;

  const GymDetailScreen({super.key, required this.gymId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Gold\'s Gym'),
              background: Image.network(
                'https://placehold.co/600x400/101827/FFF', // Placeholder
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.volt),
                      const SizedBox(width: 4),
                      Text(
                        '4.8 (120 reviews)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  Text('About', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text(
                    'Premium fitness center with state-of-the-art equipment and personal training zones.',
                    style: TextStyle(color: AppColors.slateGrey, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Amenities
                  Text('Amenities', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  const Wrap(
                    spacing: 12, 
                    runSpacing: 12,
                    children: [
                      _AmenityChip(icon: Icons.ac_unit, label: 'AC'),
                      _AmenityChip(icon: Icons.wifi, label: 'WiFi'),
                      _AmenityChip(icon: Icons.shower, label: 'Showers'),
                      _AmenityChip(icon: Icons.local_parking, label: 'Parking'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {}, // Select as my gym
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.volt,
            foregroundColor: AppColors.deepSlate,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Select This Gym'),
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.volt),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
