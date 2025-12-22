import '../models/gym_model.dart';

abstract class GymRepository {
  Future<List<GymModel>> searchGyms(String query);
  Future<GymModel?> getGymById(String id);
  Future<List<GymModel>> getNearbyGyms(double lat, double lon, {double radiusKm = 10});
}
