import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../config/theme.dart';
import '../../data/repositories/notification_repository.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final list = await repo.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSlate,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.midnightBlue,
      ),
      body: _isLoading 
         ? const Center(child: CircularProgressIndicator(color: AppColors.volt))
         : _notifications.isEmpty
             ? const Center(child: Text("No notifications yet", style: TextStyle(color: AppColors.slateGrey)))
             : ListView.separated(
                 padding: const EdgeInsets.all(16),
                 itemCount: _notifications.length,
                 separatorBuilder: (_, __) => const SizedBox(height: 12),
                 itemBuilder: (context, index) {
                   return _NotificationTile(notification: _notifications[index]);
                 },
               ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 12,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: notification.actorAvatar != null ? NetworkImage(notification.actorAvatar!) : null,
            backgroundColor: AppColors.deepSlate,
            child: notification.actorAvatar == null ? Text(notification.actorName[0]) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "${notification.actorName} ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: _getActionText(notification.type)),
                    ],
                  ),
                ),
                if (notification.message != null && notification.message!.isNotEmpty)
                   Padding(
                     padding: const EdgeInsets.only(top: 4),
                     child: Text(
                       notification.message!,
                       style: const TextStyle(color: Colors.white70, fontSize: 13),
                       maxLines: 2, 
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(notification.createdAt),
                  style: const TextStyle(color: AppColors.slateGrey, fontSize: 11),
                ),
              ],
            ),
          ),
          if (notification.type == NotificationType.like || notification.type == NotificationType.comment)
             Container(
               width: 40, height: 40,
               color: Colors.white10, // Placeholder for post thumbnail
               child: const Icon(Icons.image, size: 16, color: Colors.white30),
             ),
          if (notification.type == NotificationType.follow)
             const Icon(Icons.person_add, color: AppColors.volt, size: 20),
        ],
      ),
    );
  }

  String _getActionText(NotificationType type) {
    switch (type) {
      case NotificationType.like: return "liked your post.";
      case NotificationType.comment: return "commented on your post.";
      case NotificationType.follow: return "started following you.";
      case NotificationType.message: return "sent you a message.";
    }
  }
}
