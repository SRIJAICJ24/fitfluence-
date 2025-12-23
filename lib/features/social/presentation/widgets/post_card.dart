import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';
import '../../domain/entities/post.dart';
import 'prismatic_border.dart';
import '../controllers/posts_controller.dart';
import '../../monetization/data/repositories/subscription_repository.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class PostCard extends ConsumerWidget {
  final Post post;
  final int streak; 

  const PostCard({super.key, required this.post, this.streak = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(userSubscriptionProvider);
    final isPro = subscriptionState.value?.isPro ?? false;
    final isPremiumContent = post.caption?.toLowerCase().contains('#pro') ?? false;
    final isLocked = isPremiumContent && !isPro;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: PrismaticBorder(
        isPr: post.isPr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: post.userAvatar != null ? NetworkImage(post.userAvatar!) : null,
                    backgroundColor: AppColors.deepSlate,
                    child: post.userAvatar == null ? const Icon(Icons.person, size: 16) : null,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userName ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      if (post.locationName != null)
                        Text(post.locationName!, style: const TextStyle(color: AppColors.slateGrey, fontSize: 10)),
                    ],
                  ),
                  const Spacer(),
                  // Streak Badge
                  if (streak > 0)
                     Padding(
                       padding: const EdgeInsets.only(right: 8),
                       child: Row(
                         children: [
                           const Icon(Icons.local_fire_department, color: AppColors.volt, size: 16),
                           Text('$streak', style: const TextStyle(color: AppColors.volt, fontWeight: FontWeight.bold, fontSize: 12)),
                         ],
                       ),
                     ),
                  if (post.isPr)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.volt,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('PR 🏆', style: TextStyle(color: AppColors.deepSlate, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                ],
              ),
            ),
            
            // Media Carousel (Simplified for MVP as single image or first of list)
            // Media Carousel (Simplified for MVP as single image or first of list)
            AspectRatio(
              aspectRatio: 1.0, // Square posts
              child: Stack(
                fit: StackFit.expand,
                children: [
                   ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: isLocked ? 20 : 0, 
                      sigmaY: isLocked ? 20 : 0
                    ),
                    child: post.mediaUrls.isNotEmpty 
                      ? Image.network(post.mediaUrls.first, fit: BoxFit.cover)
                      : Container(color: Colors.grey[900], child: const Icon(Icons.image, color: Colors.white)),
                  ),
                  if (isLocked)
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/paywall'),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          borderRadius: 20,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock, color: Colors.amber, size: 32),
                              const SizedBox(height: 8),
                              const Text('Pro Content', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Tap to Unlock', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                   GestureDetector(
                     onTap: () => ref.read(postsControllerProvider.notifier).toggleLike(post.id),
                     child: AnimatedSwitcher(
                       duration: const Duration(milliseconds: 300),
                       transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                       child: Icon(
                         post.isLiked ? Icons.favorite : Icons.favorite_border,
                         key: ValueKey(post.isLiked),
                         color: post.isLiked ? AppColors.error : Colors.white,
                       ),
                     ),
                   ),
                   const SizedBox(width: 4),
                   Text('${post.likeCount}', style: const TextStyle(color: Colors.white)),
                   const SizedBox(width: 16),
                   const Icon(Icons.chat_bubble_outline, color: Colors.white),
                   const SizedBox(width: 4),
                   Text('${post.commentCount}', style: const TextStyle(color: Colors.white)),
                   const Spacer(),
                   const Icon(Icons.bookmark_border, color: Colors.white),
                ],
              ),
            ),

            // Caption
            if (post.caption != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text.rich(
                  TextSpan(
                    text: "${post.userName} ",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: post.caption, style: const TextStyle(fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ),
              
             const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
