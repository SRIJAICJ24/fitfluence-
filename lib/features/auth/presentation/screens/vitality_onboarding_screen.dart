import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:async';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/onboarding_state.dart';
import '../../../gym/domain/models/gym_model.dart';
import '../../../gym/data/repositories/gym_repository_impl.dart';

class VitalityOnboardingScreen extends ConsumerStatefulWidget {
  const VitalityOnboardingScreen({super.key});

  @override
  ConsumerState<VitalityOnboardingScreen> createState() => _VitalityOnboardingScreenState();
}

class _VitalityOnboardingScreenState extends ConsumerState<VitalityOnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _next() {
    ref.read(onboardingControllerProvider.notifier).nextStep();
    _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void _back() {
    final step = ref.read(onboardingControllerProvider).currentStep;
    if (step == 0) {
      context.go('/auth');
    } else {
      ref.read(onboardingControllerProvider.notifier).prevStep();
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final totalSteps = 6; // 0 to 6 (7 screens)

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background (Deep Slate + Ambient Glows)
           Container(
             decoration: const BoxDecoration(
               gradient: LinearGradient(
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
                 colors: [AppColors.deepSlate, AppColors.midnightBlue],
               ),
             ),
           ),
           // Ambient Glow Top Left
           Positioned(
             top: -100,
             left: -100,
             child: Container(
               width: 300,
               height: 300,
               decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.indigo),
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                 child: Container(color: Colors.transparent),
               ),
             ),
           ),
           // Ambient Glow Bottom Right
           Positioned(
             bottom: -100,
             right: -100,
             child: Container(
               width: 300,
               height: 300,
               decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.teal),
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                 child: Container(color: Colors.transparent),
               ),
             ),
           ),

           SafeArea(
             child: Column(
               children: [
                 // 2. Header (Back Button & Progress)
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   child: Row(
                     children: [
                       IconButton(
                         icon: const Icon(Icons.arrow_back, color: AppColors.slateGrey),
                         onPressed: _back,
                       ),
                       Expanded(
                         child: Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16),
                           child: ClipRRect(
                             borderRadius: BorderRadius.circular(4),
                             child: LinearProgressIndicator(
                               value: (state.currentStep + 1) / 7,
                               backgroundColor: Colors.white10,
                               valueColor: const AlwaysStoppedAnimation<Color>(AppColors.volt),
                               minHeight: 4,
                             ),
                           ),
                         ),
                       ),
                       Text('Step ${state.currentStep + 1}/7', style: const TextStyle(color: AppColors.slateGrey, fontSize: 12)),
                     ],
                   ),
                 ),

                 // 3. The Wizard Pages
                 Expanded(
                   child: PageView(
                     controller: _pageController,
                     physics: const NeverScrollableScrollPhysics(), // Managed by controller
                     children: [
                       _StepLanding(onNext: _next),
                       _StepCredentials(onNext: _next),
                       _StepIdentity(onNext: _next),
                       _StepContext(onNext: _next),
                       _StepAmbition(onNext: _next),
                       _StepSafety(onNext: _next),
                       _StepPolish(onSubmit: () async {
                         try {
                           await ref.read(onboardingControllerProvider.notifier).submit();
                           if (context.mounted) context.go('/home');
                         } catch (e) {
                           if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                         }
                       }),
                     ],
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

// --- STEP 1: Landing (The Portal) ---
class _StepLanding extends StatelessWidget {
  final VoidCallback onNext;
  const _StepLanding({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
       padding: const EdgeInsets.all(32),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Transform.rotate(
             angle: -0.785, // -45 deg
             child: Container(
               decoration: const BoxDecoration(
                 boxShadow: [BoxShadow(color: AppColors.volt, blurRadius: 40, spreadRadius: -10)]
               ),
               child: const Icon(Icons.fitness_center, size: 80, color: AppColors.volt),
             ),
           ),
           const SizedBox(height: 48),
           Text('Join the Movement', style: Theme.of(context).textTheme.displayLarge),
           const SizedBox(height: 16),
           const Text(
             'Create your athlete identity and find your squad.',
             textAlign: TextAlign.center,
             style: TextStyle(color: AppColors.slateGrey, fontSize: 18),
           ),
           const Spacer(),
           ElevatedButton(
             onPressed: onNext,
             style: ElevatedButton.styleFrom(
               backgroundColor: AppColors.volt,
               foregroundColor: AppColors.deepSlate,
               minimumSize: const Size(double.infinity, 56),
             ),
             child: const Text('Start Setup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
           ),
           const SizedBox(height: 32),
         ],
       ),
    );
  }
}

// --- STEP 2: Credentials ---
class _StepCredentials extends ConsumerWidget {
  final VoidCallback onNext;
  const _StepCredentials({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Credentials', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          const Text('Secure your account.', style: TextStyle(color: AppColors.slateGrey)),
          const SizedBox(height: 32),
          
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => ref.read(onboardingControllerProvider.notifier).updateField(email: val),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.slateGrey),
                    border: InputBorder.none,
                    labelStyle: TextStyle(color: AppColors.slateGrey),
                  ),
                ),
                const Divider(color: Colors.white10),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (val) => ref.read(onboardingControllerProvider.notifier).updateField(password: val),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.slateGrey),
                    border: InputBorder.none,
                    labelStyle: TextStyle(color: AppColors.slateGrey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const SizedBox(height: 32),
          ElevatedButton(
             onPressed: (ref.watch(onboardingControllerProvider).email.contains('@') && ref.watch(onboardingControllerProvider).password.length >= 6) 
               ? onNext 
               : null,
             style: ElevatedButton.styleFrom(backgroundColor: AppColors.volt, foregroundColor: AppColors.deepSlate, minimumSize: const Size(double.infinity, 50)),
             child: const Text('Next Step'),
           ),
           if (ref.watch(onboardingControllerProvider).password.isNotEmpty && ref.watch(onboardingControllerProvider).password.length < 6)
             const Padding(
               padding: EdgeInsets.only(top: 8.0),
               child: Text('Password must be at least 6 characters', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
             ),
        ],
      ),
    );
  }
}

// --- STEP 3: Identity ---
class _StepIdentity extends ConsumerWidget {
  final VoidCallback onNext;
  const _StepIdentity({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identity', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 32),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                   onChanged: (val) => ref.read(onboardingControllerProvider.notifier).updateField(name: val),
                   style: const TextStyle(color: Colors.white),
                   decoration: const InputDecoration(
                     labelText: 'Full Name',
                     border: InputBorder.none,
                     labelStyle: TextStyle(color: AppColors.slateGrey),
                   ),
                ),
                const Divider(color: Colors.white10),
                TextField(
                   onChanged: (val) => ref.read(onboardingControllerProvider.notifier).updateField(age: val),
                   keyboardType: TextInputType.number,
                   style: const TextStyle(color: Colors.white),
                   decoration: const InputDecoration(
                     labelText: 'Age',
                     border: InputBorder.none,
                     labelStyle: TextStyle(color: AppColors.slateGrey),
                   ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Gender', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildGenderCard('Male', state.gender == 'Male', ref),
              const SizedBox(width: 12),
              _buildGenderCard('Female', state.gender == 'Female', ref),
              const SizedBox(width: 12),
              _buildGenderCard('Other', state.gender == 'Other', ref),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
             onPressed: onNext,
             style: ElevatedButton.styleFrom(backgroundColor: AppColors.volt, foregroundColor: AppColors.deepSlate, minimumSize: const Size(double.infinity, 50)),
             child: const Text('Next Step'),
           ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(String label, bool isSelected, WidgetRef ref) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(onboardingControllerProvider.notifier).updateField(gender: label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.volt.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            border: Border.all(color: isSelected ? AppColors.volt : Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? AppColors.volt : Colors.white, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}

// --- STEP 4: Context (Gym) ---
class _StepContext extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const _StepContext({required this.onNext});

  @override
  ConsumerState<_StepContext> createState() => _StepContextState();
}

class _StepContextState extends ConsumerState<_StepContext> {
  final TextEditingController _searchController = TextEditingController();
  List<GymModel> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() => _searchResults = []);
        return;
      }

      setState(() => _isLoading = true);
      try {
        final results = await ref.read(gymRepositoryProvider).searchGyms(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }); 
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Context', style: Theme.of(context).textTheme.headlineLarge),
           const SizedBox(height: 8),
           const Text('Where do you train?', style: TextStyle(color: AppColors.slateGrey)),
           const SizedBox(height: 24),
           
           GlassContainer(
             padding: const EdgeInsets.symmetric(horizontal: 16),
             child: TextField(
               controller: _searchController,
               onChanged: _onSearchChanged,
               decoration: const InputDecoration(
                 icon: Icon(Icons.search, color: AppColors.slateGrey),
                 hintText: 'Search for your gym...',
                 border: InputBorder.none,
                 hintStyle: TextStyle(color: AppColors.slateGrey),
               ),
               style: const TextStyle(color: Colors.white),
             ),
           ),
           
           const SizedBox(height: 16),
           
           Expanded(
             child: _isLoading 
               ? const Center(child: CircularProgressIndicator(color: AppColors.volt))
               : _searchResults.isEmpty && _searchController.text.isNotEmpty
                 ? const Center(child: Text('No gyms found', style: TextStyle(color: AppColors.slateGrey)))
                 : ListView.separated(
                     itemCount: _searchResults.length,
                     separatorBuilder: (_,__) => const SizedBox(height: 12),
                     itemBuilder: (context, index) {
                       final gym = _searchResults[index];
                       final isSelected = state.gymId == gym.id;
                       
                       return GestureDetector(
                         onTap: () => ref.read(onboardingControllerProvider.notifier).updateField(gymId: gym.id),
                         child: GlassContainer(
                           padding: const EdgeInsets.all(16),
                           borderRadius: 12,
                           backgroundColor: isSelected ? AppColors.volt.withOpacity(0.1) : null,
                           child: Row(
                             children: [
                               const Icon(Icons.fitness_center, color: AppColors.lightSlate), 
                               const SizedBox(width: 16),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(gym.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                     if (gym.city.isNotEmpty)
                                       Text(gym.city, style: const TextStyle(color: AppColors.slateGrey, fontSize: 12)),
                                   ],
                                 ),
                               ),
                               if (isSelected) const Icon(Icons.check_circle, color: AppColors.volt),
                             ],
                           ),
                         ),
                       );
                     },
                   ),
           ),
           
           ElevatedButton(
             onPressed: state.gymId != null ? widget.onNext : null,
             style: ElevatedButton.styleFrom(
               backgroundColor: AppColors.volt, 
               foregroundColor: AppColors.deepSlate, 
               minimumSize: const Size(double.infinity, 50)
             ),
             child: const Text('Next Step'),
           ),
        ],
      ),
    );
  }
}

// --- STEP 5: Ambition ---
class _StepAmbition extends ConsumerWidget {
  final VoidCallback onNext;
  const _StepAmbition({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final goals = ['Strength', 'Cardio', 'Flexibility', 'Weight Loss'];
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ambition', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: goals.map((goal) {
                final isSelected = state.goals.contains(goal);
                return GestureDetector(
                   onTap: () => ref.read(onboardingControllerProvider.notifier).toggleGoal(goal),
                   child: AnimatedContainer(
                     duration: const Duration(milliseconds: 200),
                     decoration: BoxDecoration(
                       color: isSelected ? AppColors.volt.withOpacity(0.2) : const Color(0xFF1E293B).withOpacity(0.4),
                       border: Border.all(color: isSelected ? AppColors.volt : Colors.white10),
                       borderRadius: BorderRadius.circular(24),
                     ),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.emoji_events, size: 32, color: isSelected ? AppColors.volt : Colors.white),
                         const SizedBox(height: 12),
                         Text(goal, style: TextStyle(color: isSelected ? AppColors.volt : Colors.white, fontWeight: FontWeight.bold)),
                       ],
                     ),
                   ),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
             onPressed: onNext,
             style: ElevatedButton.styleFrom(backgroundColor: AppColors.volt, foregroundColor: AppColors.deepSlate, minimumSize: const Size(double.infinity, 50)),
             child: const Text('Next Step'),
           ),
        ],
      ),
    );
  }
}

// --- STEP 6: Safety (Vibe) ---
class _StepSafety extends ConsumerWidget {
  final VoidCallback onNext;
  const _StepSafety({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Vibe Check', style: Theme.of(context).textTheme.headlineLarge),
           const SizedBox(height: 8),
           const Text('Set your boundaries.', style: TextStyle(color: AppColors.slateGrey)),
           const SizedBox(height: 32),
           _buildVibeCard('Very Open', Colors.green, state.vibe == 'Very Open', ref),
           const SizedBox(height: 16),
           _buildVibeCard('Moderate', Colors.yellow, state.vibe == 'Moderate', ref),
           const SizedBox(height: 16),
           _buildVibeCard('Private', Colors.red, state.vibe == 'Private', ref),
           
           const Spacer(),
          ElevatedButton(
             onPressed: onNext,
             style: ElevatedButton.styleFrom(backgroundColor: AppColors.volt, foregroundColor: AppColors.deepSlate, minimumSize: const Size(double.infinity, 50)),
             child: const Text('Next Step'),
           ),
        ],
      ),
    );
  }

  Widget _buildVibeCard(String label, Color color, bool isSelected, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(onboardingControllerProvider.notifier).updateField(vibe: label),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 8)]),
            ),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            if (isSelected) Icon(Icons.check, color: color),
          ],
        ),
      ),
    );
  }
}

// --- STEP 7: Polish ---
class _StepPolish extends ConsumerWidget {
  final VoidCallback onSubmit;
  const _StepPolish({required this.onSubmit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Container(
             width: 120, height: 120,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               border: Border.all(color: AppColors.volt, style: BorderStyle.none), // Dashed border placeholder
               color: Colors.white10,
             ),
             child: const Center(child: Icon(Icons.add_a_photo, size: 32, color: AppColors.lightSlate)),
          ),
          const SizedBox(height: 16),
          const Text('Upload Photo', style: TextStyle(color: AppColors.slateGrey)),
          const SizedBox(height: 32),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: TextField(
               onChanged: (val) => ref.read(onboardingControllerProvider.notifier).updateField(bio: val),
               maxLines: 4,
               style: const TextStyle(color: Colors.white),
               decoration: const InputDecoration(
                 hintText: 'Write a short bio...',
                 border: InputBorder.none,
                 hintStyle: TextStyle(color: AppColors.slateGrey),
               ),
            ),
          ),
          const SizedBox(height: 48),
          
          ElevatedButton(
             onPressed: state.isLoading ? null : onSubmit,
             style: ElevatedButton.styleFrom(
               backgroundColor: AppColors.volt,
               foregroundColor: AppColors.deepSlate,
               minimumSize: const Size(double.infinity, 56),
               elevation: 10,
               shadowColor: AppColors.volt.withOpacity(0.5),
             ),
             child: state.isLoading 
               ? const CircularProgressIndicator() 
               : const Text('Complete Setup 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
           ),
        ],
      ),
    );
  }
}
