import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pulses_controller.dart';
import '../widgets/pulse_player.dart';
import '../../../../config/theme.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';

class PulseFeedScreen extends ConsumerStatefulWidget {
  const PulseFeedScreen({super.key});

  @override
  ConsumerState<PulseFeedScreen> createState() => _PulseFeedScreenState();
}

class _PulseFeedScreenState extends ConsumerState<PulseFeedScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pulsesControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterTab('For You', state.gymFilterId == null, () => ref.read(pulsesControllerProvider.notifier).toggleGymFilter(null)),
            const SizedBox(width: 16),
            const Text('|', style: TextStyle(color: Colors.white24)),
            const SizedBox(width: 16),
            // Example Gym ID hardcoded for prototype/test, ideally fetched from user profile
            _buildFilterTab('My Gym', state.gymFilterId != null, () => ref.read(pulsesControllerProvider.notifier).toggleGymFilter('gym-123')), 
          ],
        ),
        leading: BackButton(color: Colors.white, onPressed: () => Navigator.of(context).pop()),
      ),
      body: state.isLoading && state.pulses.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.volt))
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: state.pulses.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return PulsePlayer(
                  pulse: state.pulses[index],
                  isVisible: index == _currentIndex,
                );
              },
            ),
    );
  }

  Widget _buildFilterTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }
}
