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
            final post = state.posts[index];
            return PostCard(post: post);
          },
          childCount: state.posts.length,
        ),
      ),
    );
  }
}
