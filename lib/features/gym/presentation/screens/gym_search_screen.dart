import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';

class GymSearchScreen extends StatefulWidget {
  const GymSearchScreen({super.key});

  @override
  State<GymSearchScreen> createState() => _GymSearchScreenState();
}

class _GymSearchScreenState extends State<GymSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

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
                  child: ListView.builder(
                    itemCount: 5,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => context.push('/gym-search/${index + 1}'),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80&w=200',  
                                    width: 80, height: 80, fit: BoxFit.cover
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Gold\'s Gym ${index + 1}',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      const Row(
                                        children: [
                                          Icon(Icons.location_on, size: 14, color: AppColors.volt),
                                          SizedBox(width: 4),
                                          Text(
                                            'Indiranagar • 0.8 km',
                                            style: TextStyle(color: AppColors.slateGrey, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Wrap(
                                        spacing: 8,
                                        children: [
                                          _MiniTag(label: 'Cardio'),
                                          _MiniTag(label: 'Sauna'),
                                        ],
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
