import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../../data/repositories/follow_repository.dart';

class FollowButton extends ConsumerStatefulWidget {
  final String targetUserId;

  const FollowButton({super.key, required this.targetUserId});

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  bool _isFollowing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final repo = ref.read(followRepositoryProvider);
      final status = await repo.isFollowing(widget.targetUserId);
      if (mounted) {
        setState(() {
          _isFollowing = status;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => _isFollowing = !_isFollowing); // Optimistic

    final repo = ref.read(followRepositoryProvider);
    try {
      if (_isFollowing) {
        await repo.followUser(widget.targetUserId);
      } else {
        await repo.unfollowUser(widget.targetUserId);
      }
    } catch (_) {
      // Revert if failed
      if (mounted) setState(() => _isFollowing = !_isFollowing);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 20, 
        height: 20, 
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.volt)
      );
    }

    return OutlinedButton(
      onPressed: _toggleFollow,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: _isFollowing ? Colors.white30 : AppColors.volt),
        backgroundColor: _isFollowing ? Colors.transparent : AppColors.volt,
        foregroundColor: _isFollowing ? Colors.white : AppColors.deepSlate,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        minimumSize: const Size(0, 32),
      ),
      child: Text(
        _isFollowing ? 'Following' : 'Follow',
        style: TextStyle(
          fontWeight: _isFollowing ? FontWeight.normal : FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
