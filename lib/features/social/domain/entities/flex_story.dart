import 'package:equatable/equatable.dart';

enum FlexType { gym, nutrition, mindfulness, other }

class FlexStory extends Equatable {
  final String id;
  final String userId;
  final String mediaUrl;
  final FlexType streakType;
  final int streakCount;
  final String? gymId;
  final bool isVerified;
  final DateTime expiresAt;
  final DateTime createdAt;
  
  // Joined Fields
  final String? userName;
  final String? userAvatar;

  const FlexStory({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.streakType,
    this.streakCount = 0,
    this.gymId,
    this.isVerified = false,
    required this.expiresAt,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory FlexStory.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] ?? {};
    
    return FlexStory(
      id: json['id'],
      userId: json['user_id'],
      mediaUrl: json['media_url'],
      streakType: FlexType.values.firstWhere(
        (e) => e.name == json['streak_type'],
        orElse: () => FlexType.other,
      ),
      streakCount: json['streak_count'] ?? 0,
      gymId: json['gym_id'],
      isVerified: json['is_verified'] ?? false,
      expiresAt: DateTime.parse(json['expires_at']),
      createdAt: DateTime.parse(json['created_at']),
      userName: "${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}".trim(),
      userAvatar: profile['avatar_url'],
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [id, userId, mediaUrl, expiresAt];
}
