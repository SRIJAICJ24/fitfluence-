import '../models/message_models.dart';

abstract class MessagingRepository {
  /// Fetches all conversations for the [userId].
  Future<List<ConversationModel>> getConversations(String userId);

  /// Fetches message history for [conversationId].
  Future<List<MessageModel>> getMessages(String conversationId);

  /// Sends a new message.
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
  });

  /// Marks messages in [conversationId] as read for [userId].
  Future<void> markAsRead(String conversationId, String userId);

  /// Subscribes to new messages for a specific conversation.
  Stream<List<MessageModel>> subscribeToConversation(String conversationId);

  /// Gets an existing conversation ID or creates a new one.
  Future<String> getOrCreateConversation(String userA, String userB);

  /// Emits a typing event (isTyping: true/false) to the conversation room.
  Future<void> sendTypingStatus(String conversationId, String userId, bool isTyping);

  /// Listens for typing events in a conversation.
  /// Returns a Stream of UserIDs who are currently typing.
  Stream<String> onTypingStatusChanged(String conversationId);

  /// Searches messages in a conversation using case-insensitive match.
  Future<List<MessageModel>> searchMessages(String conversationId, String query);
}
