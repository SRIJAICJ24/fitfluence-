import 'package:equatable/equatable.dart';

enum PulseCategory { motivation, tips, form, nutrition, lifestyle }

class Pulse extends Equatable {
  final String id;
  final String creatorId;
  final String videoUrl;
  final String? thumbnailUrl;
  final PulseCategory category;
  final int viewCount;
  final int shareCount;
  final String? gymId;
  final DateTime createdAt;

  // Joined Creator Data
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
    final profile = json['profiles'] ?? {};
    
    return Pulse(
      id: json['id'],
      creatorId: json['creator_id'],
      videoUrl: json['video_url'],
      thumbnailUrl: json['thumbnail_url'],
      category: PulseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => PulseCategory.motivation,
      ),
      viewCount: json['view_count'] ?? 0,
      shareCount: json['share_count'] ?? 0,
      gymId: json['gym_id'],
      createdAt: DateTime.parse(json['created_at']),
      creatorName: "${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}".trim(),
      creatorAvatar: profile['avatar_url'],
    );
  }

  @override
  List<Object?> get props => [id, creatorId, videoUrl];
}
