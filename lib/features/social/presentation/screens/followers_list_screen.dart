import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';

class FollowersListScreen extends ConsumerStatefulWidget {
  final String userId;
  final int initialTabIndex; // 0 for Followers, 1 for Following

  const FollowersListScreen({super.key, required this.userId, this.initialTabIndex = 0});

  @override
  ConsumerState<FollowersListScreen> createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends ConsumerState<FollowersListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSlate,
      appBar: AppBar(
        title: const Text('Social'),
        backgroundColor: AppColors.midnightBlue,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.volt,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UserList(userId: widget.userId, type: 'followers'),
          _UserList(userId: widget.userId, type: 'following'),
        ],
      ),
    );
  }
}

class _UserList extends ConsumerStatefulWidget {
  final String userId;
  final String type; // 'followers' or 'following'

  const _UserList({required this.userId, required this.type});

  @override
  ConsumerState<_UserList> createState() => _UserListState();
}

class _UserListState extends ConsumerState<_UserList> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final supabase = Supabase.instance.client;
    try {
      if (widget.type == 'followers') {
        final response = await supabase
            .from('followers')
            .select('follower_id, profiles!follower_id(id, first_name, last_name, avatar_url, username)')
            .eq('following_id', widget.userId);
        
        setState(() {
          _users = List<Map<String, dynamic>>.from(response).map((row) => row['profiles'] as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        final response = await supabase
            .from('followers')
            .select('following_id, profiles!following_id(id, first_name, last_name, avatar_url, username)')
            .eq('follower_id', widget.userId);
            
        setState(() {
          _users = List<Map<String, dynamic>>.from(response).map((row) => row['profiles'] as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.volt));

    if (_users.isEmpty) {
      return Center(
        child: Text(
          widget.type == 'followers' ? 'No followers yet.' : 'Not following anyone.',
          style: const TextStyle(color: AppColors.slateGrey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _users.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final user = _users[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
                  backgroundColor: AppColors.deepSlate,
                  child: user['avatar_url'] == null 
                      ? Text((user['first_name'] ?? 'U')[0], style: const TextStyle(color: Colors.white)) 
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user['first_name']} ${user['last_name'] ?? ''}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      if (user['username'] != null)
                        Text(
                          "@${user['username']}",
                          style: const TextStyle(color: AppColors.slateGrey, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                // Follow Button could be added here for quick follow back, but omitting for brevity
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
              ],
            ),
          ),
        );
      },
    );
  }
}
