import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/flex_story_model.dart';
import 'dart:io';

final storiesRepositoryProvider = Provider<StoriesRepository>((ref) {
  return StoriesRepository(Supabase.instance.client);
});

class StoriesRepository {
  final SupabaseClient _supabase;

  StoriesRepository(this._supabase);

  /// Fetch active stories for feed (Following + specific gyms if verified)
  /// For prototype: Fetch ALL active stories (Global Feed style)
  Future<List<FlexStory>> getActiveStories() async {
    final response = await _supabase
        .from('flex_stories')
        .select('*, profiles(username, avatar_url, first_name)')
        .gt('expires_at', DateTime.now().toIso8601String())
        .order('created_at', ascending: false);

    return (response as List).map((json) => FlexStory.fromJson(json)).toList();
  }

  /// Create a new story
  Future<void> createStory({
    required String filePath, 
    required String streakType, 
    String? gymId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // 1. Upload Media
    final fileExt = filePath.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = '$userId/$fileName';
    
    // Note: 'stories' bucket must exist
    await _supabase.storage.from('stories').upload(
      path, 
      File(filePath),
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    final mediaUrl = _supabase.storage.from('stories').getPublicUrl(path);

    // 2. Insert Record
    await _supabase.from('flex_stories').insert({
      'user_id': userId,
      'media_url': mediaUrl,
      'streak_type': streakType,
      'streak_count': 0, // Mock for now, would fetch from streaks table
      'gym_id': gymId,
      'is_verified': gymId != null, // Simplified verification
      'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    });
  }
}
