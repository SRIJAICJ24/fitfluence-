import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/gym_repository_impl.dart';
import '../../domain/models/gym_model.dart';

class GymDetailScreen extends ConsumerStatefulWidget {
  final String gymId;

  const GymDetailScreen({super.key, required this.gymId});

  @override
  ConsumerState<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends ConsumerState<GymDetailScreen> {
  GymModel? _gym;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGymDetails();
  }

  Future<void> _fetchGymDetails() async {
    try {
      final gym = await ref.read(gymRepositoryProvider).getGymById(widget.gymId);
      if (mounted) {
        setState(() {
          _gym = gym;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.volt)),
      );
    }

    if (_gym == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Gym not found')),
      );
    }

    final gym = _gym!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(gym.name, style: const TextStyle(fontSize: 16)),
              background: Container(
                color: AppColors.midnightBlue,
                child: const Center(
                  child: Icon(Icons.fitness_center, size: 64, color: AppColors.volt),
                ),
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
                        '${gym.rating} (${gym.reviewCount} reviews)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (gym.isVerified)
                        const Chip(
                          label: Text('Verified', style: TextStyle(fontSize: 10)),
                          backgroundColor: AppColors.volt,
                          visualDensity: VisualDensity.compact,
                        )
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Location
                  Text('Location', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    '${gym.address}\n${gym.city}, ${gym.state}',
                    style: const TextStyle(color: AppColors.slateGrey, height: 1.5, fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  // Amenities
                  Text('Amenities', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12, 
                    runSpacing: 12,
                    children: gym.amenities.map((a) => _AmenityChip(
                      icon: _getIconForAmenity(a), 
                      label: a
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                   // Facilities
                  Text('Facilities', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12, 
                    runSpacing: 12,
                    children: gym.facilities.map((f) => _AmenityChip(
                      icon: Icons.fitness_center, 
                      label: f
                    )).toList(),
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Join Request Sent! (Feature coming in Phase 2)')),
            );
          }, 
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.volt,
            foregroundColor: AppColors.deepSlate,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Join This Gym'),
        ),
      ),
    );
  }

  IconData _getIconForAmenity(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi': return Icons.wifi;
      case 'ac': return Icons.ac_unit;
      case 'parking': return Icons.local_parking;
      case 'showers': return Icons.shower;
      case 'sauna': return Icons.hot_tub;
      default: return Icons.check_circle_outline;
    }
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
