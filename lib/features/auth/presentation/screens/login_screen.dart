import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password')));
      return;
    }

    await ref.read(authControllerProvider.notifier).signIn(email: email, password: password);
    
    // Check for errors
    final state = ref.read(authControllerProvider);
    if (state.hasError && mounted) {
       final errorMsg = state.error.toString();
       final cleanMsg = errorMsg.contains('Email not confirmed') 
           ? 'Please confirm your email address to login.\n\n(Or disable "Confirm Email" in your Supabase Dashboard)'
           : errorMsg.replaceAll(RegExp(r'AuthApiException\(message: |,\s*statusCode.*'), '');

       showDialog(
         context: context,
         builder: (context) => AlertDialog(
           title: const Text('Login Failed'),
           content: Text(cleanMsg),
           actions: [
             TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
           ],
         ),
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.deepSlate, AppColors.midnightBlue],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center, size: 64, color: AppColors.volt),
                const SizedBox(height: 24),
                Text(
                  'FitFluence',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find your flow.',
                  style: TextStyle(color: AppColors.slateGrey, fontSize: 18),
                ),
                const SizedBox(height: 48),
                
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.slateGrey),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          labelStyle: TextStyle(color: AppColors.slateGrey),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline, color: AppColors.slateGrey),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none, 
                          enabledBorder: InputBorder.none,
                          labelStyle: TextStyle(color: AppColors.slateGrey),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.volt,
                            foregroundColor: AppColors.deepSlate,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: authState.isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ... (Sign up button remains)
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.push('/auth/onboarding'),
                  child: const Text(
                    'New here? Create Account',
                    style: TextStyle(color: AppColors.cyan),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
