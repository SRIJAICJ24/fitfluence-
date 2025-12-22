import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../../data/repositories/messaging_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatState {
  final bool isSending;
  ChatState({this.isSending = false});
}

class ChatController extends StateNotifier<ChatState> {
  final MessagingRepository _repository;
  final SupabaseClient _supabase;

  ChatController(this._repository, this._supabase) : super(ChatState());

  Future<void> sendMessage(String conversationId, String content, String receiverId) async {
    if (content.trim().isEmpty) return;
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = ChatState(isSending: true);
    
    // We don't await the result for UI responsiveness (Optimistic UI would be better, but simple loader is fine)
    try {
      await _repository.sendMessage(
        conversationId: conversationId,
        senderId: userId,
        receiverId: receiverId,
        content: content,
      );
      state = ChatState(isSending: false);
    } catch (e) {
      state = ChatState(isSending: false);
      // Handle error
    }
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(
    ref.watch(messagingRepositoryProvider),
    Supabase.instance.client,
  );
});

// Stream Provider for Messages
final chatStreamProvider = StreamProvider.family.autoDispose((ref, String conversationId) {
  final repo = ref.watch(messagingRepositoryProvider);
  return repo.subscribeToConversation(conversationId);
});
