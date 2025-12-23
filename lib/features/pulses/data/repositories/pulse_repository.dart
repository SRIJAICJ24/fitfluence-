import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/pulse_model.dart';

final pulseRepositoryProvider = Provider<PulseRepository>((ref) {
  return PulseRepository(Supabase.instance.client);
});

class PulseRepository {
  final SupabaseClient _supabase;

  PulseRepository(this._supabase);

  /// Fetch pulses. Optional [url] for pagination (not implemented for MVP).
  /// Optional [gymId] to filter by specific gym.
  Future<List<Pulse>> getPulses({String? gymId, int limit = 10}) async {
    var query = _supabase
        .from('pulses')
        .select('*, profiles(username, avatar_url, first_name)')
        .order('created_at', ascending: false)
        .limit(limit);

    if (gymId != null) {
      query = query.eq('gym_id', gymId);
    }

    final response = await query;
    return (response as List).map((json) => Pulse.fromJson(json)).toList();
  }

  /// Create a new pulse (Mock upload for MVP)
  Future<void> createPulse(String videoUrl, String category, {String? gymId}) async {
     final userId = _supabase.auth.currentUser?.id;
     if (userId == null) throw Exception('Not authenticated');

     await _supabase.from('pulses').insert({
       'creator_id': userId,
       'video_url': videoUrl,
       'category': category,
       'gym_id': gymId,
     });
  }
}
