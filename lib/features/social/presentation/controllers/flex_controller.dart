import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/flex_story.dart';
import '../../domain/repositories/social_repository.dart';
import '../../data/repositories/social_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlexState {
  final bool isLoading;
  final List<FlexStory> stories;

  FlexState({this.isLoading = true, this.stories = const []});
}

class FlexController extends StateNotifier<FlexState> {
  final SocialRepository _repository;
  final SupabaseClient _supabase;

  FlexController(this._repository, this._supabase) : super(FlexState()) {
    loadStories();
  }

  Future<void> loadStories() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final stories = await _repository.getActiveStories(userId);
      state = FlexState(isLoading: false, stories: stories);
    } catch (e) {
      state = FlexState(isLoading: false, stories: []);
    }
  }

  Future<void> postMockStory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    // For prototype testing: insert a dummy story
    await _repository.postStory(
      userId, 
      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&q=80', 
      'gym', 
      5, 
      null
    );
    await loadStories();
  }
}

final flexControllerProvider = StateNotifierProvider<FlexController, FlexState>((ref) {
  return FlexController(
    ref.watch(socialRepositoryProvider),
    Supabase.instance.client,
  );
});
