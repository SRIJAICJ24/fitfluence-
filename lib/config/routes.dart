import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/phone_otp_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart'; // Keep for reference or remove
import '../features/auth/presentation/screens/vitality_onboarding_screen.dart';
import '../features/profile/presentation/screens/profile_edit_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/photo_upload_screen.dart';
import '../features/gym/presentation/screens/gym_search_screen.dart';
import '../features/gym/presentation/screens/gym_detail_screen.dart';
import '../features/buddy/presentation/screens/buddy_discovery_screen.dart';
import '../features/buddy/presentation/screens/buddy_list_screen.dart'; // NEW
import '../features/messaging/presentation/screens/conversation_list_screen.dart';
import '../features/messaging/presentation/screens/chat_screen.dart';
import '../shared/presentation/widgets/navigation/main_shell.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/social/presentation/screens/pulse_feed_screen.dart';
import '../features/stories/presentation/screens/create_story_screen.dart';
import '../features/social/presentation/screens/followers_list_screen.dart';
import '../features/monetization/presentation/screens/paywall_screen.dart';
import '../features/monetization/presentation/screens/analytics_dashboard_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/home', // Optimistic default
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isOnAuthPage = state.matchedLocation.startsWith('/auth');

    if (session == null && !isOnAuthPage) {
      return '/auth'; // Redirect to login if user is not signed in
    }
    if (session != null && isOnAuthPage) {
      return '/home'; // Redirect to home if user is already signed in
    }
    return null;
  },
  routes: [
    // --- Auth Routes (No Bottom Nav) ---
    GoRoute(
      path: '/auth',
      builder: (context, state) => const LoginScreen(),
      routes: [
        GoRoute(
          path: 'phone-otp',
          builder: (context, state) => const PhoneOtpScreen(),
        ),
        GoRoute(
          path: 'onboarding',
          builder: (context, state) => const VitalityOnboardingScreen(),
        ),
      ],
    ),
    
    // --- Main App Shell ---
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/gym-search',
          builder: (context, state) => const GymSearchScreen(),
          routes: [
            GoRoute(
              path: ':gymId',
              builder: (context, state) {
                final gymId = state.pathParameters['gymId']!;
                return GymDetailScreen(gymId: gymId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/buddy-discovery',
          builder: (context, state) => const BuddyDiscoveryScreen(),
          routes: [
             GoRoute(
              path: 'list',
              builder: (context, state) => const BuddyListScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const ConversationListScreen(),
          routes: [
             GoRoute(
              path: ':conversationId',
              builder: (context, state) {
                final conversationId = state.pathParameters['conversationId']!;
                return ChatScreen(conversationId: conversationId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/profile', // New Profile
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const ProfileEditScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/pulses',
          builder: (context, state) => const PulseFeedScreen(),
        ),
        GoRoute(
          path: '/create-story',
          builder: (context, state) => const CreateStoryScreen(),
        ),
      ],
    ),
    
    // Followers List (Standalone or stacked)
    GoRoute(
      path: '/profile/followers/:userId',
      builder: (context, state) {
         final userId = state.pathParameters['userId']!;
         return FollowersListScreen(userId: userId, initialTabIndex: 0); 
      },
    ),
    GoRoute(
      path: '/profile/following/:userId',
      builder: (context, state) {
         final userId = state.pathParameters['userId']!;
         return FollowersListScreen(userId: userId, initialTabIndex: 1); 
      },
    ),

    // --- Standalone Routes (Modal/Fullscreen) ---
    GoRoute(
      path: '/profile/photo-upload',
      builder: (context, state) => const PhotoUploadScreen(),
    ),
    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => AnalyticsDashboardScreen(userId: Supabase.instance.client.auth.currentUser!.id),
    ),
  ],
);
