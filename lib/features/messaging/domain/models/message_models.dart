import 'package:equatable/equatable.dart';

class ConversationModel extends Equatable {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? lastMessagePreview;
  final DateTime lastMessageAt;
  final DateTime updatedAt;
  // UI helper: The "other" user (requires join/hydration)
  final Map<String, dynamic>? otherUserProfile; 

  const ConversationModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.lastMessagePreview,
    required this.lastMessageAt,
    required this.updatedAt,
    this.otherUserProfile,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      user1Id: json['user_1_id'] as String,
      user2Id: json['user_2_id'] as String,
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageAt: DateTime.parse(json['last_message_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      otherUserProfile: json['other_user'] as Map<String, dynamic>?, // Hydrated manually or via view
    );
  }

  @override
  List<Object?> get props => [id, lastMessageAt, lastMessagePreview];
}

class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  List<Object?> get props => [id, content, isRead, createdAt];
}
