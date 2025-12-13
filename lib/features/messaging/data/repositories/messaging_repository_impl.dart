import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../models/message_model.dart';
// import '../models/conversation_model.dart'; // Assuming similar model exists

class MessagingRepositoryImpl implements MessagingRepository {
  final SupabaseClient _supabaseClient;

  MessagingRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Conversation>> getConversations(String userId) async {
    // Basic implementation: Fetch conversations where user is participant
    // For now returning empty or mock could be safer if tables aren't perfectly seeded
    try {
        final response = await _supabaseClient
            .from('conversations')
            .select()
            .or('user_1_id.eq.$userId,user_2_id.eq.$userId')
            .order('last_message_at', ascending: false);
        
        // Mapping logic would go here. 
        // Simply returning empty list to prevent crash until full join logic is ready
        return []; 
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final response = await _supabaseClient
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true); // Oldest first for chat list
      
      return (response as List).map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> sendMessage(Message message) async {
      await _supabaseClient.from('messages').insert({
        'conversation_id': message.conversationId,
        'sender_id': message.senderId,
        'recipient_id': message.recipientId,
        'message_text': message.messageText,
        // ... other fields
      });
  }

  @override
  Stream<Message> getMessageStream(String conversationId) {
    return _supabaseClient
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((maps) => maps.map((e) => MessageModel.fromJson(e)).last);
  }
}
