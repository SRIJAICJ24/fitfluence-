import '../entities/flex_story.dart';
import '../entities/post.dart';
import '../entities/pulse.dart';

abstract class SocialRepository {
  /// Fetches active stories (expires_at > now) for the given user's feed.
  /// Typically friends + gym buddies.
  Future<List<FlexStory>> getActiveStories(String userId);

  /// Posts a new flex story.
  Future<void> postStory(String userId, String mediaUrl, String type, int streakCount, String? gymId);

  /// Fetches the main home feed (posts from following + algorithm).
  Future<List<Post>> getHomeFeed(String userId);

  /// Fetches posts only from users the current user follows.
  Future<List<Post>> getFollowingFeed(String userId);

  /// Fetches posts for a specific user profile.
  Future<List<Post>> getUserPosts(String userId);

  /// Fetches short-form content.
  /// If [gymIdFilter] is provided, returns only pulses from that gym.
  Future<List<Pulse>> getPulses(String userId, {String? gymIdFilter});

  // Social Graph
  Future<void> followUser(String followerId, String targetId);
  Future<void> unfollowUser(String followerId, String targetId);
  Future<bool> isFollowing(String followerId, String targetId);

  // Interaction
  Future<void> likePost(String userId, String postId);
  Future<void> unlikePost(String userId, String postId);
}
