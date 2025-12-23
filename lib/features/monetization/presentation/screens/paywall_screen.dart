import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/presentation/widgets/glass_container.dart';
import '../../../shared/presentation/widgets/primary_button.dart'; // Make sure this exists or use standard button
import '../../data/repositories/subscription_repository.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      await ref.read(subscriptionRepositoryProvider).upgradeToPro();
      
      if (mounted) {
        context.pop(); // Close paywall
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to Pro! 🌟'),
            backgroundColor: Colors.amber,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Or use a gradient background
      body: Stack(
        children: [
          // Background Elements (Optional: animated blobs)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withOpacity(0.2),
                blurRadius: 100,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header (Close Button)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Icon / Logo
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.amber.shade300, Colors.orange.shade700],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(duration: 2000.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),

                        const SizedBox(height: 30),

                        Text(
                          'Unlock FitFluence Pro',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        Text(
                          'Elevate your fitness journey with exclusive tools and insights.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Pricing Card
                        GlassContainer(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildFeatureItem('Unlimited Swipes'),
                              _buildFeatureItem('See Who Liked You'),
                              _buildFeatureItem('Pro Analytics Dashboard'),
                              _buildFeatureItem('Exclusive Workouts & Diets'),
                              _buildFeatureItem('Verified Badge'),
                              
                              const Divider(color: Colors.white24, height: 40),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '\$9.99',
                                    style: GoogleFonts.outfit(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '/mo',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms).fadeIn(),

                        const SizedBox(height: 40),

                        // CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handlePurchase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : Text(
                                    'Start 7-Day Free Trial',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ).animate().shimmer(delay: 1000.ms, duration: 2000.ms),

                        const SizedBox(height: 20),

                        Text(
                          'Cancel anytime. Terms & Conditions apply.',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.green, // Or amber
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
