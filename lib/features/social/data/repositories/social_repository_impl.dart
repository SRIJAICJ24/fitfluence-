import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/social_repository.dart';
import '../../domain/entities/flex_story.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/pulse.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepositoryImpl(Supabase.instance.client);
});

class SocialRepositoryImpl implements SocialRepository {
  final SupabaseClient _supabase;

  SocialRepositoryImpl(this._supabase);

  @override
  Future<List<FlexStory>> getActiveStories(String userId) async {
    // Phase 3 Logic:
    // 1. Fetch stories where expires_at > now()
    // 2. Join with profiles to get user info
    // 3. (Optional) Filter by following/gym in future steps
    
    final response = await _supabase
        .from('flex_stories')
        .select('*, profiles!user_id(first_name, last_name, avatar_url)')
        .gt('expires_at', DateTime.now().toIso8601String())
        .order('created_at', ascending: false);

    return (response as List).map((json) => FlexStory.fromJson(json)).toList();
  }

  @override
  Future<void> postStory(String userId, String mediaUrl, String type, int streakCount, String? gymId) async {
    await _supabase.from('flex_stories').insert({
      'user_id': userId,
      'media_url': mediaUrl,
      'streak_type': type,
      'streak_count': streakCount,
      'gym_id': gymId,
      'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    });
  }

  @override
  Future<List<Post>> getHomeFeed(String userId) async {
    // For now, fetch ALL recent posts (Global Feed style for MVP)
    // In Phase 3.5, we will filter by "Followers" table.
    
    final response = await _supabase
        .from('posts')
        .select('*, profiles!user_id(first_name, last_name, avatar_url)')
        .order('created_at', ascending: false)
        .limit(20);

    return (response as List).map((json) => Post.fromJson(json)).toList();
  }

  @override
  Future<List<Post>> getUserPosts(String userId) async {
    final response = await _supabase
        .from('posts')
        .select('*, profiles!user_id(first_name, last_name, avatar_url)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Post.fromJson(json)).toList();
  }

  @override
  Future<List<Pulse>> getPulses(String userId, {String? gymIdFilter}) async {
    var query = _supabase
        .from('pulses')
        .select('*, profiles!creator_id(first_name, last_name, avatar_url)');

    if (gymIdFilter != null) {
      query = query.eq('gym_id', gymIdFilter);
    }
    
    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => Pulse.fromJson(json)).toList();
  }

  @override
  Future<void> followUser(String followerId, String targetId) async {
    await _supabase.from('followers').insert({
      'follower_id': followerId,
      'following_id': targetId,
    });
  }

  @override
  Future<void> unfollowUser(String followerId, String targetId) async {
    await _supabase
        .from('followers')
        .delete()
        .match({'follower_id': followerId, 'following_id': targetId});
  }

  @override
  Future<bool> isFollowing(String followerId, String targetId) async {
    final response = await _supabase
        .from('followers')
        .select()
        .match({'follower_id': followerId, 'following_id': targetId})
        .maybeSingle();
    return response != null;
  }
}
