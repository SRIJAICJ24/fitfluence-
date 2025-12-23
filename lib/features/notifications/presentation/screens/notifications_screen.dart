import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import 'package:go_router/go_router.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Ambient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.midnightBlue, AppColors.deepSlate, Colors.black],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.volt))
                : state.items.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          return _NotificationTile(item: state.items[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.notifications_none, size: 48, color: AppColors.slateGrey),
            SizedBox(height: 16),
            Text(
              "No new notifications",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "We'll let you know when something important happens.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightSlate),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          if (item.type == NotificationType.buddyRequest) {
            // Navigate to Buddy Requests tab
            // Note: Since BuddyListScreen has tabs, we might want to pass a param or just go to the screen.
            // The TabController in BuddyListScreen defaults to 0 (Requests) anyway if we implemented it right?
            // Actually usually index 0. Let's check. 
            // In BuddyListScreen: tabs: [Tab(text: 'Requests'), Tab(text: 'Connections')]
            // So default is Requests. Perfect.
            context.push('/buddy-discovery/list'); 
          }
        },
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.volt,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(item.timestamp),
                      style: const TextStyle(color: AppColors.slateGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (item.type == NotificationType.buddyRequest)
                 const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.lightSlate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color color;

    switch (item.type) {
      case NotificationType.buddyRequest:
        iconData = Icons.person_add;
        color = AppColors.volt;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else {
      return "${time.day}/${time.month}";
    }
  }
}
