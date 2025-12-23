import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class PulseVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const PulseVideoPlayer({super.key, required this.videoUrl, this.thumbnailUrl});

  @override
  State<PulseVideoPlayer> createState() => _PulseVideoPlayerState();
}

class _PulseVideoPlayerState extends State<PulseVideoPlayer> {
  // In a real app, initialize VideoPlayerController here.
  // For prototype/web demo stability, we simulate playback UI.
  bool _isPlaying = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isPlaying = !_isPlaying),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background / Thumbnail
          Container(
             color: Colors.black,
             child: widget.thumbnailUrl != null 
                 ? Image.network(widget.thumbnailUrl!, fit: BoxFit.cover)
                 : Image.network("https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop", fit: BoxFit.cover),
          ),
          
          // "Video" Placeholder (e.g. Gif or just static for now)
          // In real implementation: VideoPlayer(_controller)

          // Play/Pause Overlay
          if (!_isPlaying)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Icon(Icons.play_arrow, size: 64, color: AppColors.volt),
              ),
            ),
        ],
      ),
    );
  }
}
