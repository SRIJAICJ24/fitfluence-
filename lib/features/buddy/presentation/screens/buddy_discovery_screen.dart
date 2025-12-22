import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../controllers/buddy_discovery_controller.dart';

class BuddyDiscoveryScreen extends ConsumerWidget {
  const BuddyDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(buddyDiscoveryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Discover Buddies'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined, color: Colors.white),
            tooltip: 'My Squad',
            onPressed: () => context.go('/buddy-discovery/list'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.volt),
            onPressed: () {}, // Filter sheet later
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Ambient Background (Consistent with App)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.midnightBlue, AppColors.deepSlate, Colors.black],
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.volt.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.volt))
                : state.matches.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.matches.length,
                        itemBuilder: (context, index) {
                          return _BuddyCard(data: state.matches[index]);
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
            Icon(Icons.search_off, size: 48, color: AppColors.slateGrey),
            SizedBox(height: 16),
            Text(
              "No matches yet",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Try updating your schedule or fitness goals to find more buddies.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightSlate),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuddyCard extends StatelessWidget {
  final BuddyCardData data;

  const _BuddyCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: EdgeInsets.zero, // Custom inside
        child: Column(
          children: [
            // Header: Avatar + Score
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.deepSlate,
                    child: Text(
                      data.name[0],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${data.name}, ${data.age}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.slateGrey),
                            const SizedBox(width: 4),
                            Text(
                              data.gymName,
                              style: const TextStyle(color: AppColors.slateGrey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _MatchBadge(score: data.matchScore),
                ],
              ),
            ),

            // Divider
            Container(height: 1, color: Colors.white.withOpacity(0.1)),

            // Details: "Why matched"
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "WHY WE MATCHED",
                    style: TextStyle(
                      color: AppColors.lightSlate,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (data.commonGoals.isNotEmpty)
                        _DetailChip(
                          icon: Icons.track_changes,
                          label: "${data.commonGoals.length} Shared Goals",
                          isHighlight: true,
                        ),
                      if (data.commonDays.isNotEmpty)
                        _DetailChip(
                          icon: Icons.calendar_today,
                          label: "${data.commonDays.length} Days Overlap",
                        ),
                        // Add more chips dynamic logic here
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Consumer(
                builder: (context, ref, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(buddyDiscoveryProvider.notifier).skipMatch(data.userId);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Skip", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await ref.read(buddyDiscoveryProvider.notifier).sendRequest(data.userId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Request Sent! 🚀"),
                                    backgroundColor: AppColors.volt,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.volt,
                            foregroundColor: AppColors.midnightBlue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text("Connect", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final double score;
  const _MatchBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.volt.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.volt.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 16, color: AppColors.volt),
          const SizedBox(width: 4),
          Text(
            "${score.toInt()}%",
            style: const TextStyle(
              color: AppColors.volt,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isHighlight;

  const _DetailChip({required this.icon, required this.label, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlight ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isHighlight ? Colors.white : AppColors.lightSlate),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isHighlight ? Colors.white : AppColors.lightSlate,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
