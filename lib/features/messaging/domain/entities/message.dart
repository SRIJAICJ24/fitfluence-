import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String recipientId;
  final String messageText;
  final String messageType; // 'text', 'image', 'video'
  final String? mediaUrl;
  final bool isRead;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.recipientId,
    required this.messageText,
    this.messageType = 'text',
    this.mediaUrl,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, conversationId, senderId, recipientId, messageText, messageType, mediaUrl, isRead, createdAt
  ];
}
