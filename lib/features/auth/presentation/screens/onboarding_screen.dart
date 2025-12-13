import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';
import '../../../../config/theme.dart';
import '../../../../config/constants.dart';

import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Form State
  String? _selectedGender;
  final List<String> _selectedGoals = [];
  String? _selectedFitnessLevel;
  String? _selectedComfort;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.deepSlate, AppColors.midnightBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildCurrentStep(),
                ),
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: LinearProgressIndicator(
        value: (_currentStep + 1) / 4,
        backgroundColor: AppColors.darkContainer,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.volt),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildGoalsStep();
      case 2:
        return _buildFitnessLevelStep();
      case 3:
        return _buildMentalHealthStep();
      default:
        return Container();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Basic Info', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other'].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsStep() {
    final goals = ['Strength', 'Hypertrophy', 'Endurance', 'Weight Loss', 'Flexibility'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fitness Goals', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: goals.map((goal) {
            final isSelected = _selectedGoals.contains(goal);
            return FilterChip(
              label: Text(goal),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGoals.add(goal);
                  } else {
                    _selectedGoals.remove(goal);
                  }
                });
              },
              backgroundColor: AppColors.darkContainer,
              selectedColor: AppColors.volt.withOpacity(0.2),
              checkmarkColor: AppColors.volt,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.volt : AppColors.lightSlate,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFitnessLevelStep() {
    final levels = ['Beginner', 'Intermediate', 'Advanced', 'Elite'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fitness Level', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 16),
        Column(
          children: levels.map((level) {
            return RadioListTile<String>(
              title: Text(level),
              value: level,
              groupValue: _selectedFitnessLevel,
              onChanged: (val) => setState(() => _selectedFitnessLevel = val),
              activeColor: AppColors.volt,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMentalHealthStep() {
    final comforts = ['Very Open', 'Moderate', 'Private'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Social Comfort', style: Theme.of(context).textTheme.displayMedium),
        const Text(
          'How open are you to interacting with new people?',
          style: TextStyle(color: AppColors.slateGrey),
        ),
        const SizedBox(height: 16),
        Column(
          children: comforts.map((comfort) {
            return RadioListTile<String>(
              title: Text(comfort),
              value: comfort,
              groupValue: _selectedComfort,
              onChanged: (val) => setState(() => _selectedComfort = val),
              activeColor: AppColors.volt,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: () => setState(() => _currentStep--),
              child: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: () {
              if (_currentStep < 3) {
                setState(() => _currentStep++);
              } else {
                // Submit Form
                context.go('/home');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.volt,
              foregroundColor: AppColors.deepSlate,
            ),
            child: Text(_currentStep == 3 ? 'Finish' : 'Next'),
          ),
        ],
      ),
    );
  }
}
