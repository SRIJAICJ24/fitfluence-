import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../domain/models/flex_story_model.dart';

class StoryBubble extends StatelessWidget {
  final FlexStory story;
  final bool isSeen;
  final VoidCallback onTap;

  const StoryBubble({
    super.key,
    required this.story,
    required this.onTap,
    this.isSeen = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3), // Border width
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSeen
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.volt, AppColors.neonBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: isSeen ? Colors.white38 : null,
            ),
            child: Container(
              padding: const EdgeInsets.all(2), // Spacing
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black, // Dark background behind avatar
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundImage: story.userAvatar != null ? NetworkImage(story.userAvatar!) : null,
                backgroundColor: AppColors.deepSlate,
                child: story.userAvatar == null
                    ? Text(
                        (story.userName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            story.userName ?? 'User',
            style: const TextStyle(color: Colors.white, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
