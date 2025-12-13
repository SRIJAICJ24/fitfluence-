import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';

class SupabaseConfig {
  static Future<void> init() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }
}
