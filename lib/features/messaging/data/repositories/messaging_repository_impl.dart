import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../../domain/models/message_models.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepositoryImpl(Supabase.instance.client);
});

class MessagingRepositoryImpl implements MessagingRepository {
  final SupabaseClient supabase;

  MessagingRepositoryImpl(this.supabase);

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    // 1. Fetch Conversations
    final response = await supabase
        .from('conversations')
        .select()
        .or('user_1_id.eq.$userId,user_2_id.eq.$userId')
        .order('last_message_at', ascending: false);

    final conversations = (response as List).map((json) => ConversationModel.fromJson(json)).toList();

    // 2. Hydrate "Other User" Profile (N+1 efficient implementation needed normally)
    // For prototype, simple loop.
    final hydratedConversations = <ConversationModel>[];
    
    for (var conv in conversations) {
      final otherId = (conv.user1Id == userId) ? conv.user2Id : conv.user1Id;
      final profile = await supabase
          .from('profiles')
          .select('id, first_name, last_name, gym_id') // optimized select
          .eq('id', otherId)
          .single();
      
      hydratedConversations.add(ConversationModel(
        id: conv.id,
        user1Id: conv.user1Id,
        user2Id: conv.user2Id,
        lastMessageAt: conv.lastMessageAt,
        lastMessagePreview: conv.lastMessagePreview,
        updatedAt: conv.updatedAt,
        otherUserProfile: profile,
      ));
    }

    return hydratedConversations;
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false); // Newest first for chat UI

    return (response as List).map((json) => MessageModel.fromJson(json)).toList();
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    // 1. Insert Message
    final msgResponse = await supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'is_read': false,
      // 'created_at' auto-generated
    }).select().single();

    // 2. Update Conversation Metadata (Last msg preview)
    await supabase.from('conversations').update({
      'last_message_preview': content,
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);

    return MessageModel.fromJson(msgResponse);
  }

  @override
  Future<void> markAsRead(String conversationId, String userId) async {
    // Update all messages where receiver is me AND is_read is false
    await supabase.from('messages').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('conversation_id', conversationId)
      .eq('receiver_id', userId)
      .eq('is_read', false);
  }

  @override
  Stream<List<MessageModel>> subscribeToConversation(String conversationId) {
    // Realtime Stream!
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false) // must match order
        .map((maps) => maps.map((json) => MessageModel.fromJson(json)).toList());
  }
}
