import 'dart:async';
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
    final response = await supabase
        .from('conversations')
        .select()
        .or('user_1_id.eq.$userId,user_2_id.eq.$userId')
        .order('last_message_at', ascending: false);

    final conversations = (response as List).map((json) => ConversationModel.fromJson(json)).toList();

    final hydratedConversations = <ConversationModel>[];
    for (var conv in conversations) {
      final otherId = (conv.user1Id == userId) ? conv.user2Id : conv.user1Id;
      // In production, optimize this fetch
      try {
        final profile = await supabase
            .from('profiles')
            .select('id, first_name, last_name, gym_id, avatar_url')
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
      } catch (_) {
        // Skip if profile not found (defensive)
      }
    }
    return hydratedConversations;
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false);
    return (response as List).map((json) => MessageModel.fromJson(json)).toList();
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final msgResponse = await supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'is_read': false,
    }).select().single();

    await supabase.from('conversations').update({
      'last_message_preview': content,
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);

    return MessageModel.fromJson(msgResponse);
  }

  @override
  Future<void> markAsRead(String conversationId, String userId) async {
    await supabase.from('messages').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('conversation_id', conversationId)
      .eq('receiver_id', userId)
      .eq('is_read', false);
  }

  @override
  Stream<List<MessageModel>> subscribeToConversation(String conversationId) {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .map((maps) => maps.map((json) => MessageModel.fromJson(json)).toList());
  }

  @override
  Future<String> getOrCreateConversation(String userA, String userB) async {
    final response = await supabase
        .from('conversations')
        .select('id')
        .or('and(user_1_id.eq.$userA,user_2_id.eq.$userB),and(user_1_id.eq.$userB,user_2_id.eq.$userA)')
        .maybeSingle();

    if (response != null) {
      return response['id'] as String;
    }

    final newConv = await supabase.from('conversations').insert({
      'user_1_id': userA,
      'user_2_id': userB,
      'updated_at': DateTime.now().toIso8601String(),
    }).select('id').single();

    return newConv['id'] as String;
  }

  @override
  Future<void> sendTypingStatus(String conversationId, String userId, bool isTyping) async {
    final channel = supabase.channel('room:$conversationId');
    await channel.subscribe();
    await channel.sendBroadcastMessage(
      event: 'typing',
      payload: {'user_id': userId, 'is_typing': isTyping},
    );
  }

  @override
  Stream<String> onTypingStatusChanged(String conversationId) {
    final controller = StreamController<String>();
    final channel = supabase.channel('room:$conversationId');
    
    channel.onBroadcast(event: 'typing', callback: (payload) {
       final uid = payload['user_id'] as String?;
       final isTyping = payload['is_typing'] as bool? ?? false;
       if (uid != null && isTyping) {
         controller.add(uid);
       } 
    }).subscribe();

    return controller.stream;
  }

  @override
  Future<List<MessageModel>> searchMessages(String conversationId, String query) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .ilike('content', '%$query%')
        .order('created_at', ascending: false);

    return (response as List).map((json) => MessageModel.fromJson(json)).toList();
  }
}
