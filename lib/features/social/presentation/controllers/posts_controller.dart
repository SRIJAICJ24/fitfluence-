import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/social_repository.dart';
import '../../data/repositories/social_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostsState {
  final bool isLoading;
  final List<Post> posts;
  final String? error;

  PostsState({this.isLoading = true, this.posts = const [], this.error});
}

class PostsController extends StateNotifier<PostsState> {
  final SocialRepository _repository;
  final SupabaseClient _supabase;

  PostsController(this._repository, this._supabase) : super(PostsState()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = PostsState(isLoading: true);
    try {
      final posts = await _repository.getHomeFeed(userId);
      state = PostsState(isLoading: false, posts: posts);
    } catch (e) {
      state = PostsState(isLoading: false, posts: [], error: e.toString());
    }
  }

  Future<void> likePost(String postId) async {
    // Optimistic UI update could go here
    // For now, just a stub
  }
}

final postsControllerProvider = StateNotifierProvider<PostsController, PostsState>((ref) {
  return PostsController(
    ref.watch(socialRepositoryProvider),
    Supabase.instance.client,
  );
});
