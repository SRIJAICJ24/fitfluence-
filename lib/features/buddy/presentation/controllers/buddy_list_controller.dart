import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/buddy_repository.dart';
import '../../data/repositories/buddy_repository_impl.dart';

class BuddyListState {
  final bool isLoading;
  final List<Map<String, dynamic>> requests;
  final List<Map<String, dynamic>> connections;

  BuddyListState({this.isLoading = true, this.requests = const [], this.connections = const []});
}

class BuddyListController extends StateNotifier<BuddyListState> {
  final BuddyRepository _repository;
  final SupabaseClient _supabase;

  BuddyListController(this._repository, this._supabase) : super(BuddyListState()) {
    loadData();
  }

  Future<void> loadData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    state = BuddyListState(isLoading: true);
    try {
      final reqs = await _repository.getPendingRequests(userId);
      final conns = await _repository.getConnections(userId);
      state = BuddyListState(isLoading: false, requests: reqs, connections: conns);
    } catch (e) {
      state = BuddyListState(isLoading: false);
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await _repository.respondToRequest(requestId, 'accepted');
      await loadData(); // Reload all
    } catch (e) {
      // Handle error
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _repository.respondToRequest(requestId, 'rejected');
      await loadData();
    } catch (e) {
      // Handle error
    }
  }
}

final buddyListProvider = StateNotifierProvider<BuddyListController, BuddyListState>((ref) {
  return BuddyListController(
    ref.watch(buddyRepositoryProvider),
    Supabase.instance.client,
  );
});
