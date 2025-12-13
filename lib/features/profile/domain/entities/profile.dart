import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? avatarUrl;
  final String? gender;
  final String? fitnessLevel;
  final List<String> fitnessGoals;
  final String? gymId;
  final String? mentalHealthComfort;
  final List<String> availableDays;
  final bool isActive;

  const Profile({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.bio,
    this.avatarUrl,
    this.gender,
    this.fitnessLevel,
    this.fitnessGoals = const [],
    this.gymId,
    this.mentalHealthComfort,
    this.availableDays = const [],
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        firstName,
        lastName,
        bio,
        avatarUrl,
        gender,
        fitnessLevel,
        fitnessGoals,
        gymId,
        mentalHealthComfort,
        availableDays,
        isActive,
      ];
}
