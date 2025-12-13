import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../data/repositories/buddy_repository_mock.dart';
import '../../domain/entities/buddy_match.dart';
import '../widgets/skewed_card.dart';

class BuddyDiscoveryScreen extends StatefulWidget {
  const BuddyDiscoveryScreen({super.key});

  @override
  State<BuddyDiscoveryScreen> createState() => _BuddyDiscoveryScreenState();
}

class _BuddyDiscoveryScreenState extends State<BuddyDiscoveryScreen> {
  final _repository = BuddyRepositoryMock();
  List<BuddyMatch> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    final matches = await _repository.getPotentialMatches('user_1');
    setState(() {
      _matches = matches;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Buddies'),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.volt))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: _matches.isEmpty
                    ? [const Center(child: Text('No matches found'))]
                    : _matches.map((match) {
                        // In a real app, use a Tinder-like draggable swiper package.
                        // For this implementation, we stack them.
                        // The top card is the last one in the list.
                        return Draggable(
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: SkewedCard(match: match),
                            ),
                          ),
                          childWhenDragging: Container(), // disappear when dragging
                          onDragEnd: (details) {
                             if (details.velocity.pixelsPerSecond.dx > 100 || 
                                 details.velocity.pixelsPerSecond.dx < -100) {
                                // Swiped
                                setState(() {
                                  _matches.remove(match);
                                });
                             }
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: SkewedCard(match: match),
                          ),
                        );
                      }).toList(),
              ),
            ),
       bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionButton(
              icon: Icons.close,
              color: AppColors.private,
              onTap: () {
                if (_matches.isNotEmpty) {
                  setState(() => _matches.removeLast());
                }
              },
            ),
            _ActionButton(
              icon: Icons.favorite,
              color: AppColors.volt,
              onTap: () {
                 if (_matches.isNotEmpty) {
                  setState(() => _matches.removeLast());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.deepSlate,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
            )
          ],
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}
