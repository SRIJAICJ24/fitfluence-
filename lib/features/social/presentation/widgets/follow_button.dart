import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../controllers/follow_controller.dart';

class FollowButton extends ConsumerWidget {
  final String targetUserId;

  const FollowButton({super.key, required this.targetUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(followControllerProvider(targetUserId));

    if (state.isLoading) {
      return const SizedBox(
        width: 20, 
        height: 20, 
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.volt)
      );
    }

    final isFollowing = state.isFollowing;

    return ElevatedButton(
      onPressed: () => ref.read(followControllerProvider(targetUserId).notifier).toggleFollow(),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.transparent : AppColors.volt,
        foregroundColor: isFollowing ? AppColors.volt : AppColors.deepSlate,
        side: isFollowing ? const BorderSide(color: AppColors.volt) : BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 32),
        elevation: 0,
      ),
      child: Text(
        isFollowing ? 'Following' : 'Follow',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
