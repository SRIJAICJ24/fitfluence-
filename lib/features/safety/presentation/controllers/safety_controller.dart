import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/safety_repository_impl.dart';
import '../../domain/repositories/safety_repository.dart';

// Repository Provider
final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  return SafetyRepositoryImpl(Supabase.instance.client);
});

// Controller State (AsyncValue<void>) represents loading/error/success of action
class SafetyController extends StateNotifier<AsyncValue<void>> {
  final SafetyRepository _repository;

  SafetyController(this._repository) : super(const AsyncValue.data(null));

  Future<void> blockUser(String blockedUserId, {String? reason}) async {
    state = const AsyncValue.loading();
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await _repository.blockUser(userId, blockedUserId, reason);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reportUser({
    required String reportedUserId,
    required String reportType,
    String? messageId,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await _repository.reportUser(
        reporterId: userId,
        reportedUserId: reportedUserId,
        reportType: reportType,
        messageId: messageId,
        description: description,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final safetyControllerProvider = StateNotifierProvider<SafetyController, AsyncValue<void>>((ref) {
  final repo = ref.watch(safetyRepositoryProvider);
  return SafetyController(repo);
});
