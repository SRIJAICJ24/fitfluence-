import 'package:equatable/equatable.dart';

class BuddyMatch extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final int age;
  final List<String> photos;
  final List<String> fitnessGoals;
  final String fitnessLevel;
  final String gymId;
  final String gymName;
  final String mentalHealthComfort;
  final List<String> availableDays;
  final double distance; // in km
  final int matchScore; // 0-100
  final List<String> matchReasons;

  const BuddyMatch({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.age,
    required this.photos,
    required this.fitnessGoals,
    required this.fitnessLevel,
    required this.gymId,
    required this.gymName,
    required this.mentalHealthComfort,
    required this.availableDays,
    required this.distance,
    required this.matchScore,
    required this.matchReasons,
  });

  @override
  List<Object?> get props => [
        id, matchScore, distance, fitnessGoals, fitnessLevel
      ];
}
