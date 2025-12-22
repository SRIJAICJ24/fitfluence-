import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/gym_model.dart';
import '../../domain/repositories/gym_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  return GymRepositoryImpl(Supabase.instance.client);
});

class GymRepositoryImpl implements GymRepository {
  final SupabaseClient _supabase;

  GymRepositoryImpl(this._supabase);

  @override
  Future<List<GymModel>> searchGyms(String query) async {
    try {
      final response = await _supabase
          .from('gyms')
          .select()
          .ilike('name', '%$query%') // Case-insensitive partial match
          .limit(20);

      return (response as List).map((data) => GymModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to search gyms: $e');
    }
  }

  @override
  Future<GymModel?> getGymById(String id) async {
    try {
      final response = await _supabase
          .from('gyms')
          .select()
          .eq('id', id)
          .single();

      return GymModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<GymModel>> getNearbyGyms(double lat, double lon, {double radiusKm = 10}) async {
    // Note: This is an improved query that would ideally use PostGIS if available.
    // For Phase 1 Standard Postgres, we'll just fetch all active gyms and filter or limit.
    // In a real app with many gyms, use strict BBox filtering or RPC.
    try {
      final response = await _supabase
          .from('gyms')
          .select()
          .eq('is_active', true)
          .limit(50);

      return (response as List).map((data) => GymModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch nearby gyms: $e');
    }
  }
}
