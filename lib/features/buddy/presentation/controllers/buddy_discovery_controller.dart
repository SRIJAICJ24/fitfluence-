import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/buddy_repository.dart';
import '../../data/repositories/buddy_repository_impl.dart';
import '../../domain/models/match_model.dart';
import '../../../profile/data/models/profile_model.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State Class
class BuddyDiscoveryState {
  final bool isLoading;
  final List<BuddyCardData> matches;
  final List<BuddyCardData> allMatches; // RESTORED
  final Map<String, dynamic> filters;   // RESTORED

  BuddyDiscoveryState({
    this.isLoading = true, 
    this.matches = const [], 
    this.allMatches = const [], 
    this.filters = const {},
  });
}

// View Model for the UI
class BuddyCardData {
  final String userId;
  final String name;
  final int age;
  final String gymName;
  final double matchScore;
  final List<String> commonGoals;
  final List<String> commonDays;

  BuddyCardData({
    required this.userId,
    required this.name,
    this.age = 25,
    this.gymName = "Gold's Gym",
    required this.matchScore,
    required this.commonGoals,
    required this.commonDays,
  });
}

class BuddyDiscoveryController extends StateNotifier<BuddyDiscoveryState> {
  final BuddyRepository _repository;
  final SupabaseClient _supabase;

  BuddyDiscoveryController(this._repository, this._supabase) : super(BuddyDiscoveryState()) {
    _loadPersistedFilters().then((_) => loadMatches());
  }

  Future<void> _loadPersistedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final gymId = prefs.getString('filter_gym_id');
    final level = prefs.getString('filter_level');
    final time = prefs.getString('filter_time');
    
    final newFilters = {
      if (gymId != null) 'gymId': gymId,
      if (level != null) 'level': level,
      if (time != null) 'time': time,
    };
    state = BuddyDiscoveryState(
      isLoading: state.isLoading,
      matches: state.matches, 
      allMatches: state.allMatches,
      filters: newFilters,
    );
  }

  Future<void> setFilter(String key, dynamic value) async {
    final newFilters = Map<String, dynamic>.from(state.filters);
    if (value == null) {
      newFilters.remove(key);
    } else {
      newFilters[key] = value;
    }
    
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString('filter_$key', value);
    } else {
      await prefs.remove('filter_$key');
    }

    state = BuddyDiscoveryState(
      isLoading: state.isLoading,
      allMatches: state.allMatches,
      filters: newFilters,
      matches: _applyFilters(state.allMatches, newFilters),
    );
  }

  List<BuddyCardData> _applyFilters(List<BuddyCardData> source, Map<String, dynamic> filters) {
    return source.where((m) {
      if (filters['gymId'] != null) {
         // Implement real filtering here
      }
      return true;
    }).toList();
  }

  Future<void> loadMatches() async {
    state = BuddyDiscoveryState(isLoading: true, allMatches: state.allMatches, matches: state.matches, filters: state.filters);
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _repository.updateMatchCache(userId);
      final results = await _repository.getMatches(userId);
      final List<BuddyCardData> fullMatches = [];

      for (var match in results) {
        final profileResponse = await _supabase
            .from('profiles')
            .select()
            .eq('id', match.candidateId)
            .single();

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

      state = BuddyDiscoveryState(
        isLoading: false, 
        allMatches: fullMatches,
        matches: _applyFilters(fullMatches, state.filters),
        filters: state.filters
      );
    } catch (e) {
      state = BuddyDiscoveryState(isLoading: false, matches: [], allMatches: [], filters: state.filters);
    }
  }

  Future<void> sendRequest(String recipientId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _repository.sendBuddyRequest(userId, recipientId);
      skipMatch(recipientId); 
    } catch (e) {
      rethrow;
    }
  }

  void skipMatch(String candidateId) {
    state = BuddyDiscoveryState(
      isLoading: state.isLoading,
      matches: state.matches.where((m) => m.userId != candidateId).toList(),
      allMatches: state.allMatches.where((m) => m.userId != candidateId).toList(),
      filters: state.filters,
    );
  }
}

final buddyDiscoveryProvider = StateNotifierProvider<BuddyDiscoveryController, BuddyDiscoveryState>((ref) {
  return BuddyDiscoveryController(
    ref.watch(buddyRepositoryProvider),
    Supabase.instance.client,
  );
});
