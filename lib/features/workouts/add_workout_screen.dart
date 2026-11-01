import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/calorie_calculator.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/workout.dart';
import '../profile/profile_provider.dart';
import 'workout_provider.dart';
import 'workout_timer.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  WorkoutType _type = WorkoutType.run;
  final _duration = TextEditingController();
  final _notes = TextEditingController();

  int get _minutes => int.tryParse(_duration.text.trim()) ?? 0;
  double get _weight =>
      context.read<ProfileProvider>().profile?.weightKg ?? 70;

  @override
  void dispose() {
    _duration.dispose();
    _notes.dispose();
    super.dispose();
  }

  int get _estimate => CalorieCalculator.estimate(
    type: _type,
    durationMinutes: _minutes,
    weightKg: _weight,
  );

  Future<void> _save() async {
    final provider = context.read<WorkoutProvider>();
    final navigator = Navigator.of(context);
    await provider.add(
      Workout(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: _type,
        durationMinutes: _minutes,
        calories: _estimate,
        notes: _notes.text.trim(),
        date: DateTime.now(),
      ),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new,
                      size: 20, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NEW SESSION', style: AppTextStyles.label),
                        const SizedBox(height: 12),
                        Text('Log workout', style: AppTextStyles.headline),
                        const SizedBox(height: 28),
                        Text('TYPE', style: AppTextStyles.label),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final t in WorkoutType.values) _typeChip(t),
                          ],
                        ),
                        const SizedBox(height: 32),
                        WorkoutTimer(onUse: (m) => setState(() => _duration.text = '$m')),
                        const SizedBox(height: 28),
                        Text('DURATION', style: AppTextStyles.label),
                        TextField(
                          controller: _duration,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          onChanged: (_) => setState(() {}),
                          cursorColor: AppColors.goldLight,
                          style: AppTextStyles.hero,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: AppTextStyles.hero
                                .copyWith(color: AppColors.textMuted),
                            suffixText: 'min',
                            suffixStyle: AppTextStyles.title
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('ESTIMATED BURN', style: AppTextStyles.label),
                        const SizedBox(height: 6),
                        Text(
                          '$_estimate kcal',
                          style: AppTextStyles.title
                              .copyWith(color: AppColors.goldLight),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          label: 'Notes (optional)',
                          controller: _notes,
                          maxLines: 3,
                          hint: 'How did it feel?',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Save workout',
                  onPressed: _minutes > 0 ? _save : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeChip(WorkoutType t) {
    final selected = t == _type;
    return GestureDetector(
      onTap: () => setState(() => _type = t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.goldLight : AppColors.hairline,
          ),
          color: selected ? const Color(0x1AE8C48A) : const Color(0xFF14172A),
        ),
        child: Text(
          t.label,
          style: AppTextStyles.bodyStrong.copyWith(
            color: selected ? AppColors.goldLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}