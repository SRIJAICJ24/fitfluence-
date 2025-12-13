import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatelessWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(radius: 16, child: Text('S')),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sarah Connor', style: TextStyle(fontSize: 16)),
                Text('Online', style: TextStyle(fontSize: 12, color: AppColors.volt.withOpacity(0.8))),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ChatBubble(
                  message: 'Hi there! found you on FitFluence.',
                  isOwn: false,
                  timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
                ),
                ChatBubble(
                  message: 'Hey! active for a session?',
                  isOwn: true,
                  timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
                  isRead: true,
                ),
                ChatBubble(
                  message: 'Sure, what time works?',
                  isOwn: false,
                  timestamp: DateTime.now(),
                ),
              ],
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.midnightBlue,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea( // For iPhone bottom bar
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.add_circle, color: AppColors.slateGrey), onPressed: () {}),
            Expanded(
              child: GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.slateGrey),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.volt,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.deepSlate),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
