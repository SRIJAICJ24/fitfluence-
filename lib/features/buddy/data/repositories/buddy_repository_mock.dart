import '../../domain/entities/buddy_match.dart';
import '../../domain/repositories/buddy_repository.dart';

class BuddyRepositoryMock implements BuddyRepository {
  @override
  Future<List<BuddyMatch>> getPotentialMatches(String userId) async {
    // Mock Data for UI Development
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const BuddyMatch(
        id: '1',
        firstName: 'Sarah',
        lastName: 'Connor',
        avatarUrl: 'https://placehold.co/400x600/png',
        age: 28,
        photos: ['https://placehold.co/400x600/png'],
        fitnessGoals: ['Strength', 'HIIT'],
        fitnessLevel: 'Advanced',
        gymId: 'gym_1',
        gymName: "Gold's Gym",
        mentalHealthComfort: 'Very Open',
        availableDays: ['Mon', 'Wed', 'Fri'],
        distance: 1.2,
        matchScore: 92,
        matchReasons: ['Compatible Goals', 'Nearby'],
      ),
       const BuddyMatch(
        id: '2',
        firstName: 'Mike',
        lastName: 'Ross',
        avatarUrl: 'https://placehold.co/400x601/png',
        age: 26,
        photos: ['https://placehold.co/400x601/png'],
        fitnessGoals: ['Hypertrophy'],
        fitnessLevel: 'Intermediate',
        gymId: 'gym_2',
        gymName: "Anytime Fitness",
        mentalHealthComfort: 'Moderate',
        availableDays: ['Tue', 'Thu'],
        distance: 3.5,
        matchScore: 78,
        matchReasons: ['Similar Level'],
      ),
    ];
  }

  @override
  Future<void> swipeUser(String userId, String targetUserId, bool isLike) async {
    // Mock API call
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
