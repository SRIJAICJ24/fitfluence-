import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/data/repositories/profile_repository_impl.dart';
import '../../../profile/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final onboardingControllerProvider = StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController(
    ref.read(authRepositoryProvider),
    ProfileRepositoryImpl(Supabase.instance.client),
  );
});

class OnboardingController extends StateNotifier<OnboardingState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  OnboardingController(this._authRepository, this._profileRepository) : super(const OnboardingState());

  void updateField({
    String? email, String? password, String? name, String? age, String? gender,
    String? gymId, String? vibe, String? bio
  }) {
    state = state.copyWith(
      email: email, password: password, name: name, age: age, gender: gender,
      gymId: gymId, vibe: vibe, bio: bio
    );
  }

  void toggleGoal(String goal) {
    final currentGoals = List<String>.from(state.goals);
    if (currentGoals.contains(goal)) {
      currentGoals.remove(goal);
    } else {
      currentGoals.add(goal);
    }
    state = state.copyWith(goals: currentGoals);
  }

  void nextStep() {
    if (state.currentStep < 6) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> submit() async {
    state = state.copyWith(isLoading: true);
    try {
      // 1. Sign Up
      final response = await _authRepository.signUpWithEmail(state.email, state.password);
      final userId = response.user?.id;

      if (userId != null) {
        // 2. Create Profile Data
        final nameParts = state.name.trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        
        final profile = ProfileModel(
          id: userId,
          email: state.email,
          username: state.email.split('@').first, // Simple default username
          firstName: firstName,
          lastName: lastName,
          mentalHealthComfort: state.vibe, 
          gymId: state.gymId,
          bio: state.bio,
          fitnessGoals: state.goals,
          // gender: state.gender, // If ProfileModel has gender
        );
        
        await _profileRepository.updateProfile(profile);
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}
