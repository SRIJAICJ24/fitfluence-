import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabaseClient;

  ProfileRepositoryImpl(this._supabaseClient);

  @override
  Future<Profile> getProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) {
        // Return a dummy/empty profile if none exists yet, 
        // effectively handling the 'new user' state gracefully.
        return ProfileModel(
          id: userId,
          email: '',
          username: 'New User',
          firstName: 'Guest',
          lastName: '',
          isActive: false, 
          // Default values for required fields
        );
      }
      
      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    try {
      final model = ProfileModel(
        id: profile.id,
        email: profile.email,
        username: profile.username,
        firstName: profile.firstName,
        lastName: profile.lastName,
        bio: profile.bio,
        avatarUrl: profile.avatarUrl,
        gender: profile.gender,
        fitnessLevel: profile.fitnessLevel,
        fitnessGoals: profile.fitnessGoals,
        gymId: profile.gymId,
        mentalHealthComfort: profile.mentalHealthComfort,
        availableDays: profile.availableDays,
        isActive: profile.isActive,
      );

      await _supabaseClient
          .from('profiles')
          .upsert(model.toJson());
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> createProfile(Profile profile) async {
    // This is typically handled by the Database Trigger,
    // but useful for edge cases or admins.
  }
}
