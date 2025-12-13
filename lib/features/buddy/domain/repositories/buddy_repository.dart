import '../../domain/entities/buddy_match.dart';

abstract class BuddyRepository {
  Future<List<BuddyMatch>> getPotentialMatches(String userId);
  Future<void> swipeUser(String userId, String targetUserId, bool isLike);
}
