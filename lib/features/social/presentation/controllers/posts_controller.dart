import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/social_repository.dart';
import '../../data/repositories/social_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum FeedFilter { global, following }

class PostsState {
  final bool isLoading;
  final List<Post> posts;
  final String? error;
  final FeedFilter filter;

  PostsState({
    this.isLoading = true, 
    this.posts = const [], 
    this.error,
    this.filter = FeedFilter.global,
  });
  
  PostsState copyWith({
    bool? isLoading, 
    List<Post>? posts, 
    String? error,
    FeedFilter? filter,
  }) {
    return PostsState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      error: error ?? this.error,
      filter: filter ?? this.filter,
    );
  }
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

    state = state.copyWith(isLoading: true);
    try {
      final posts = state.filter == FeedFilter.global 
          ? await _repository.getHomeFeed(userId)
          : await _repository.getFollowingFeed(userId);
      
      state = state.copyWith(isLoading: false, posts: posts);
    } catch (e) {
      state = state.copyWith(isLoading: false, posts: [], error: e.toString());
    }
  }

  void setFilter(FeedFilter filter) {
    if (state.filter == filter) return;
    state = state.copyWith(filter: filter);
    loadFeed();
  }

  Future<void> toggleLike(String postId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Find the post
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    
    final post = state.posts[index];
    final isLiked = post.isLiked;

    // 2. Optimistic Update (Copy list, modify item)
    final updatedPosts = List<Post>.from(state.posts);
    updatedPosts[index] = Post(
      id: post.id,
      userId: post.userId,
      caption: post.caption,
      mediaUrls: post.mediaUrls,
      hashtags: post.hashtags,
      isPr: post.isPr,
      locationName: post.locationName,
      likeCount: isLiked ? post.likeCount - 1 : post.likeCount + 1,
      commentCount: post.commentCount,
      createdAt: post.createdAt,
      userName: post.userName,
      userAvatar: post.userAvatar,
      isLiked: !isLiked,
    );
    state = state.copyWith(posts: updatedPosts);

    // 3. API Call
    try {
      if (isLiked) {
        await _repository.unlikePost(userId, postId);
      } else {
        await _repository.likePost(userId, postId);
      }
    } catch (e) {
      // Revert if error
      state = state.copyWith(posts: state.posts); // Or deeper revert
    }
  }
}

final postsControllerProvider = StateNotifierProvider<PostsController, PostsState>((ref) {
  return PostsController(
    ref.watch(socialRepositoryProvider),
    Supabase.instance.client,
  );
});
