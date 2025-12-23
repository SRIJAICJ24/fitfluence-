import '../domain/models/match_model.dart';
import 'dart:math' as math;

class MatchingService {
  
  /// MAIN ENTRY POINT
  /// Calculates match scores for a target User against a list of Candidates.
  List<MatchResult> calculateMatches(MatchCandidate user, List<MatchCandidate> candidates) {
    final results = <MatchResult>[];

    for (final candidate in candidates) {
      // --- STAGE 1: HARD FILTERS ---
      // 1. Same Gym?
      if (candidate.gymId != user.gymId) continue;
      
      // 2. Not Self?
      if (candidate.id == user.id) continue;

      // 3. Recently Active? (e.g. within 30 days)
      if (!_isRecentlyActive(candidate.lastActiveAt)) continue;

      // (Gender & Blocks checks would happen here or in DB query)

      // --- STAGE 2: WEIGHTED SCORING (0-100) ---
      final breakdown = <String, dynamic>{};
      double totalScore = 0;

      // 1. Goals (Jaccard) - Max 30
      final goalScore = _calculateJaccardScore(user.goals, candidate.goals) * 30;
      totalScore += goalScore;
      breakdown['goals_score'] = goalScore;
      breakdown['common_goals'] = _getIntersection(user.goals, candidate.goals).toList();

      // 2. Schedule (Overlap) - Max 25
      final scheduleScore = _calculateScheduleScore(user.schedule, candidate.schedule) * 25;
      totalScore += scheduleScore;
      breakdown['schedule_score'] = scheduleScore;
      breakdown['common_days'] = _getIntersection(user.schedule, candidate.schedule).toList();

      // 3. Fitness Level (Proximity) - Max 15
      final levelScore = _calculateLevelScore(user.fitnessLevel, candidate.fitnessLevel);
      totalScore += levelScore;
      breakdown['level_score'] = levelScore;

      // 4. Age (Band) - Max 5 (Simple logic for prototype)
      final ageScore = _calculateAgeScore(user.birthYear, candidate.birthYear);
      totalScore += ageScore;
      breakdown['age_score'] = ageScore;

      // 5. Time Window (>45m overlap) - Max 15
      final timeScore = _calculateTimeScore(user, candidate);
      totalScore += timeScore;
      breakdown['time_score'] = timeScore;

      // 6. Vibe (Mental Health Comfort) - Max 10 (Part of Age/Vibe bucket)
      final vibeScore = _calculateVibeScore(user.mentalHealthComfort, candidate.mentalHealthComfort);
      totalScore += vibeScore;
      breakdown['vibe_score'] = vibeScore;

      // TODO: Time of Day & Vibe (Need more data fields)

      // Clamp to 100
      final finalScore = math.min(totalScore, 100.0);

      results.add(MatchResult(
        candidateId: candidate.id,
        score: double.parse(finalScore.toStringAsFixed(1)),
        details: breakdown,
      ));
    }

    // Sort by highest score
    results.sort((a, b) => b.score.compareTo(a.score));
    
    return results;
  }

  // --- HELPER LOGIC ---

  bool _isRecentlyActive(DateTime? lastActive) {
    if (lastActive == null) return false; // Strict: Must have logged in
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return lastActive.isAfter(thirtyDaysAgo);
  }

  /// Jaccard Index = (Intersection / Union)
  double _calculateJaccardScore(List<String> setA, List<String> setB) {
    final a = setA.map((e) => e.toLowerCase()).toSet();
    final b = setB.map((e) => e.toLowerCase()).toSet();

    if (a.isEmpty || b.isEmpty) return 0.0;

    final intersection = a.intersection(b).length;
    final union = a.union(b).length;

    return union == 0 ? 0.0 : intersection / union;
  }

  /// Schedule Score = Match % of User A's need
  /// e.g. If I go Mon/Wed, and you go Mon/Wed/Fri -> 100% match for ME.
  double _calculateScheduleScore(List<String> myDays, List<String> theirDays) {
     final mine = myDays.map((e) => e.toLowerCase()).toSet();
     final theirs = theirDays.map((e) => e.toLowerCase()).toSet();

     if (mine.isEmpty) return 0.0;

     final matchingDays = mine.intersection(theirs).length;
     // How many of MY days can you meet?
     return matchingDays / mine.length;
  }

  double _calculateLevelScore(String myLevel, String theirLevel) {
    const levels = ['beginner', 'intermediate', 'advanced'];
    
    final i1 = levels.indexOf(myLevel.toLowerCase());
    final i2 = levels.indexOf(theirLevel.toLowerCase());

    if (i1 == -1 || i2 == -1) return 0.0; // Unknown level

    final diff = (i1 - i2).abs();
    if (diff == 0) return 15.0; // Same level
    if (diff == 1) return 7.0;  // Adjacent
    return 0.0;                 // Too far apart
  }

  double _calculateAgeScore(int? y1, int? y2) {
    if (y1 == null || y2 == null) return 0.0;
    final diff = (y1 - y2).abs();
    if (diff <= 5) return 5.0;
    return 0.0;
  }

  double _calculateVibeScore(String? v1, String? v2) {
    if (v1 == null || v2 == null) return 0.0;
    return (v1 == v2) ? 10.0 : 0.0;
  }

  double _calculateTimeScore(MatchCandidate u1, MatchCandidate u2) {
    if (u1.availableStartTime == null || u1.availableEndTime == null ||
        u2.availableStartTime == null || u2.availableEndTime == null) {
      return 0.0;
    }

    try {
      final start1 = _parseTime(u1.availableStartTime!);
      final end1 = _parseTime(u1.availableEndTime!);
      final start2 = _parseTime(u2.availableStartTime!);
      final end2 = _parseTime(u2.availableEndTime!);

      // Calculate Overlap
      final overlapStart = math.max(start1, start2);
      final overlapEnd = math.min(end1, end2);

      final overlapMinutes = overlapEnd - overlapStart;
      
      if (overlapMinutes >= 45) return 15.0;
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Helper: Convert HH:MM:SS to minutes from midnight
  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return (h * 60) + m;
  }

  Set<String> _getIntersection(List<String> a, List<String> b) {
     return a.toSet().intersection(b.toSet());
  }
}
