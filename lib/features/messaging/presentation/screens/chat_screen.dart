import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../controllers/chat_controller.dart';
import '../../domain/models/message_models.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final String _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

  // In a real app, pass the Receiver's Name/ID via route extras.
  // For prototype, we'll fetch or just show generic.
  
  @override
  Widget build(BuildContext context) {
    final streamAsyncValue = ref.watch(chatStreamProvider(widget.conversationId));
    final chatState = ref.watch(chatControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Chat'), // Dynamic name requires passing extra args
        backgroundColor: AppColors.midnightBlue.withOpacity(0.8),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
           Container(
             decoration: const BoxDecoration(
               gradient: LinearGradient(
                 begin: Alignment.topCenter,
                 end: Alignment.bottomCenter,
                 colors: [AppColors.midnightBlue, AppColors.deepSlate],
               ),
             ),
          ),

          Column(
            children: [
              // Message List
              Expanded(
                child: streamAsyncValue.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return const Center(child: Text("Say hi! 👋", style: TextStyle(color: AppColors.slateGrey)));
                    }
                    return ListView.builder(
                      reverse: true, // Auto-scroll to bottom
                      padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return _MessageBubble(
                          message: msg,
                          isMe: msg.senderId == _currentUserId,
                        );
                      },
                    );
                  },
                  error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.volt)),
                ),
              ),

              // Input Area
              _buildInputArea(ref, chatState.isSending),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(WidgetRef ref, bool isSending) {
    return GlassContainer(
      borderRadius: 0,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40), // Safe area bottom
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: const TextStyle(color: AppColors.slateGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.volt,
            onPressed: isSending ? null : () {
              final text = _textController.text;
              if (text.isNotEmpty) {
                 // Hack: Need receiverId. Ideally conversation model contains it.
                 // Ideally Controller fetches convo details first.
                 // For now, assuming conversation exists, we can find the "other" user via DB query or pass it.
                 // Let's rely on the controller to infer or pass receiverId? 
                 // Actually, sendMessage needs receiverId.
                 
                 // STOPGAP: We fetch the conversation details once in InitState or here to know ReceiverID.
                 // For simplicity in this step, I'll do a quick fetch directly (Not optimal but works).
                 _sendMessage(text);
              }
            },
            child: isSending 
                ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.midnightBlue))
                : const Icon(Icons.send, color: AppColors.midnightBlue, size: 18),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    // We need receiver ID. 
    // Quick Fix: Fetch single convo row to get participants.
    final supabase = Supabase.instance.client;
    final convo = await supabase
        .from('conversations')
        .select()
        .eq('id', widget.conversationId)
        .single();
    
    final p1 = convo['user_1_id'];
    final p2 = convo['user_2_id'];
    final receiverId = (p1 == _currentUserId) ? p2 : p1;

    // Send
    ref.read(chatControllerProvider.notifier).sendMessage(widget.conversationId, text, receiverId);
    _textController.clear();
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.volt : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? AppColors.midnightBlue : Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            // Time (e.g. 10:30 AM)
             Text(
              "${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                color: isMe ? AppColors.midnightBlue.withOpacity(0.6) : AppColors.slateGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
