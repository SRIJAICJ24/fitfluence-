import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:async';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';
import '../../domain/models/gym_model.dart';
import '../../data/repositories/gym_repository_impl.dart';

class GymSearchScreen extends ConsumerStatefulWidget {
  const GymSearchScreen({super.key});

  @override
  ConsumerState<GymSearchScreen> createState() => _GymSearchScreenState();
}

class _GymSearchScreenState extends ConsumerState<GymSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<GymModel> _gyms = [];
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Verify valid user location in real app. For now, use Chennai coordinates.
    _fetchNearby(13.0827, 80.2707);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchNearby(double lat, double lon) async {
    setState(() => _isLoading = true);
    try {
      final gyms = await ref.read(gymRepositoryProvider).getNearbyGyms(lat, lon);
      if (mounted) {
        setState(() {
          _gyms = gyms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isLoading = true);
      try {
        final gyms = query.isEmpty 
            ? await ref.read(gymRepositoryProvider).getNearbyGyms(13.0827, 80.2707)
            : await ref.read(gymRepositoryProvider).searchGyms(query);
            
        if (mounted) {
          setState(() {
            _gyms = gyms;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Search Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Find a Gym'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightSlate),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Stack(
        children: [
          // 1. Ambient Background
          Container(
             decoration: const BoxDecoration(
               gradient: LinearGradient(
                 begin: Alignment.topCenter,
                 end: Alignment.bottomCenter,
                 colors: [AppColors.deepSlate, AppColors.midnightBlue],
               ),
             ),
          ),
          Positioned(
             top: 100,
             right: -100,
             child: Container(
               width: 300,
               height: 300,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: AppColors.cyan.withOpacity(0.15),
               ),
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                 child: Container(color: Colors.transparent),
               ),
             ),
           ),

          // 2. Content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search, color: AppColors.slateGrey),
                        hintText: 'Search gyms by name or city...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: AppColors.slateGrey),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.volt))
                    : _gyms.isEmpty
                      ? const Center(child: Text('No gyms found', style: TextStyle(color: AppColors.slateGrey)))
                      : ListView.builder(
                          itemCount: _gyms.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final gym = _gyms[index];
                            return GestureDetector(
                              onTap: () => context.push('/gym-search/${gym.id}'),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: GlassContainer(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 80, height: 80,
                                          color: Colors.white10,
                                          child: const Icon(Icons.fitness_center, color: AppColors.lightSlate),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              gym.name,
                                              style: Theme.of(context).textTheme.titleLarge,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on, size: 14, color: AppColors.volt),
                                                const SizedBox(width: 4),
                                                Text(
                                                  gym.city,
                                                  style: const TextStyle(color: AppColors.slateGrey, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              children: gym.amenities.take(3).map((a) => _MiniTag(label: a)).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  const _MiniTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.lightSlate)),
    );
  }
}
