class OnboardingState {
  final int currentStep;
  final String email;
  final String password;
  final String name;
  final String age;
  final String gender;
  final String? gymId;
  final List<String> goals;
  final String vibe; // 'Very Open', 'Moderate', 'Private'
  final String bio;
  final bool isLoading;

  const OnboardingState({
    this.currentStep = 0,
    this.email = '',
    this.password = '',
    this.name = '',
    this.age = '',
    this.gender = '',
    this.gymId,
    this.goals = const [],
    this.vibe = 'Moderate',
    this.bio = '',
    this.isLoading = false,
  });

  OnboardingState copyWith({
    int? currentStep,
    String? email,
    String? password,
    String? name,
    String? age,
    String? gender,
    String? gymId,
    List<String>? goals,
    String? vibe,
    String? bio,
    bool? isLoading,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      gymId: gymId ?? this.gymId,
      goals: goals ?? this.goals,
      vibe: vibe ?? this.vibe,
      bio: bio ?? this.bio,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
