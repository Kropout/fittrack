import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/user_profile.dart';
import '../profile/profile_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _started = false;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _goal = TextEditingController(text: '8000');

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _height.dispose();
    _goal.dispose();
    super.dispose();
  }

  String? _range(String? v, double min, double max) {
    final n = double.tryParse((v ?? '').trim());
    if (n == null || n < min || n > max) {
      return 'Enter a value between ${min.toInt()} and ${max.toInt()}';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<ProfileProvider>().save(
      UserProfile(
        name: _name.text.trim(),
        weightKg: double.parse(_weight.text.trim()),
        heightCm: double.parse(_height.text.trim()),
        dailyStepGoal: int.parse(_goal.text.trim()),
      ),
    );
    // App switches to the main shell automatically once the profile exists.
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _started ? _buildForm() : _buildWelcome(),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Padding(
      key: const ValueKey('welcome'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FITTRACK', style: AppTextStyles.label),
          const Spacer(),
          Text(
            'Move with\nintent.',
            style: AppTextStyles.headline.copyWith(fontSize: 52),
          ),
          const SizedBox(height: 16),
          Text(
            'Track workouts, steps and streaks in one quiet, focused place.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 48),
          PrimaryButton(
            label: 'Get started',
            onPressed: () => setState(() => _started = true),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FITTRACK', style: AppTextStyles.label),
            const SizedBox(height: 12),
            Text("Let's set\nyou up.", style: AppTextStyles.headline),
            const SizedBox(height: 12),
            Text(
              'Your weight is used to estimate calories burned.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 32),
            AppTextField(
              label: 'Name',
              controller: _name,
              hint: 'Your name',
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Weight',
              controller: _weight,
              suffix: 'kg',
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => _range(v, 20, 300),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Height',
              controller: _height,
              suffix: 'cm',
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => _range(v, 100, 250),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Daily step goal',
              controller: _goal,
              suffix: 'steps',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => _range(v, 1000, 50000),
            ),
            const SizedBox(height: 36),
            PrimaryButton(label: 'Continue', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}