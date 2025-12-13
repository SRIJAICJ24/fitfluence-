import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.username,
    super.firstName,
    super.lastName,
    super.bio,
    super.avatarUrl,
    super.gender,
    super.fitnessLevel,
    super.fitnessGoals,
    super.gymId,
    super.mentalHealthComfort,
    super.availableDays,
    super.isActive,
  });
  
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim().isEmpty ? username : '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      gender: json['gender'] as String?,
      fitnessLevel: json['fitness_level'] as String?,
      fitnessGoals: List<String>.from(json['fitness_goals'] ?? []),
      gymId: json['gym_id'] as String?,
      mentalHealthComfort: json['mental_health_comfort'] as String?,
      availableDays: List<String>.from(json['available_days'] ?? []),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'gender': gender,
      'fitness_level': fitnessLevel,
      'fitness_goals': fitnessGoals,
      'gym_id': gymId,
      'mental_health_comfort': mentalHealthComfort,
      'available_days': availableDays,
      'is_active': isActive,
    };
  }
}
