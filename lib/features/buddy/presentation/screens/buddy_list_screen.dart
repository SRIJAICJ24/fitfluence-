import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../controllers/buddy_list_controller.dart';

class BuddyListScreen extends ConsumerStatefulWidget {
  const BuddyListScreen({super.key});

  @override
  ConsumerState<BuddyListScreen> createState() => _BuddyListScreenState();
}

class _BuddyListScreenState extends ConsumerState<BuddyListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(buddyListProvider);
    final controller = ref.read(buddyListProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Squad'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.volt,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.slateGrey,
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Connections'),
          ],
        ),
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
          
          SafeArea(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.volt))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Requests
                      _RequestsList(
                        requests: state.requests,
                        onAccept: controller.acceptRequest,
                        onReject: controller.rejectRequest,
                      ),
                      // Tab 2: Connections
                      _ConnectionsList(connections: state.connections),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final Function(String) onAccept;
  final Function(String) onReject;

  const _RequestsList({required this.requests, required this.onAccept, required this.onReject});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(child: Text("No pending requests.", style: TextStyle(color: AppColors.slateGrey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final profile = req['profiles'] ?? {}; // Handle safely
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: AppColors.deepSlate, child: Text((profile['first_name'] ?? 'U')[0])),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${profile['first_name']} ${profile['last_name']}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Wants to connect",
                        style: TextStyle(color: AppColors.volt, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: () => onReject(req['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: AppColors.success),
                  onPressed: () => onAccept(req['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConnectionsList extends StatelessWidget {
  final List<Map<String, dynamic>> connections;

  const _ConnectionsList({required this.connections});

  @override
  Widget build(BuildContext context) {
    if (connections.isEmpty) {
      return const Center(child: Text("No connections yet. Go discover!", style: TextStyle(color: AppColors.slateGrey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: connections.length,
      itemBuilder: (context, index) {
        final conn = connections[index];
        // Logic to find "other" user needs to be robust, handled by repo ideally.
        // For prototype, we'll try to guess based on structure or show generic
        // Actually, let's just show a simple card.
        final p1 = conn['profiles']?['user_1_id'];
        final p2 = conn['profiles']?['user_2_id'];
        // This mapping logic in UI is fragile. 
        // Real app should have a mapped model.
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: AppColors.deepSlate, child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Fitness Buddy", // Placeholder until better mapping
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: AppColors.volt),
                  onPressed: () {
                    // Navigate to chat (we need conversation ID or user ID)
                    // context.push('/messages/...');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
