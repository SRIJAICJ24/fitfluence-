import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

abstract class MessagingRepository {
  Future<List<Conversation>> getConversations(String userId);
  Future<List<Message>> getMessages(String conversationId);
  Future<void> sendMessage(Message message);
  Stream<Message> getMessageStream(String conversationId);
}
