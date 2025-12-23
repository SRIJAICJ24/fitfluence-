import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';

class QuickConnectRail extends StatelessWidget {
  const QuickConnectRail({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70, // Mini card height
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _HolographicMiniCard(index: index);
        },
      ),
    );
  }
}

class _HolographicMiniCard extends StatelessWidget {
  final int index;
  const _HolographicMiniCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: 180,
      padding: const EdgeInsets.all(8),
      borderRadius: 35, // Pill shape
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=User+${index + 5}&background=random'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const Text('At Gold\'s Gym', style: TextStyle(fontSize: 10, color: AppColors.slateGrey)),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.volt,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: AppColors.deepSlate, size: 18),
          ),
        ],
      ),
    );
  }
}
