import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import 'dart:ui';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../widgets/flex_rail.dart';
import '../widgets/quick_connect_rail.dart';
import '../widgets/active_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final firstName = profileState.value?.firstName ?? 'Athlete';

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1. Ambient Glow Background
          _buildAmbientBackground(),

          // 2. Content ScrollView
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverToBoxAdapter(child: _buildHeader(context, firstName)),
                ),

                // Flex Rail (Stories)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: FlexRail(),
                  ),
                ),

                // Quick Connect Suggestions
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: QuickConnectRail(),
                  ),
                ),

                // Active Dashboard Grid
                const SliverToBoxAdapter(
                  child: ActiveGrid(),
                ),

                // Bottom Padding for FAB
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
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
             const _GlassIconButton(icon: Icons.search),
             const SizedBox(width: 8),
             const _GlassIconButton(icon: Icons.notifications_none, hasDot: true),
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
