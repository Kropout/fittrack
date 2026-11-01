import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../workouts/workout_provider.dart';

class _Badge {
  final IconData icon;
  final String title;
  final String hint;
  final bool earned;
  const _Badge(this.icon, this.title, this.hint, this.earned);
}

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WorkoutProvider>();
    final badges = [
      _Badge(Icons.flag_outlined, 'First session', 'Log a workout',
          w.workouts.isNotEmpty),
      _Badge(Icons.local_fire_department_outlined, 'On a roll',
          '3-day streak', w.longestStreak >= 3),
      _Badge(Icons.bolt_outlined, 'Week strong', '7-day streak',
          w.longestStreak >= 7),
      _Badge(Icons.fitness_center_outlined, 'Ten sessions',
          'Log 10 workouts', w.workouts.length >= 10),
      _Badge(Icons.timer_outlined, 'Century', '100 active minutes',
          w.totalMinutes >= 100),
      _Badge(Icons.whatshot_outlined, 'Burner', 'Burn 1,000 kcal',
          w.totalCalories >= 1000),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final width = (c.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final b in badges)
              SizedBox(width: width, child: _tile(b)),
          ],
        );
      },
    );
  }

  Widget _tile(_Badge b) {
    final color = b.earned ? AppColors.goldLight : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: b.earned ? const Color(0x66E8C48A) : AppColors.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(b.icon, color: color, size: 26),
          const SizedBox(height: 14),
          Text(
            b.title,
            style: AppTextStyles.bodyStrong.copyWith(
              color: b.earned
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            b.earned ? 'Earned' : b.hint,
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: b.earned ? AppColors.goldLight : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}