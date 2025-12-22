import '../models/match_model.dart';

abstract class BuddyRepository {
  /// Triggers the calculation of matches for the [userId].
  /// Fetches fresh data, runs the algorithm, and updates the cache.
  Future<void> updateMatchCache(String userId);

  /// Retrieves cached matches for the [userId].
  /// [minScore] filters low-quality matches.
  Future<List<MatchResult>> getMatches(String userId, {double minScore = 0});

  /// Sends a buddy request from [requesterId] to [recipientId].
  Future<void> sendBuddyRequest(String requesterId, String recipientId);

  /// Fetches pending requests for [userId] (where they are recipient).
  Future<List<Map<String, dynamic>>> getPendingRequests(String userId);

  /// Responds to a request (accept/reject).
  Future<void> respondToRequest(String requestId, String status);

  /// Fetches active connections for [userId].
  Future<List<Map<String, dynamic>>> getConnections(String userId);
}
