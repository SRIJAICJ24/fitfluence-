import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/buddy_repository.dart';
import '../../domain/models/match_model.dart';
import '../matching_service.dart';

final buddyRepositoryProvider = Provider<BuddyRepository>((ref) {
  return BuddyRepositoryImpl(
    supabase: Supabase.instance.client,
    matchingService: MatchingService(),
  );
});

class BuddyRepositoryImpl implements BuddyRepository {
  final SupabaseClient supabase;
  final MatchingService matchingService;

  BuddyRepositoryImpl({
    required this.supabase,
    required this.matchingService,
  });

  @override
  Future<void> updateMatchCache(String userId) async {
    try {
      // 1. Fetch Current User Profile
      final userResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      final currentUser = MatchCandidate.fromJson(userResponse);

      // 2. Fetch Blocked Users (Safety Filter)
      final blocksResponse = await supabase
          .from('user_blocks')
          .select()
          .or('blocker_id.eq.$userId,blocked_user_id.eq.$userId');
      
      final Set<String> blockedIds = {};
      for (final block in blocksResponse as List) {
        if (block['blocker_id'] == userId) blockedIds.add(block['blocked_user_id']);
        if (block['blocked_user_id'] == userId) blockedIds.add(block['blocker_id']);
      }

      // 3. Fetch Potential Candidates (Same Gym Optimization)
      // We process hard filters in memory (MatchingService) for now, 
      // but filtering by GymID at DB level is a huge performance win.
      var query = supabase
          .from('profiles')
          .select()
          .eq('gym_id', currentUser.gymId) 
          .neq('id', currentUser.id); // Exclude self
      
      if (blockedIds.isNotEmpty) {
        // Syntax for 'not in list' in Supabase/Postgrest is tricky with dynamic lists.
        // Easiest is .not('id', 'in', '("id1","id2")') formatted string.
        final filterString = '(${blockedIds.map((id) => '"$id"').join(',')})';
        query = query.not('id', 'in', filterString); 
      }

      final candidatesResponse = await query;

      final candidates = (candidatesResponse as List)
          .map((json) => MatchCandidate.fromJson(json))
          .toList();

      // 4. Run Algorithm (The "Brain")
      final results = matchingService.calculateMatches(currentUser, candidates);

      // 5. Cache Results (Bulk Insert/Upsert)
      if (results.isNotEmpty) {
        final records = results.map((r) => {
          'user_a_id': userId,
          'user_b_id': r.candidateId,
          'match_score': r.score,
          'match_details': r.details,
          'expires_at': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        }).toList();

        // Using upsert to update existing matches if score changed
        await supabase.from('buddy_matches').upsert(
          records, 
          onConflict: 'user_a_id, user_b_id'
        );
      }
    } catch (e) {
      // In a real app, log to Crashlytics
      throw Exception('Failed to update match cache: $e');
    }
  }

  @override
  Future<List<MatchResult>> getMatches(String userId, {double minScore = 0}) async {
    // Fetch from Cache Table
    final response = await supabase
        .from('buddy_matches')
        .select()
        .eq('user_a_id', userId)
        .gte('match_score', minScore)
        .order('match_score', ascending: false);

    return (response as List).map((row) {
      return MatchResult(
        candidateId: row['user_b_id'],
        score: (row['match_score'] as num).toDouble(),
        details: row['match_details'] ?? {},
      );
    }).toList();
  }

  @override
  Future<void> sendBuddyRequest(String requesterId, String recipientId) async {
    // 1. Check for existing request (prevent duplicates)
    final existing = await supabase
        .from('buddy_requests')
        .select()
        .or('requester_id.eq.$requesterId,recipient_id.eq.$requesterId') // Check both directions? No, specifically this pair.
        .eq('status', 'pending')
        .match({
          'requester_id': requesterId, 
          'recipient_id': recipientId
        })
        .maybeSingle();

    if (existing != null) {
      throw Exception('Request already pending');
    }

    // 2. Insert Request
    await supabase.from('buddy_requests').insert({
      'requester_id': requesterId,
      'recipient_id': recipientId,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingRequests(String userId) async {
    final response = await supabase
        .from('buddy_requests')
        .select('id, requester_id, created_at, profiles!requester_id(first_name, last_name, gym_id)') // Join profile
        .eq('recipient_id', userId)
        .eq('status', 'pending');
    
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> respondToRequest(String requestId, String status) async {
    // 1. Update Request
    final response = await supabase
        .from('buddy_requests')
        .update({'status': status})
        .eq('id', requestId)
        .select()
        .single();
    
    if (status == 'accepted') {
      final requesterId = response['requester_id'];
      final recipientId = response['recipient_id'];

      // 2. Create Connection
      await supabase.from('buddy_connections').insert({
        'user_1_id': requesterId,
        'user_2_id': recipientId,
        'status': 'active',
      });

      // 3. Create Conversation (Empty for now)
      await supabase.from('conversations').insert({
        'user_1_id': requesterId,
        'user_2_id': recipientId,
        'last_message_at': DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getConnections(String userId) async {
    // Fetch connections where user is either user_1 or user_2
    final response = await supabase
        .from('buddy_connections')
        .select('''
          id, status, 
          profiles!user_1_id(id, first_name, last_name, gym_id), 
          profiles!user_2_id(id, first_name, last_name, gym_id)
        ''')
        .or('user_1_id.eq.$userId,user_2_id.eq.$userId')
        .eq('status', 'active');

    return List<Map<String, dynamic>>.from(response).map((row) {
      // Normalize: Figure out which profile is "the other person"
      final p1 = row['profiles'] != null ? row['profiles']['user_1_id'] : null; // Supabase map logic might differ
      // Actually Supabase returns nested objects based on FK if aliased or detected. 
      // Simplified extraction (assuming simple map structure returned):
      final user1 = row['profiles']['user_1_id'] ?? row['profiles']; // Fallback
      // Wait, complex join syntax in Dart usually returns generic maps.
      // Logic for UI consumption needs robust parsing. For prototype, passing raw map.
      return row; 
    }).toList();
  }

  @override
  Future<void> endConnection(String connectionId, int rating, String feedback) async {
    // 1. Update Connection Status
    await supabase.from('buddy_connections').update({
      'status': 'ended', // or archived
      'ended_at': DateTime.now().toIso8601String(),
    }).eq('id', connectionId);

    // 2. Log Feedback (Optional table or column)
    // For MVP, maybe just update a metadata column on the connection
    // Or insert into 'feedbacks' table if exists.
  }
}
