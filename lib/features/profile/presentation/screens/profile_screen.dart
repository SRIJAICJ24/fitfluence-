import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_masonry_grid.dart';
import '../../../social/presentation/widgets/follow_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId; // If null, assume current user
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // Watch specific profile based on userId
    final profileState = ref.watch(profileControllerProvider(widget.userId));
    final profile = profileState.value;
    
    final currentUser = Supabase.instance.client.auth.currentUser;
    final isMe = widget.userId == null || widget.userId == currentUser?.id;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.deepSlate,
      body: profileState.isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Hero Banner with Parallax-like feel (SliverAppBar)
          SliverAppBar(
            expandedHeight: 280,
            pinned: false,
            stretch: true,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const GlassContainer(
                  padding: EdgeInsets.all(8),
                  borderRadius: 50,
                  child: Icon(Icons.share, color: Colors.white, size: 20),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              if (isMe)
                IconButton(
                  icon: const GlassContainer(
                    padding: EdgeInsets.all(8),
                    borderRadius: 50,
                    child: Icon(Icons.settings, color: Colors.white, size: 20),
                  ),
                  onPressed: () {},
                )
              else if (widget.userId != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FollowButton(targetUserId: widget.userId!),
                ),
              const SizedBox(width: 8),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                   Image.network(
                    profile?.avatarUrl ?? 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                  ),
                  // Gradient Overlay for Fade
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.deepSlate],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Identity Cluster (The Float)
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -60), // Negative margin pull-up
              child: Column(
                children: [
                   // Avatar with Gradient Ring
                  Container(
                    padding: const EdgeInsets.all(4), // Ring width
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.volt, AppColors.cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4), // Inner spacing
                      decoration: const BoxDecoration(color: AppColors.deepSlate, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: NetworkImage(profile?.avatarUrl ?? 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?auto=format&fit=crop&q=80'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                         profile?.fullName ?? 'Athlete', 
                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)
                       ),
                       const SizedBox(width: 8),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                         decoration: BoxDecoration(
                           color: AppColors.volt.withOpacity(0.2),
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: AppColors.volt),
                         ),
                         child: const Text('PRO', style: TextStyle(color: AppColors.volt, fontSize: 10, fontWeight: FontWeight.bold)),
                       ),
                    ],
                  ),
                  Text('@${profile?.username ?? "user"}', style: const TextStyle(color: AppColors.slateGrey)),
                  
                  const SizedBox(height: 16),

                  // Mental Health Vibe Check
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    borderRadius: 30,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: _getVibeColor(profile?.mentalHealthComfort),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: _getVibeColor(profile?.mentalHealthComfort), blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          profile?.mentalHealthComfort ?? 'Unknown Vibe', 
                          style: const TextStyle(color: AppColors.lightSlate, fontSize: 12, fontWeight: FontWeight.w500)
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.qr_code, color: Colors.white, size: 16),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 3. Vitality Rings (Stats)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildVitalityRing('Streak', '14', 0.8, AppColors.indigo),
                        _buildVitalityRing('PRs', '5', 0.4, AppColors.volt),
                        _buildVitalityRing('Consistency', '92%', 0.92, AppColors.teal),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // 4. Glass Tabs
                  GlassContainer(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.all(4),
                    borderRadius: 16,
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.slateGrey,
                      dividerColor: Colors.transparent,
                      tabs: const [
                         Tab(text: 'Posts'),
                         Tab(text: 'Vitals'),
                         Tab(text: 'Gear'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 5. Masonry Grid (Content Feed) - Real Data
          const ProfileMasonryGrid(),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildVitalityRing(String label, String value, double percent, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: percent,
                strokeWidth: 6,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
              Center(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppColors.slateGrey, fontSize: 12)),
      ],
    );
  }

  Color _getVibeColor(String? vibe) {
    switch (vibe) {
      case 'Very Open': return Colors.green;
      case 'Moderate': return Colors.yellow;
      case 'Private': return Colors.red;
      default: return Colors.grey;
    }
  }
}
