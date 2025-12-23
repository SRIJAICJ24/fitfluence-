import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/profile_posts_controller.dart';
import '../../../../features/social/domain/entities/post.dart';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';

class ProfileMasonryGrid extends ConsumerWidget {
  const ProfileMasonryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilePostsControllerProvider);

    if (state.isLoading) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator(color: AppColors.volt)),
      );
    }

    if (state.posts.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(32),
          alignment: Alignment.center,
          child: Column(
            children: [
              const Icon(Icons.photo_camera_back, size: 48, color: AppColors.slateGrey),
              const SizedBox(height: 16),
              const Text("No posts yet", style: TextStyle(color: AppColors.slateGrey)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Trigger create post flow
                },
                icon: const Icon(Icons.add_a_photo, size: 16),
                label: const Text("Create First Post"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.volt,
                  foregroundColor: AppColors.deepSlate,
                ),
              )
            ],
          ),
        ),
      );
    }

    // Custom 2-Column Staggered Logic
    // Divide posts into two lists (left/right) to simulate masonry
    final leftPosts = <Post>[];
    final rightPosts = <Post>[];

    for (var i = 0; i < state.posts.length; i++) {
      if (i % 2 == 0) {
        leftPosts.add(state.posts[i]);
      } else {
        rightPosts.add(state.posts[i]);
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _ColumnLayout(posts: leftPosts)),
            const SizedBox(width: 16),
            Expanded(child: _ColumnLayout(posts: rightPosts)),
          ],
        ),
      ),
    );
  }
}

class _ColumnLayout extends StatelessWidget {
  final List<Post> posts;

  const _ColumnLayout({required this.posts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: posts.map((post) {
        // Random-ish aspect ratio simulation based on hash or just standard
        // For actual masonry, we usually rely on image size, but here we can just vary height slightly or keep standard.
        // Let's toggle between aspect ratios 1.0 and 1.3 for visual variety
        final isTall = post.hashCode % 2 == 0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: isTall ? 0.7 : 1.0, 
                  child: post.mediaUrls.isNotEmpty 
                    ? Image.network(post.mediaUrls.first, fit: BoxFit.cover)
                    : Container(color: AppColors.deepSlate),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Stats on Hover/Overlay
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('${post.likeCount}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // PR Badge
                if (post.isPr)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      borderRadius: 4,
                      child: const Text('PR', style: TextStyle(color: AppColors.volt, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
