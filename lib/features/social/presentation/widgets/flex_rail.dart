import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';
import '../../domain/entities/flex_story.dart';
import '../controllers/flex_controller.dart';
import 'dart:math' as math;

class FlexRail extends ConsumerWidget {
  const FlexRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(flexControllerProvider);

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.stories.length + 1, // +1 for "Add Story"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _AddStoryCard(onTap: () {
               ref.read(flexControllerProvider.notifier).postMockStory();
            });
          }
          final story = state.stories[index - 1];
          return _FlexStoryCard(story: story);
        },
      ),
    );
  }
}

class _AddStoryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddStoryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        // Skew Transformation
        transform: Matrix4.skewX(-0.1), // approx -6 degrees
        child: GlassContainer(
          borderRadius: 16,
          border: Border.all(color: AppColors.volt.withOpacity(0.5), width: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.volt,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppColors.deepSlate),
              ),
              const SizedBox(height: 12),
              const Text("New Flex", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlexStoryCard extends StatelessWidget {
  final FlexStory story;

  const _FlexStoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      transform: Matrix4.skewX(-0.1),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              story.mediaUrl,
              fit: BoxFit.cover,
            ),
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
              border: story.isVerified 
                  ? Border.all(color: AppColors.volt, width: 2) // Verified Glow
                  : null,
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                Row(
                  children: [
                     CircleAvatar(
                       radius: 10, 
                       backgroundColor: AppColors.deepSlate,
                       backgroundImage: story.userAvatar != null ? NetworkImage(story.userAvatar!) : null,
                       child: story.userAvatar == null ? const Icon(Icons.person, size: 12) : null,
                     ),
                     const SizedBox(width: 4),
                     Expanded(child: Text(story.userName ?? 'User', style: const TextStyle(fontSize: 10, color: Colors.white, overflow: TextOverflow.ellipsis))),
                  ],
                ),
                const SizedBox(height: 4),
                // Streak Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.volt,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    story.streakType.name.toUpperCase(),
                    style: const TextStyle(color: AppColors.deepSlate, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
