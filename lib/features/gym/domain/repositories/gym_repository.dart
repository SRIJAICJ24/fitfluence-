import '../../domain/entities/gym.dart';

abstract class GymRepository {
  Future<List<Gym>> searchGyms(String query);
  Future<List<Gym>> getNearbyGyms(double lat, double lon, {double radius = 5000});
  Future<Gym> getGymDetail(String id);
}
