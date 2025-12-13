import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final int unreadCount;
  
  // For UI display (usually joined data)
  final String? otherUserName;
  final String? otherUserAvatar;

  const Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.lastMessageText,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  List<Object?> get props => [
    id, user1Id, user2Id, lastMessageText, lastMessageAt, unreadCount, otherUserName, otherUserAvatar
  ];
}
