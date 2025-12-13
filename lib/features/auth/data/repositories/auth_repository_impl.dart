import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoTrueClient _auth;

  AuthRepositoryImpl(this._auth);

  @override
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;
}
