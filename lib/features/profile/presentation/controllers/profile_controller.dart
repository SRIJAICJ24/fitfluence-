import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(Supabase.instance.client);
});

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<ProfileModel?>>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  // Get current user directly from Supabase instance as AuthController might not expose it easily as a property
  final user = Supabase.instance.client.auth.currentUser;
  return ProfileController(repo, user?.id);
});

class ProfileController extends StateNotifier<AsyncValue<ProfileModel?>> {
  final ProfileRepository _repository;
  final String? _userId;

  ProfileController(this._repository, this._userId) : super(const AsyncLoading()) {
    if (_userId != null) {
      loadProfile();
    } else {
      state = const AsyncData(null);
    }
  }

  Future<void> loadProfile() async {
    if (_userId == null) return;
    try {
      final profile = await _repository.getProfile(_userId!);
      // Ensure casting if necessary, but ideally repository returns the correct type.
      // If getProfile returns Profile entity, we might need a cast or just usage.
      // ProfileModel extends Profile, so if the repo returns ProfileModel it's fine.
      state = AsyncData(profile as ProfileModel?);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
