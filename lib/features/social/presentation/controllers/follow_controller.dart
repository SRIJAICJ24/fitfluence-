import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/social_repository.dart';
import '../../data/repositories/social_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// State: simply true/false for isFollowing, or null if loading.
class FollowState {
  final bool isLoading;
  final bool isFollowing;

  FollowState({this.isLoading = false, this.isFollowing = false});
}

class FollowController extends StateNotifier<FollowState> {
  final SocialRepository _repository;
  final String _currentUserId;
  final String _targetUserId;

  FollowController(this._repository, this._currentUserId, this._targetUserId) 
      : super(FollowState(isLoading: true)) {
    checkFollowStatus();
  }

  Future<void> checkFollowStatus() async {
    try {
      final isFollowing = await _repository.isFollowing(_currentUserId, _targetUserId);
      state = FollowState(isLoading: false, isFollowing: isFollowing);
    } catch (e) {
      state = FollowState(isLoading: false, isFollowing: false);
    }
  }

  Future<void> toggleFollow() async {
    final oldState = state.isFollowing;
    // Optimistic Update
    state = FollowState(isLoading: false, isFollowing: !oldState);

    try {
      if (oldState) {
        await _repository.unfollowUser(_currentUserId, _targetUserId);
      } else {
        await _repository.followUser(_currentUserId, _targetUserId);
      }
    } catch (e) {
      // Revert if error
      state = FollowState(isLoading: false, isFollowing: oldState);
    }
  }
}

// AutoDispose family provider so we can verify multiple users
final followControllerProvider = StateNotifierProvider.family.autoDispose<FollowController, FollowState, String>((ref, targetUserId) {
  final repo = ref.watch(socialRepositoryProvider);
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;
  
  if (currentUserId == null) throw Exception("User not logged in");
  
  return FollowController(repo, currentUserId, targetUserId);
});
