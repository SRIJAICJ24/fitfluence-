import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final followRepositoryProvider = Provider<FollowRepository>((ref) {
  return FollowRepository(Supabase.instance.client);
});

class FollowRepository {
  final SupabaseClient _supabase;

  FollowRepository(this._supabase);

  /// Check if the current user follows [targetUserId]
  Future<bool> isFollowing(String targetUserId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return false;

    final response = await _supabase
        .from('followers')
        .select()
        .eq('follower_id', myId)
        .eq('following_id', targetUserId)
        .maybeSingle();

    return response != null;
  }

  /// Follow a user
  Future<void> followUser(String targetUserId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    await _supabase.from('followers').insert({
      'follower_id': myId,
      'following_id': targetUserId,
    });
  }

  /// Unfollow a user
  Future<void> unfollowUser(String targetUserId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) throw Exception('Not authenticated');

    await _supabase
        .from('followers')
        .delete()
        .eq('follower_id', myId)
        .eq('following_id', targetUserId);
  }

  /// Get counts (followers, following)
  Future<Map<String, int>> getSocialCounts(String userId) async {
    final followersCount = await _supabase
        .from('followers')
        .count(CountOption.exact)
        .eq('following_id', userId);
    
    final followingCount = await _supabase
        .from('followers')
        .count(CountOption.exact)
        .eq('follower_id', userId);

    return {
      'followers': followersCount,
      'following': followingCount,
    };
  }
}
