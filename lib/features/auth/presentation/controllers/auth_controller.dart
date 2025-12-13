import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(Supabase.instance.client.auth);
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncData(null));

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _authRepository.signInWithEmail(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _authRepository.signUpWithEmail(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
