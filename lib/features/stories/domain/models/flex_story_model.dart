import 'package:equatable/equatable.dart';

class FlexStory extends Equatable {
  final String id;
  final String userId;
  final String mediaUrl;
  final String streakType; // 'gym', 'nutrition', 'mindfulness', 'other'
  final int streakCount;
  final String? gymId;
  final bool isVerified;
  final DateTime expiresAt;
  final DateTime createdAt;
  
  // Hydrated fields
  final String? userName;
  final String? userAvatar;

  const FlexStory({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    this.streakType = 'other',
    this.streakCount = 0,
    this.gymId,
    this.isVerified = false,
    required this.expiresAt,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory FlexStory.fromJson(Map<String, dynamic> json) {
    // Handle profile hydration if joined
    final profile = json['profiles'] as Map<String, dynamic>?;
    
    return FlexStory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mediaUrl: json['media_url'] as String,
      streakType: json['streak_type'] ?? 'other',
      streakCount: json['streak_count'] ?? 0,
      gymId: json['gym_id'] as String?,
      isVerified: json['is_verified'] ?? false,
      expiresAt: DateTime.parse(json['expires_at']),
      createdAt: DateTime.parse(json['created_at']),
      userName: profile?['username'] ?? profile?['first_name'],
      userAvatar: profile?['avatar_url'],
    );
  }

  @override
  List<Object?> get props => [id, userId, mediaUrl, expiresAt];
}
