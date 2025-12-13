import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.recipientId,
    required super.messageText,
    super.messageType,
    super.mediaUrl,
    super.isRead,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      recipientId: json['recipient_id'] as String,
      messageText: json['message_text'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      mediaUrl: json['media_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'message_text': messageText,
      'message_type': messageType,
      'media_url': mediaUrl,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
