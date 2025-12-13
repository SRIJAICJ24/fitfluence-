import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';

class ActiveGrid extends StatelessWidget {
  const ActiveGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Row 1: Gym Status (Large)
          _buildGymStatusCard(context),
          const SizedBox(height: 16),
          // Row 2: Split (Up Next & Stats)
          Row(
            children: [
              Expanded(flex: 3, child: _buildUpNextCard()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildStatsCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGymStatusCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     children: [
                       Icon(Icons.location_on, color: AppColors.volt, size: 16),
                       SizedBox(width: 4),
                       Text('Gold\'s Gym Indiranagar', style: TextStyle(color: AppColors.lightSlate, fontWeight: FontWeight.bold)),
                     ],
                   ),
                   SizedBox(height: 4),
                   Text('6 Friends Active Now', style: TextStyle(color: AppColors.slateGrey, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.volt.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.volt),
                ),
                child: const Text('LIVE', style: TextStyle(color: AppColors.volt, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Avatar Stack Placeholder
          Row(
            children: [
               _avatarStack(),
               const Spacer(),
               ElevatedButton(
                 onPressed: (){},
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppColors.volt,
                   foregroundColor: AppColors.deepSlate,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                   minimumSize: const Size(0, 36),
                 ),
                 child: const Text('Check In'),
               ),
            ],
          )
        ],
      ),
    );
  }

  Widget _avatarStack() {
    return SizedBox(
      height: 32,
      width: 100,
      child: Stack(
        children: [
          for(int i = 0; i < 3; i++)
            Positioned(
              left: i * 20.0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.deepSlate,
                child: CircleAvatar(
                  radius: 14,
                   backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=active$i'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpNextCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Up Next', style: TextStyle(color: AppColors.slateGrey, fontSize: 12)),
          const SizedBox(height: 8),
          const Text('Buddy Workout', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              CircleAvatar(radius: 10, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=buddy')),
              const SizedBox(width: 8),
              const Expanded(child: Text('Rahul K. • 6PM', style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const Text('Streak', style: TextStyle(color: AppColors.slateGrey, fontSize: 12)),
           const SizedBox(height: 8),
           const Text('12 Days', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.cyan)),
           const SizedBox(height: 8),
           // Gradient Bar
           Container(
             height: 4,
             width: double.infinity,
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(2),
               gradient: const LinearGradient(colors: [AppColors.indigo, AppColors.cyan]),
             ),
           ),
        ],
      ),
    );
  }
}
