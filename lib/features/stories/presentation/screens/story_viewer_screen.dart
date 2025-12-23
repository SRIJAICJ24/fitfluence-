import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../domain/models/flex_story_model.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<FlexStory> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // 5-second Duration for each story
    _animController = AnimationController(
       vsync: this, 
       duration: const Duration(seconds: 5)
    );
    
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
    } else {
      // End of stories
      context.pop();
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
           final width = MediaQuery.of(context).size.width;
           if (details.globalPosition.dx < width / 3) {
             _prevStory();
           } else {
             _nextStory();
           }
        },
        onLongPressStart: (_) => _animController.stop(),
        onLongPressEnd: (_) => _animController.forward(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.network(
              story.mediaUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(color: AppColors.volt));
              },
            ),

            // Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black54],
                  stops: [0.0, 0.2, 1.0],
                ),
              ),
            ),
            
            // Progress Bar & Header
            SafeArea(
              child: Column(
                children: [
                  // Progress Bars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: List.generate(widget.stories.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: index == _currentIndex
                                ? AnimatedBuilder(
                                    animation: _animController,
                                    builder: (context, child) {
                                      return LinearProgressIndicator(
                                        value: _animController.value,
                                        backgroundColor: Colors.white24,
                                        color: Colors.white,
                                        minHeight: 2,
                                      );
                                    },
                                  )
                                : LinearProgressIndicator(
                                    value: index < _currentIndex ? 1.0 : 0.0,
                                    backgroundColor: Colors.white24,
                                    color: Colors.white,
                                    minHeight: 2,
                                  ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Header (User Info)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: story.userAvatar != null ? NetworkImage(story.userAvatar!) : null,
                          backgroundColor: AppColors.deepSlate,
                          child: story.userAvatar == null 
                            ? Text((story.userName ?? 'U')[0], style: const TextStyle(fontWeight: FontWeight.bold))
                            : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                           story.userName ?? 'User',
                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(DateTime.now().difference(story.createdAt)),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        if (story.isVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.verified, color: AppColors.volt, size: 16),
                          const SizedBox(width: 4),
                          if (story.gymId != null)
                             const Text(
                               "At Gym", // ideally Gym Name lookup
                               style: TextStyle(color: AppColors.volt, fontSize: 12),
                             )
                        ],
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Footer (Streak Badge)
                  if (story.streakType != 'other')
                    Padding(
                       padding: const EdgeInsets.only(bottom: 24),
                       child: GlassContainer(
                         borderRadius: 20,
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             const Icon(Icons.local_fire_department, color: AppColors.volt, size: 20),
                             const SizedBox(width: 8),
                             Text(
                               "${story.streakType.toUpperCase()} STREAK",
                               style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                             ),
                           ],
                         ),
                       ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return "${d.inHours}h ago";
    if (d.inMinutes > 0) return "${d.inMinutes}m ago";
    return "Just now";
  }
}
