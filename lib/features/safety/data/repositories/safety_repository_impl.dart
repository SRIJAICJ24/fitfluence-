import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/safety_repository.dart';

class SafetyRepositoryImpl implements SafetyRepository {
  final SupabaseClient _supabase;

  SafetyRepositoryImpl(this._supabase);

  @override
  Future<void> blockUser(String blockerId, String blockedUserId, String? reason) async {
    await _supabase.from('user_blocks').insert({
      'blocker_id': blockerId,
      'blocked_user_id': blockedUserId,
      'reason': reason,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Optionally update buddy connection status to 'blocked'
    await _supabase.from('buddy_connections')
        .update({'status': 'blocked'})
        .or('user_1_id.eq.$blockerId,user_2_id.eq.$blockerId')
        .or('user_1_id.eq.$blockedUserId,user_2_id.eq.$blockedUserId');
  }

  @override
  Future<void> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reportType,
    String? messageId,
    String? description,
  }) async {
    await _supabase.from('safety_reports').insert({
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'report_type': reportType,
      'message_id': messageId,
      'description': description,
      'status': 'submitted',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
