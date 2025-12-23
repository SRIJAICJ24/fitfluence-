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
    if (userId != null) {
      await _repository.markAsRead(conversationId, userId);
    }
  }

  Future<void> sendTyping(String conversationId, bool isTyping) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _repository.sendTypingStatus(conversationId, userId, isTyping);
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
  
  // Side Effect: Mark as read when stream is active (user is viewing)
  // We use a fire-and-forget call here carefully.
  // Ideally, we'd use a useEffect hook in the UI, but here ensures it runs on data fetch.
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId != null) {
      repo.markAsRead(conversationId, userId);
  }
  
  return repo.subscribeToConversation(conversationId);
});

// Stream Provider for Typing Status
final typingStatusProvider = StreamProvider.family.autoDispose((ref, String conversationId) {
  final repo = ref.watch(messagingRepositoryProvider);
  return repo.onTypingStatusChanged(conversationId);
});
