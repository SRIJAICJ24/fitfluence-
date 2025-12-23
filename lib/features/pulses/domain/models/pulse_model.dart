import 'package:equatable/equatable.dart';

class Pulse extends Equatable {
  final String id;
  final String creatorId; // UUID
  final String videoUrl;
  final String? thumbnailUrl;
  final String category; // 'motivation', 'tips', 'form', 'nutrition', 'lifestyle'
  final int viewCount;
  final int shareCount;
  final String? gymId;
  final DateTime createdAt;
  
  // Hydrated
  final String? creatorName;
  final String? creatorAvatar;

  const Pulse({
    required this.id,
    required this.creatorId,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.category,
    this.viewCount = 0,
    this.shareCount = 0,
    this.gymId,
    required this.createdAt,
    this.creatorName,
    this.creatorAvatar,
  });

  factory Pulse.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return Pulse(
      id: json['id'],
      creatorId: json['creator_id'],
      videoUrl: json['video_url'],
      thumbnailUrl: json['thumbnail_url'],
      category: json['category'] ?? 'lifestyle',
      viewCount: json['view_count'] ?? 0,
      shareCount: json['share_count'] ?? 0,
      gymId: json['gym_id'],
      createdAt: DateTime.parse(json['created_at']),
      creatorName: profile?['username'] ?? profile?['first_name'],
      creatorAvatar: profile?['avatar_url'],
    );
  }

  @override
  List<Object?> get props => [id, videoUrl, creatorId];
}
