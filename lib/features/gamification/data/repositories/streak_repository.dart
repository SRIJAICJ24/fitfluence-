import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(Supabase.instance.client);
});

class Streak {
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastActivityDate;

  Streak({
    required this.currentStreak,
    required this.bestStreak,
    this.lastActivityDate,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      currentStreak: json['current_streak'] ?? 0,
      bestStreak: json['best_streak'] ?? 0,
      lastActivityDate: json['last_activity_date'] != null 
          ? DateTime.parse(json['last_activity_date']) 
          : null,
    );
  }
}

class StreakRepository {
  final SupabaseClient _supabase;

  StreakRepository(this._supabase);

  Future<Streak?> getUserStreak(String userId) async {
    final response = await _supabase
        .from('user_streaks')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      // Return default/empty streak if no record exists yet
      return Streak(currentStreak: 0, bestStreak: 0);
    }

    return Streak.fromJson(response);
  }

  /// Updates streak based on activity.
  /// Note: Ideally this is handled by a Database Trigger or Edge Function to ensure integrity.
  /// For this prototype, we'll expose a simplified client-side trigger.
  Future<void> logActivity() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Call an RPC or Edge Function in real app.
    // Here we'll just upsert a dummy record to trigger potential DB logic
    // or manually update if we were doing client-side logic (not recommended for streaks).
    
    // Assuming backend handles the calculation on 'posts' insert or 'gym_visit' log.
    // This method might just force a refresh or be a placeholder.
  }
}
