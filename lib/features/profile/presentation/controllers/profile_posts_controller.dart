import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/social/domain/entities/post.dart';
import '../../../../features/social/domain/repositories/social_repository.dart';
import '../../../../features/social/data/repositories/social_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePostsState {
  final bool isLoading;
  final List<Post> posts;

  ProfilePostsState({this.isLoading = true, this.posts = const []});
}

class ProfilePostsController extends StateNotifier<ProfilePostsState> {
  final SocialRepository _repository;
  final String? _userId;

  ProfilePostsController(this._repository, this._userId) : super(ProfilePostsState()) {
    loadUserPosts();
  }

  Future<void> loadUserPosts() async {
    if (_userId == null) return;
    try {
      final posts = await _repository.getUserPosts(_userId!);
      state = ProfilePostsState(isLoading: false, posts: posts);
    } catch (e) {
      state = ProfilePostsState(isLoading: false, posts: []);
    }
  }
}

final profilePostsControllerProvider = StateNotifierProvider.autoDispose<ProfilePostsController, ProfilePostsState>((ref) {
  final repo = ref.watch(socialRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  return ProfilePostsController(repo, userId);
});
