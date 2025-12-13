import '../../domain/entities/buddy_match.dart';

class BuddyMatchModel extends BuddyMatch {
  const BuddyMatchModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.avatarUrl,
    required super.age,
    required super.photos,
    required super.fitnessGoals,
    required super.fitnessLevel,
    required super.gymId,
    required super.gymName,
    required super.mentalHealthComfort,
    required super.availableDays,
    required super.distance,
    required super.matchScore,
    required super.matchReasons,
  });

  factory BuddyMatchModel.fromJson(Map<String, dynamic> json) {
    return BuddyMatchModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      avatarUrl: json['avatar_url'] as String,
      age: json['age'] as int,
      photos: List<String>.from(json['photos'] ?? []),
      fitnessGoals: List<String>.from(json['fitness_goals'] ?? []),
      fitnessLevel: json['fitness_level'] as String,
      gymId: json['gym_id'] as String,
      gymName: json['gym_name'] as String,
      mentalHealthComfort: json['mental_health_comfort'] as String,
      availableDays: List<String>.from(json['available_days'] ?? []),
      distance: (json['distance'] as num).toDouble(),
      matchScore: json['match_score'] as int,
      matchReasons: List<String>.from(json['match_reasons'] ?? []),
    );
  }
}
