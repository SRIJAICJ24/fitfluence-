import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../controllers/posts_controller.dart';
import 'post_card.dart';

class PostsFeed extends ConsumerWidget {
  const PostsFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postsControllerProvider);

    if (state.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator(color: AppColors.volt)),
        ),
      );
    }

    if (state.posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No posts yet. Be the first!', style: TextStyle(color: AppColors.slateGrey))),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Header at index 0
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Global', 
                      isActive: state.filter == FeedFilter.global,
                      onTap: () => ref.read(postsControllerProvider.notifier).setFilter(FeedFilter.global),
                    ),
                    const SizedBox(width: 12),
                    _FilterChip(
                      label: 'Following', 
                      isActive: state.filter == FeedFilter.following,
                      onTap: () => ref.read(postsControllerProvider.notifier).setFilter(FeedFilter.following),
                    ),
                  ],
                ),
              );
            }

            // Posts
            final post = state.posts[index - 1];
            return PostCard(post: post);
          },
          childCount: state.posts.length + 1,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.volt : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.deepSlate : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
