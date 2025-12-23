import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(Supabase.instance.client);
});

enum NotificationType { like, comment, follow, message }

class AppNotification {
  final String id;
  final String actorId;
  final String actorName;
  final String? actorAvatar;
  final NotificationType type;
  final String? message;
  final String? resourceId; // Post ID, Comment ID, etc.
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.actorId,
    required this.actorName,
    this.actorAvatar,
    required this.type,
    this.message,
    this.resourceId,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Note: Depends on how `social_notifications` table is structured in SQL.
    // Assuming a generic structure or joined with profiles.
    final profile = json['profiles']; 
    
    return AppNotification(
      id: json['id'],
      actorId: json['actor_id'],
      actorName: profile != null ? (profile['username'] ?? profile['first_name']) : 'User',
      actorAvatar: profile?['avatar_url'],
      type: _parseType(json['type']),
      message: json['content'],
      resourceId: json['resource_id'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }

  static NotificationType _parseType(String type) {
    switch (type) {
      case 'like': return NotificationType.like;
      case 'comment': return NotificationType.comment;
      case 'follow': return NotificationType.follow;
      default: return NotificationType.message;
    }
  }
}

class NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepository(this._supabase);

  Stream<List<AppNotification>> getNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    return _supabase
        .from('social_notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .map((maps) => maps.map((map) {
             // In stream, we can't easily join. 
             // We might need to fetch profiles separately or rely on a view.
             // For MVP, returning raw or simple mapping.
             // Ideally: Use a Postgres View `notifications_with_profiles`
             return AppNotification.fromJson(map); 
        }).toList());
  }
  
  // Alternative: Fetch once
  Future<List<AppNotification>> fetchNotifications() async {
     final userId = _supabase.auth.currentUser?.id;
     if (userId == null) return [];

     final response = await _supabase
         .from('social_notifications')
         .select('*, profiles!actor_id(username, first_name, avatar_url)')
         .eq('user_id', userId)
         .order('created_at', ascending: false)
         .limit(50);
     
     return (response as List).map((json) => AppNotification.fromJson(json)).toList();
  }
}
