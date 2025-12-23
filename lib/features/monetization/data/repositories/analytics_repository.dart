import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsRepositoryProvider = Provider((ref) => AnalyticsRepository());

class AnalyticsRepository {
  Future<List<DailyStat>> getDailyStats(String userId) async {
    // Mock data
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(7, (index) {
      return DailyStat(
        date: DateTime.now().subtract(Duration(days: 6 - index)),
        views: 100 + (index * 20) + (index % 2 * 50),
        likes: 20 + (index * 5),
        interactions: 5 + index,
      );
    });
  }
}

class DailyStat {
  final DateTime date;
  final int views;
  final int likes;
  final int interactions;

  DailyStat({
    required this.date,
    required this.views,
    required this.likes,
    required this.interactions,
  });
}
