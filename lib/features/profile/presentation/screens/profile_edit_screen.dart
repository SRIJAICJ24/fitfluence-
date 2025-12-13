import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1. Ambient Background (Consistent with Home)
          Container(
             decoration: const BoxDecoration(
               gradient: LinearGradient(
                 begin: Alignment.topCenter,
                 end: Alignment.bottomCenter,
                 colors: [AppColors.deepSlate, AppColors.midnightBlue],
               ),
             ),
          ),
          // Ambient Glows
          Positioned(
             top: -100, // Higher glow for profile
             right: -50,
             child: Container(
               width: 300,
               height: 300,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: AppColors.volt.withOpacity(0.15), // Volt glow for energy
               ),
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                 child: Container(color: Colors.transparent),
               ),
             ),
           ),

          // 2. Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                   // Header
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       IconButton(
                         icon: const Icon(Icons.arrow_back, color: AppColors.lightSlate),
                         onPressed: () => context.go('/home'),
                       ),
                       Text('My Profile', style: Theme.of(context).textTheme.headlineMedium),
                       IconButton(
                         icon: const Icon(Icons.settings, color: AppColors.lightSlate),
                         onPressed: () {}, 
                       ),
                     ],
                   ),
                   const SizedBox(height: 32),

                   // Avatar Section
                   const CircleAvatar(
                     radius: 60,
                     backgroundColor: AppColors.volt,
                     child: CircleAvatar(
                       radius: 56,
                       backgroundImage: NetworkImage('https://placehold.co/200x200.png'),
                     ),
                   ),
                   const SizedBox(height: 16),
                   Text('Alex Johnson', style: Theme.of(context).textTheme.displayMedium),
                   const Text('@alex_fits', style: TextStyle(color: AppColors.slateGrey, fontSize: 16)),
                   
                   const SizedBox(height: 32),
                   
                   // Stats Grid
                   Row(
                     children: [
                       _buildStatCard('Workouts', '42', AppColors.cyan),
                       const SizedBox(width: 16),
                       _buildStatCard('Hours', '38', AppColors.indigo),
                       const SizedBox(width: 16),
                       _buildStatCard('Buddies', '12', AppColors.volt),
                     ],
                   ),

                   const SizedBox(height: 32),

                   // Settings/Actions List
                   GlassContainer(
                     padding: const EdgeInsets.symmetric(vertical: 8),
                     child: Column(
                       children: [
                         _buildListTile(Icons.person_outline, 'Edit Personal Details', onTap: (){}),
                         const Divider(color: Colors.white10),
                         _buildListTile(Icons.notifications_outlined, 'Notifications', onTap: (){}),
                         const Divider(color: Colors.white10),
                         _buildListTile(Icons.lock_outline, 'Privacy & Security', onTap: (){}),
                         const Divider(color: Colors.white10),
                         _buildListTile(Icons.help_outline, 'Help & Support', onTap: (){}),
                       ],
                     ),
                   ),

                   const SizedBox(height: 32),
                   
                   // Danger Zone
                   GlassContainer(
                     backgroundColor: AppColors.private.withOpacity(0.1),
                     child: ListTile(
                       leading: const Icon(Icons.logout, color: AppColors.private),
                       title: const Text('Log Out', style: TextStyle(color: AppColors.private, fontWeight: FontWeight.bold)),
                       onTap: () {
                         // Mock Logout
                         context.go('/auth');
                       },
                     ),
                   ),
                   
                   const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.slateGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.lightSlate),
      title: Text(title, style: const TextStyle(color: AppColors.lightSlate)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.slateGrey, size: 20),
      onTap: onTap,
    );
  }
}
