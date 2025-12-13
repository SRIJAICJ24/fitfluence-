import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';
import '../../domain/entities/buddy_match.dart';

class SkewedCard extends StatelessWidget {
  final BuddyMatch match;

  const SkewedCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    // 3D Transform
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..rotateZ(-0.05), // -3 degrees tilt
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 1. Background Image
              Positioned.fill(
                child: Image.network(
                  match.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) => Container(color: AppColors.midnightBlue),
                ),
              ),

              // 2. Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.deepSlate.withOpacity(0.1),
                        AppColors.deepSlate.withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Content
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Match Score Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.volt,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${match.matchScore}% Match',
                        style: const TextStyle(
                          color: AppColors.deepSlate,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Name & Age
                    Text(
                      '${match.firstName}, ${match.age}',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 4),
                    
                    // Gym Info
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.slateGrey),
                        const SizedBox(width: 4),
                        Text(
                          match.gymName,
                          style: const TextStyle(color: AppColors.slateGrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: match.fitnessGoals.take(3).map((goal) {
                        return GlassContainer(
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Text(
                            goal,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
