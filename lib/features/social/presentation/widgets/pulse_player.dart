import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../domain/entities/pulse.dart';
import '../../presentation/managers/video_pool_manager.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';

class PulsePlayer extends StatefulWidget {
  final Pulse pulse;
  final bool isVisible;

  const PulsePlayer({super.key, required this.pulse, required this.isVisible});

  @override
  State<PulsePlayer> createState() => _PulsePlayerState();
}

class _PulsePlayerState extends State<PulsePlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) {
      _initVideo();
    }
  }

  @override
  void didUpdateWidget(PulsePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !_isInitialized) {
      _initVideo();
    } else if (!widget.isVisible && _isInitialized) {
      _pauseVideo();
    } else if (widget.isVisible && _isInitialized) {
      _playVideo();
    }
  }

  Future<void> _initVideo() async {
    try {
      final controller = await VideoPoolManager().getController(widget.pulse.videoUrl);
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
        _playVideo();
      }
    } catch (e) {
      debugPrint("Error loading pulse: $e");
    }
  }

  void _playVideo() {
    _controller?.play();
  }

  void _pauseVideo() {
    _controller?.pause();
  }

  @override
  void dispose() {
    // We don't dispose the controller here, we let the PoolManager handle eviction
    // But we should pause it to be safe
    _controller?.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background / Thumbnail
        Container(color: Colors.black),
        if (!_isInitialized && widget.pulse.thumbnailUrl != null)
           Image.network(widget.pulse.thumbnailUrl!, fit: BoxFit.cover),

        // Video
        if (_isInitialized && _controller != null)
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),

        // Loading Indicator
        if (!_isInitialized && widget.isVisible)
          const Center(child: CircularProgressIndicator(color: AppColors.volt)),

        // Overlay UI (Right Side Actions)
        Positioned(
          bottom: 100,
          right: 16,
          child: Column(
            children: [
              _buildAction(Icons.favorite, '${widget.pulse.viewCount}'), // Using viewCount as proxy for likes for now
              const SizedBox(height: 24),
              _buildAction(Icons.chat_bubble, '0'),
              const SizedBox(height: 24),
              _buildAction(Icons.share, '${widget.pulse.shareCount}'),
            ],
          ),
        ),

        // Bottom Info
        Positioned(
          bottom: 24,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.pulse.creatorAvatar != null 
                      ? NetworkImage(widget.pulse.creatorAvatar!) 
                      : null,
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(widget.pulse.creatorName ?? 'Creator', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  if (widget.pulse.gymId != null)
                     GlassContainer(
                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                       borderRadius: 4,
                       child: const Text('My Gym', style: TextStyle(color: AppColors.volt, fontSize: 10)),
                     ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '#${widget.pulse.category.name} #fitness', 
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
