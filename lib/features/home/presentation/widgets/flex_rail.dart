import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';

class FlexRail extends StatelessWidget {
  const FlexRail({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140, // Height for the rail
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) return const _AddFlexCard();
          return _FlexStoryCard(index: index);
        },
      ),
    );
  }
}

class _AddFlexCard extends StatelessWidget {
  const _AddFlexCard();

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skewX(-0.10), // -6 degrees skew
      alignment: Alignment.center,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.volt.withOpacity(0.5), style: BorderStyle.solid),
          color: AppColors.deepSlate.withOpacity(0.3),
        ),
        child: Transform(
          transform: Matrix4.skewX(0.10), // Counter-skew to keep icon upright
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: AppColors.volt, size: 28),
              SizedBox(height: 4),
              Text('Add Flex', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlexStoryCard extends StatelessWidget {
  final int index;

  const _FlexStoryCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skewX(-0.10),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 90,
          color: AppColors.midnightBlue, // Fallback
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Placeholder Image
              Image.network(
                'https://picsum.photos/seed/flex$index/200/300', 
                fit: BoxFit.cover,
                errorBuilder: (_,__,___) => Container(color: AppColors.midnightBlue),
              ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              // Text Content (Counter-Skewed)
              Transform(
                transform: Matrix4.skewX(0.10),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${12 + index}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const Text(
                        'PR Hit! 🔥', 
                        style: TextStyle(fontSize: 10, color: AppColors.volt),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
