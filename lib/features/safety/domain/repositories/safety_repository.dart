abstract class SafetyRepository {
  Future<void> blockUser(String blockerId, String blockedUserId, String? reason);
  Future<void> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reportType,
    String? messageId,
    String? description,
  });
}
