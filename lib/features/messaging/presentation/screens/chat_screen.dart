import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../controllers/chat_controller.dart';
import '../../domain/models/message_models.dart';
import '../../../safety/presentation/controllers/safety_controller.dart';
import '../../../safety/presentation/widgets/report_dialog.dart';
import '../widgets/chat_bubble.dart'; 
import '../../../buddy/presentation/widgets/vitality_rating_dialog.dart';
import '../../../buddy/data/repositories/buddy_repository_impl.dart';
import '../../data/repositories/messaging_repository_impl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final String _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

  String? _receiverId;
  String _receiverName = 'Chat';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<MessageModel> _searchResults = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _fetchConversationDetails();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  Timer? _typingTimer;
  void _onTextChanged() {
    // Debounce typing status
    if (_typingTimer?.isActive ?? false) _typingTimer!.cancel();
    
    // Send "Typing"
    ref.read(chatControllerProvider.notifier).sendTyping(widget.conversationId, true);

    // Stop "Typing" after 2 seconds of inactivity
    _typingTimer = Timer(const Duration(seconds: 2), () {
      ref.read(chatControllerProvider.notifier).sendTyping(widget.conversationId, false);
    });
  }

  Future<void> _fetchConversationDetails() async {
    final supabase = Supabase.instance.client;
    // Basic fetch to identify the other user.
    // In strict mode, we might need a dedicated Repository method for this.
    try {
      final convo = await supabase
          .from('conversations')
          .select('*, profiles!user_1_id(first_name, last_name, id, username), profiles!user_2_id(first_name, last_name, id, username)') 
          .eq('id', widget.conversationId)
          .single();
      
      final p1 = convo['user_1_id'];
      final p2 = convo['user_2_id'];
      
      final otherIsP1 = p1 != _currentUserId;
      _receiverId = otherIsP1 ? p1 : p2;
      
      // Extract profile name logic (Profiles join returns a Map or List depending on relationship type)
      // Assuming 'profiles' is available via join alias or inferred.
      // If aliases (user_1_id) are used in query, accessed via that alias usually.
      final p1Data = convo['profiles!user_1_id'];
      final p2Data = convo['profiles!user_2_id'];
      
      final receiverData = otherIsP1 ? p1Data : p2Data;
      
      if (receiverData != null) {
        setState(() {
          _receiverName = receiverData['first_name'] ?? receiverData['username'] ?? 'User';
        });
      }
    } catch (_) {
       // Silent error or retry
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final streamAsyncValue = ref.watch(chatStreamProvider(widget.conversationId));
    final chatState = ref.watch(chatControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _isSearching ? _buildSearchAppBar(ref) : _buildNormalAppBar(context),
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
                    
                    return Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          reverse: true, // Auto-scroll to bottom
                          padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            return ChatBubble(
                              message: msg.content,
                              isOwn: msg.senderId == _currentUserId,
                              timestamp: msg.createdAt,
                              isRead: msg.isRead,
                            );
                          },
                        ),
                        if (_isSearching && _searchResults.isNotEmpty)
                          Container(
                            color: AppColors.deepSlate.withOpacity(0.95),
                            child: ListView.separated(
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                              itemBuilder: (context, index) {
                                final res = _searchResults[index];
                                return ListTile(
                                  title: Text(res.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
                                  subtitle: Text(res.createdAt.toString().substring(0, 16), style: const TextStyle(color: Colors.white54)),
                                  onTap: () {
                                     // Find in main list
                                     final mainIndex = messages.indexWhere((m) => m.id == res.id);
                                     if (mainIndex != -1) {
                                       setState(() {
                                         _isSearching = false;
                                         _searchResults.clear();
                                         _searchController.clear();
                                       });
                                       _scrollController.animateTo(
                                         mainIndex * 80.0,
                                         duration: const Duration(milliseconds: 500),
                                         curve: Curves.easeInOut,
                                       );
                                     }
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                  error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.volt)),
                ),
              ),

              // Input Area
              if (!_isSearching) _buildInputArea(ref, chatState.isSending),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildNormalAppBar(BuildContext context) {
    return AppBar(
        title: Text(_receiverName), 
        backgroundColor: AppColors.midnightBlue.withOpacity(0.8),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Consumer(
            builder: (context, ref, child) {
              final typingAsync = ref.watch(typingStatusProvider(widget.conversationId));
              return typingAsync.when(
                data: (typingUserId) {
                  if (typingUserId == _receiverId) { 
                     return Container(
                       width: double.infinity,
                       color: AppColors.midnightBlue.withOpacity(0.8),
                       padding: const EdgeInsets.only(left: 16, bottom: 4),
                       child: const Text(
                         "Typing...",
                         style: TextStyle(color: AppColors.volt, fontSize: 12, fontStyle: FontStyle.italic),
                       ),
                     );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (_receiverId == null) return;
              if (value == 'report') _showReportDialog(context, _receiverId!);
              if (value == 'block') _blockUser(context, _receiverId!);
              if (value == 'end_connection') _showEndConnectionDialog(context);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'end_connection',
                  child: Row(
                    children: [Icon(Icons.broken_image, color: AppColors.error, size: 18), SizedBox(width: 8), Text('End Connection', style: TextStyle(color: AppColors.error))],
                  ),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [Icon(Icons.flag, color: AppColors.slateGrey, size: 18), SizedBox(width: 8), Text('Report User')],
                  ),
                ),
                const PopupMenuItem(
                   value: 'block',
                   child: Row(
                    children: [Icon(Icons.block, color: AppColors.error, size: 18), SizedBox(width: 8), Text('Block User', style: TextStyle(color: AppColors.error))],
                   ),
                ),
              ];
            },
          ),
        ],
      );
  }

  AppBar _buildSearchAppBar(WidgetRef ref) {
    return AppBar(
      backgroundColor: AppColors.midnightBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchResults.clear();
            _searchController.clear();
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "Search messages...",
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
        onSubmitted: (value) async {
           if (value.isNotEmpty) {
             final repo = ref.read(messagingRepositoryProvider);
             final results = await repo.searchMessages(widget.conversationId, value);
             setState(() {
               _searchResults = results;
             });
           }
        },
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
    // Need receiverID.
    if (_receiverId == null) {
      // Try fetch again or fail gracefully
      await _fetchConversationDetails();
      if (_receiverId == null) return;
    }

    ref.read(chatControllerProvider.notifier).sendMessage(widget.conversationId, text, _receiverId!);
    _textController.clear();
  }

  void _showReportDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(reportedUserId: userId, reportedUserName: _receiverName),
    );
  }

  void _blockUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepSlate,
        title: const Text('Block User?', style: TextStyle(color: Colors.white)),
        content: const Text('They will no longer be able to message you.', style: TextStyle(color: AppColors.slateGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
               ref.read(safetyControllerProvider.notifier).blockUser(userId);
               Navigator.pop(context); // Close dialog
               Navigator.pop(context); // Close chat
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked')));
            },
            child: const Text('Block', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showEndConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => VitalityRatingDialog(onSubmit: (rating, comment) async {
        // Fetch connection ID
        final supabase = Supabase.instance.client;
        final convo = await supabase.from('conversations').select('connection_id').eq('id', widget.conversationId).single();
        final connectionId = convo['connection_id'] as String?;
        
        if (connectionId != null) {
           final buddyRepo = ref.read(buddyRepositoryProvider);
           await buddyRepo.endConnection(connectionId, rating, comment);
           if (mounted) {
             Navigator.pop(context); // Close Chat
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection ended.')));
           }
        }
      }),
    );
  }
}
