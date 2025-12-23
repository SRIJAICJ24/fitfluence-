import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String userId;
  final String? caption;
  final List<String> mediaUrls;
  final List<String> hashtags;
  final bool isPr; // Personal Record
  final String? locationName;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  
  // Joined User Data
  final String? userName;
  final String? userAvatar;

  const Post({
    required this.id,
    required this.userId,
    this.caption,
    required this.mediaUrls,
    this.hashtags = const [],
    this.isPr = false,
    this.locationName,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] ?? {};
    
    return Post(
      id: json['id'],
      userId: json['user_id'],
      caption: json['caption'],
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      isPr: json['is_pr'] ?? false,
      locationName: json['location_name'],
      // Counters would ideally come from a subquery or separate count field
      likeCount: json['like_count'] ?? 0, 
      commentCount: json['comment_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      userName: "${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}".trim(),
      userAvatar: profile['avatar_url'],
    );
  }

  @override
  List<Object?> get props => [id, userId, mediaUrls, createdAt];
}
