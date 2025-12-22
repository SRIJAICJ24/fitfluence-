import 'package:equatable/equatable.dart';

class MatchCandidate extends Equatable {
  final String id;
  final String gymId;
  final String? gender;
  final List<String> goals;
  final List<String> schedule; // e.g. ["Mon", "Wed"]
  final String fitnessLevel; // "Beginner", "Intermediate", "Advanced"
  final DateTime? lastActiveAt;
  final int? birthYear; // For age calculation

  const MatchCandidate({
    required this.id,
    required this.gymId,
    this.gender,
    this.goals = const [],
    this.schedule = const [],
    this.fitnessLevel = 'Intermediate',
    this.lastActiveAt,
    this.birthYear,
  });

  factory MatchCandidate.fromJson(Map<String, dynamic> json) {
    return MatchCandidate(
      id: json['id'] as String,
      gymId: json['gym_id'] as String? ?? '', // Important: Gym ID is required for hard filter
      gender: json['gender'] as String?,
      goals: List<String>.from(json['fitness_goals'] ?? []),
      schedule: List<String>.from(json['available_days'] ?? []),
      fitnessLevel: json['fitness_level'] as String? ?? 'Intermediate',
      lastActiveAt: json['last_active_at'] != null 
          ? DateTime.tryParse(json['last_active_at']) 
          : null,
      // birth_date expected, simplified to year for logic
      birthYear: json['birth_date'] != null 
          ? DateTime.tryParse(json['birth_date'])?.year 
          : null,
    );
  }

  @override
  List<Object?> get props => [id, gymId, goals, schedule, fitnessLevel];
}

class MatchResult extends Equatable {
  final String candidateId;
  final double score;
  final Map<String, dynamic> details;

  const MatchResult({
    required this.candidateId,
    required this.score,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'details': details,
    };
  }
  
  @override
  List<Object?> get props => [candidateId, score];
}
