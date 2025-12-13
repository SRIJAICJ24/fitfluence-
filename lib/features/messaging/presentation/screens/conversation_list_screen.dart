import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final conversations = [
      {'id': '1', 'name': 'Sarah Connor', 'lastMsg': 'See you at the gym!', 'time': '10:30 AM', 'count': 2},
      {'id': '2', 'name': 'Mike Ross', 'lastMsg': 'What is your split today?', 'time': 'Yesterday', 'count': 0},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.builder(
        itemCount: conversations.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final chat = conversations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => context.go('/messages/${chat['id']}'),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.darkContainer,
                      child: Text((chat['name'] as String)[0]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(chat['name'] as String, style: Theme.of(context).textTheme.titleMedium),
                              Text(chat['time'] as String, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chat['lastMsg'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: (chat['count'] as int) > 0 ? AppColors.lightSlate : AppColors.slateGrey,
                              fontWeight: (chat['count'] as int) > 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((chat['count'] as int) > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.volt,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          chat['count'].toString(),
                          style: const TextStyle(color: AppColors.deepSlate, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
