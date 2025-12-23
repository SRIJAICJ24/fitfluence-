import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../buddy/domain/repositories/buddy_repository.dart';
import '../../../buddy/data/repositories/buddy_repository_impl.dart';

// 1. Domain Model for a Notification (Client-side aggregation)
enum NotificationType {
  buddyRequest,
  system,
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final Map<String, dynamic>? data; // For navigation or actions (max flexibility)
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.data,
    this.isRead = false,
  });
}

// 2. Controller State
class NotificationsState {
  final bool isLoading;
  final List<NotificationItem> items;

  NotificationsState({this.isLoading = true, this.items = const []});
}

// 3. Controller
class NotificationsController extends StateNotifier<NotificationsState> {
  final BuddyRepository _buddyRepository;
  final SupabaseClient _supabase;

  NotificationsController(this._buddyRepository, this._supabase) : super(NotificationsState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = NotificationsState(isLoading: true);

    try {
      // Source A: Buddy Requests (Pending)
      final requests = await _buddyRepository.getPendingRequests(userId);
      
      final requestNotifications = requests.map((req) {
        final profile = req['profiles'] ?? {};
        final name = "${profile['first_name'] ?? 'User'} ${profile['last_name'] ?? ''}";
        
        return NotificationItem(
          id: req['id'], // Request ID
          title: "New Buddy Request",
          body: "$name wants to join your squad!",
          timestamp: DateTime.tryParse(req['created_at']) ?? DateTime.now(),
          type: NotificationType.buddyRequest,
          data: {'requestId': req['id'], 'userId': profile['id']},
        );
      }).cast<NotificationItem>().toList();

      // Source B: System Notifications (Mock for now, or fetch from a future table)
      // Future expansion: Unread messages could also be here, but usually they are just in chat list.

      // Merge and Sort
      final allItems = [...requestNotifications];
      allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first

      state = NotificationsState(isLoading: false, items: allItems);
    } catch (e) {
      state = NotificationsState(isLoading: false, items: []);
    }
  }

  Future<void> markAsRead(String id) async {
    // For buddy requests, "reading" it might not change DB state unless we had a 'viewed' flag.
    // For now, purely local UI state update if we wanted.
  }
}

// 4. Provider
final notificationsProvider = StateNotifierProvider.autoDispose<NotificationsController, NotificationsState>((ref) {
  return NotificationsController(
    ref.watch(buddyRepositoryProvider),
    Supabase.instance.client,
  );
});
