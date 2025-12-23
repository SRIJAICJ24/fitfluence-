import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';
import '../../data/repositories/pulse_repository.dart';
import '../../domain/models/pulse_model.dart';
import 'widgets/pulse_video_player.dart'; // We'll create this next

class PulseFeedScreen extends ConsumerStatefulWidget {
  final String? gymId;
  const PulseFeedScreen({super.key, this.gymId});

  @override
  ConsumerState<PulseFeedScreen> createState() => _PulseFeedScreenState();
}

class _PulseFeedScreenState extends ConsumerState<PulseFeedScreen> {
  final PageController _pageController = PageController();
  List<Pulse> _pulses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPulses();
  }

  Future<void> _loadPulses() async {
    try {
      final repo = ref.read(pulseRepositoryProvider);
      final pulses = await repo.getPulses(gymId: widget.gymId);
      if (mounted) {
        setState(() {
          _pulses = pulses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.volt)),
      );
    }

    if (_pulses.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
        body: const Center(child: Text("No Pulses found.", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _pulses.length,
        itemBuilder: (context, index) {
          return _PulseItem(pulse: _pulses[index]);
        },
      ),
    );
  }
}

class _PulseItem extends StatelessWidget {
  final Pulse pulse;

  const _PulseItem({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Video Player
        PulseVideoPlayer(videoUrl: pulse.videoUrl, thumbnailUrl: pulse.thumbnailUrl),
        
        // 2. Overlay Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black26, Colors.transparent, Colors.black87],
            ),
          ),
        ),

        // 3. UI Controls
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pulse.category.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              
              const Spacer(),

              // Bottom Info Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: pulse.creatorAvatar != null ? NetworkImage(pulse.creatorAvatar!) : null,
                                backgroundColor: AppColors.deepSlate,
                                child: pulse.creatorAvatar == null ? Text((pulse.creatorName ?? 'U')[0]) : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                pulse.creatorName ?? '@user',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              if (pulse.gymId != null)
                               const Icon(Icons.location_on, color: AppColors.volt, size: 16),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                             "Pushing limits today! 🚀 #fitness #gym", // Mock caption as model doesn't have it yet
                             style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    // Right Side Actions
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         _buildAction(Icons.favorite, "${pulse.viewCount}"),
                         _buildAction(Icons.chat_bubble, "0"),
                         _buildAction(Icons.share, "${pulse.shareCount}", onTap: () {
                           Share.share('Check out this Pulse on FitFluence! ${pulse.videoUrl}');
                         }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAction(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            GlassContainer(
               borderRadius: 25,
               padding: const EdgeInsets.all(10),
               child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
