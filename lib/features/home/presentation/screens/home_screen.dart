import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import 'dart:ui';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../widgets/flex_rail.dart';
import '../widgets/quick_connect_rail.dart';
import '../../../social/presentation/widgets/posts_feed.dart';
import '../../../../shared/presentation/widgets/navigation/vitality_orb.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch specific profile based on userId (passing null for current user)
    final profileState = ref.watch(profileControllerProvider(null));
    final firstName = profileState.value?.firstName ?? 'Athlete';

    return Scaffold(
      extendBody: true, // Allow body to extend behind bottom elements
      body: Stack(
        children: [
          // 1. Ambient Glow Background
          _buildAmbientBackground(),

          // Main Scrollable Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: Text('Good Morning,\n$firstName', 
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(height: 1.1),
                ),
                actions: [
                  IconButton(
                    icon: const GlassContainer(
                      padding: EdgeInsets.all(8),
                      borderRadius: 12, // Squared off slightly
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                    onPressed: () => context.push('/gym-search'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Stack(
                      children: [
                        const GlassContainer(
                          padding: EdgeInsets.all(8),
                          borderRadius: 12,
                          child: Icon(Icons.notifications_none, color: Colors.white),
                        ),
                        Positioned(
                          right: 8, top: 8,
                          child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.volt, shape: BoxShape.circle)),
                        ),
                      ],
                    ),
                    onPressed: () => context.push('/notifications'),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              // 2. Flex Rail (Stories) - Skewed!
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: FlexRail(),
                ),
              ),

              // 3. Quick Connect (Buddy Discovery)
              const SliverToBoxAdapter(
                child: QuickConnectRail(),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 4. Content Feed
              const PostsFeed(),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for Orb
            ],
          ),
          
          // Vitality Orb (Floating Menu) - Restored
          const Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(child: VitalityOrb()),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBackground() {
    return Stack(
      children: [
        // Base Gradient (Deep Slate)
        Container(
           decoration: const BoxDecoration(
             gradient: LinearGradient(
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
               colors: [AppColors.deepSlate, AppColors.midnightBlue],
             ),
           ),
        ),
        // Top Left Glow (Indigo)
         Positioned(
           top: -100,
           left: -100,
           child: Container(
             width: 300,
             height: 300,
             decoration: const BoxDecoration(
               shape: BoxShape.circle,
               color: AppColors.indigo,
             ),
             child: BackdropFilter(
               filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
               child: Container(color: Colors.transparent),
             ),
           ),
         ),
         // Bottom Right Glow (Teal)
         Positioned(
           bottom: -50,
           right: -50,
           child: Container(
             width: 250,
             height: 250,
             decoration: const BoxDecoration(
               shape: BoxShape.circle,
               color: AppColors.teal,
             ),
             child: BackdropFilter(
               filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
               child: Container(color: Colors.transparent),
             ),
           ),
         ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good Morning,', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.slateGrey)),
            Text(name, style: Theme.of(context).textTheme.displayMedium),
          ],
        ),
        // Utility Cluster
        Row(
          children: [
             _GlassIconButton(icon: Icons.groups, onTap: () => context.go('/buddy-discovery')), // Squad Finder
             const SizedBox(width: 8),
             _GlassIconButton(icon: Icons.search, onTap: () => context.push('/gym-search')),
             const SizedBox(width: 8),
             _GlassIconButton(icon: Icons.notifications_none, hasDot: true, onTap: () => context.push('/notifications')),
          ],
        ),
      ],
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final bool hasDot;
  final VoidCallback? onTap;

  const _GlassIconButton({required this.icon, this.hasDot = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(10),
        borderRadius: 12,
        child: Stack(
          children: [
             Icon(icon, color: AppColors.lightSlate, size: 22),
             if (hasDot)
               const Positioned(
                 right: 0,
                 top: 0,
                 child: CircleAvatar(radius: 4, backgroundColor: AppColors.error),
               ),
          ],
        ),
      ),
    );
  }
}
