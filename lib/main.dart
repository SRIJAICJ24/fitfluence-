import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.init(); 

  runApp(
    const ProviderScope(
      child: FitFluenceApp(),
    ),
  );
}

class FitFluenceApp extends StatelessWidget {
  const FitFluenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FitFluence',
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
