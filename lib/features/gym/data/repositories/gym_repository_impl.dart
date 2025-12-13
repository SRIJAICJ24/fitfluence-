import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/gym.dart';
import '../../domain/repositories/gym_repository.dart';
import '../models/gym_model.dart';

class GymRepositoryImpl implements GymRepository {
  final SupabaseClient _supabaseClient;

  GymRepositoryImpl(this._supabaseClient);

  @override
  Future<List<Gym>> searchGyms(String query) async {
    try {
      final response = await _supabaseClient
          .from('gyms')
          .select()
          .ilike('name', '%$query%')
          .limit(20);
      
      return (response as List).map((data) => GymModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to search gyms: $e');
    }
  }

  @override
  Future<List<Gym>> getNearbyGyms(double lat, double lon, {double radius = 5000}) async {
    // Note: This relies on the 'nearby-gyms' Edge Function or PostGIS query
    // For now, implementing a basic mock or client-side filter if needed, 
    // but referring to the Edge Function call pattern.
    try {
       final response = await _supabaseClient.functions.invoke(
        'nearby-gyms',
        body: {'lat': lat, 'lon': lon, 'radius': radius},
      );
      
      final data = response.data as List;
      return data.map((json) => GymModel.fromJson(json)).toList();
    } catch (e) {
      // Fallback or empty list
      return [];
    }
  }

  @override
  Future<Gym> getGymDetail(String id) async {
    try {
      final response = await _supabaseClient
          .from('gyms')
          .select()
          .eq('id', id)
          .single();
      
      return GymModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get gym detail: $e');
    }
  }
}
