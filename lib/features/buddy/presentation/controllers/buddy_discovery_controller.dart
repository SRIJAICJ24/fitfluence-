import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/buddy_repository.dart';
import '../../data/repositories/buddy_repository_impl.dart';
import '../../domain/models/match_model.dart';
import '../../../profile/data/models/profile_model.dart'; // Fixed import
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. State Class
class BuddyDiscoveryState {
  final bool isLoading;
  final List<BuddyCardData> matches;

  BuddyDiscoveryState({this.isLoading = true, this.matches = const []});
}

// 2. View Model for the UI
class BuddyCardData {
  final String userId;
  final String name;
  final int age; // Derived from birth_date or mock
  final String gymName;
  final double matchScore;
  final List<String> commonGoals;
  final List<String> commonDays;

  BuddyCardData({
    required this.userId,
    required this.name,
    this.age = 25, // Mock default if null
    this.gymName = "Gold's Gym", // Mock or fetched
    required this.matchScore,
    required this.commonGoals,
    required this.commonDays,
  });
}

// 3. Controller
class BuddyDiscoveryController extends StateNotifier<BuddyDiscoveryState> {
  final BuddyRepository _repository;
  final SupabaseClient _supabase;

  BuddyDiscoveryController(this._repository, this._supabase) : super(BuddyDiscoveryState()) {
    loadMatches();
  }

  Future<void> loadMatches() async {
    state = BuddyDiscoveryState(isLoading: true);
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // A. Trigger Calc (Refresh Cache)
      await _repository.updateMatchCache(userId);

      // B. Get Matches
      final results = await _repository.getMatches(userId);

      // C. Hydrate with Profile Data
      // Note: Ideally Repository does this join. For prototype, doing manually here.
      final List<BuddyCardData> fullMatches = [];

      for (var match in results) {
        final profileResponse = await _supabase
            .from('profiles')
            .select()
            .eq('id', match.candidateId)
            .single();

        // Safe parsing
        final commonGoals = List<String>.from(match.details['common_goals'] ?? []);
        final commonDays = List<String>.from(match.details['common_days'] ?? []);

        fullMatches.add(BuddyCardData(
          userId: match.candidateId,
          name: profileResponse['first_name'] ?? 'Fitness User',
          age: 2025 - (DateTime.tryParse(profileResponse['birth_date'] ?? '')?.year ?? 2000),
          matchScore: match.score,
          commonGoals: commonGoals,
          commonDays: commonDays,
        ));
      }

      state = BuddyDiscoveryState(isLoading: false, matches: fullMatches);
    } catch (e) {
      state = BuddyDiscoveryState(isLoading: false, matches: []);
      // Handle error
    }
  }

  Future<void> sendRequest(String recipientId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _repository.sendBuddyRequest(userId, recipientId);
      // Optimistic Update: Remove from list
      skipMatch(recipientId); 
    } catch (e) {
      rethrow; // UI should handle error
    }
  }

  void skipMatch(String candidateId) {
    state = BuddyDiscoveryState(
      isLoading: state.isLoading,
      matches: state.matches.where((m) => m.userId != candidateId).toList(),
    );
  }
}

// 4. Provider
final buddyDiscoveryProvider = StateNotifierProvider<BuddyDiscoveryController, BuddyDiscoveryState>((ref) {
  return BuddyDiscoveryController(
    ref.watch(buddyRepositoryProvider),
    Supabase.instance.client,
  );
});
