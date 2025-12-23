import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../controllers/buddy_discovery_controller.dart';

class DiscoveryFilterDrawer extends ConsumerWidget {
  const DiscoveryFilterDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(buddyDiscoveryProvider);
    final controller = ref.read(buddyDiscoveryProvider.notifier);
    final filters = state.filters;

    return Drawer(
      backgroundColor: Colors.transparent, // Glass effect
      child: GlassContainer(
        borderRadius: 0,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const Icon(Icons.tune, color: AppColors.volt),
                    const SizedBox(width: 12),
                    const Text(
                      'Filters',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildSectionTitle('Fitness Level'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Beginner', 'Intermediate', 'Advanced', 'Elite'].map((level) {
                        final isSelected = filters['level'] == level;
                        return ChoiceChip(
                          label: Text(level),
                          selected: isSelected,
                          onSelected: (selected) {
                            controller.setFilter('level', selected ? level : null);
                          },
                          backgroundColor: Colors.white10,
                          selectedColor: AppColors.volt,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.deepSlate : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Time of Day'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ['Morning', 'Afternoon', 'Evening'].map((time) {
                        final isSelected = filters['time'] == time;
                         return ChoiceChip(
                          label: Text(time),
                          selected: isSelected,
                          onSelected: (selected) {
                            controller.setFilter('time', selected ? time : null);
                          },
                          backgroundColor: Colors.white10,
                          selectedColor: AppColors.volt,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.deepSlate : Colors.white70,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Gym'),
                    const SizedBox(height: 12),
                    // Dropdown or selector. Mocking standard gym.
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.location_on, color: AppColors.slateGrey),
                      title: const Text("Gold's Gym", style: TextStyle(color: Colors.white)),
                      trailing: Checkbox(
                        value: filters['gymId'] != null, // Mock logic
                        activeColor: AppColors.volt,
                        checkColor: AppColors.deepSlate,
                        onChanged: (val) {
                           // Toggle just for demo
                           controller.setFilter('gymId', (val ?? false) ? 'golds_gym_id' : null);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppColors.volt,
                     foregroundColor: AppColors.deepSlate,
                     minimumSize: const Size(double.infinity, 48),
                   ),
                   onPressed: () {
                     // Filters apply immediately in this design, so just close
                     Navigator.pop(context);
                   },
                   child: const Text('Show Results', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.lightSlate,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
