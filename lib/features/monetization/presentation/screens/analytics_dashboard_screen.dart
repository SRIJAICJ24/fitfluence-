import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/presentation/widgets/glass_container.dart';
import '../../data/repositories/analytics_repository.dart';

final analyticsProvider = FutureProvider.family<List<DailyStat>, String>((ref, userId) async {
  return ref.read(analyticsRepositoryProvider).getDailyStats(userId);
});

class AnalyticsDashboardScreen extends ConsumerWidget {
  final String userId;
  const AnalyticsDashboardScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(analyticsProvider(userId));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Pro Insights', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Colors.black],
          ),
        ),
        child: statsAsync.when(
          data: (stats) => _buildDashboard(context, stats),
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, List<DailyStat> stats) {
    int totalViews = stats.fold(0, (sum, item) => sum + item.views);
    int totalLikes = stats.fold(0, (sum, item) => sum + item.likes);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Views', '$totalViews', Icons.visibility, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Total Likes', '$totalLikes', Icons.favorite, Colors.pink)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Engagement Overview',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Chart
          GlassContainer(
            padding: const EdgeInsets.all(24),
            height: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.map((stat) {
                // Normalize height (max 200px)
                double maxViews = stats.map((e) => e.views).reduce((a, b) => a > b ? a : b).toDouble();
                double height = (stat.views / maxViews) * 200;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.withOpacity(0.8), Colors.orange.withOpacity(0.4)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('E').format(stat.date),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
           Text(
            'Top Performing Posts',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mock List
          _buildPostStatItem('Morning Workout Routine', '1.2k views', '452 likes'),
          _buildPostStatItem('Healthy Meal Prep', '890 views', '320 likes'),
          _buildPostStatItem('Gym Fail Compilation', '560 views', '120 likes'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Icon(Icons.arrow_upward, color: Colors.green.shade400, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildPostStatItem(String title, String views, String likes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('$views • $likes', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
