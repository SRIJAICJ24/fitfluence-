import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../../data/repositories/messaging_repository_impl.dart';
import '../../domain/models/message_models.dart';

// Simple Future Provider
final conversationListProvider = FutureProvider.autoDispose<List<ConversationModel>>((ref) {
  final repo = ref.watch(messagingRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return repo.getConversations(userId);
});

class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(conversationListProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
           Container(
             decoration: const BoxDecoration(
               gradient: LinearGradient(
                 begin: Alignment.topCenter,
                 end: Alignment.bottomCenter,
                 colors: [AppColors.midnightBlue, AppColors.deepSlate],
               ),
             ),
          ),
          
          SafeArea(
            child: listAsync.when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return const Center(child: Text("No conversations yet.", style: TextStyle(color: AppColors.slateGrey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final convo = conversations[index];
                    final otherUser = convo.otherUserProfile ?? {};
                    final name = "${otherUser['first_name'] ?? 'User'} ${otherUser['last_name'] ?? ''}";
                    
                    return GestureDetector(
                      onTap: () => context.go('/messages/${convo.id}'),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.deepSlate,
                                child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      convo.lastMessagePreview ?? 'Start chatting...',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: (convo.lastMessagePreview == null) ? AppColors.volt : AppColors.slateGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatDate(convo.lastMessageAt),
                                style: const TextStyle(color: AppColors.slateGrey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.volt)),
              error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: AppColors.error))),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays < 1) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day}/${date.month}";
  }
}
