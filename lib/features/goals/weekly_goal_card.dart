import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../workouts/workout_provider.dart';
import 'goal_provider.dart';

class WeeklyGoalCard extends StatelessWidget {
  const WeeklyGoalCard({super.key});

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final workouts = context.watch<WorkoutProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final goal = goalProvider.weeklyWorkouts;

    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final days = List.generate(
      7,
          (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
    final done = days.fold<int>(0, (s, d) => s + workouts.countOn(d));
    final reached = done >= goal;
    final todayIndex = now.weekday - 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF14172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WEEKLY GOAL', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Text('$done / $goal sessions', style: AppTextStyles.title),
                    if (reached) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Goal reached this week',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.goldLight),
                      ),
                    ],
                  ],
                ),
              ),
              _roundButton(
                Icons.remove,
                    () => goalProvider.setWeeklyWorkouts(goal - 1),
              ),
              const SizedBox(width: 10),
              _roundButton(
                Icons.add,
                    () => goalProvider.setWeeklyWorkouts(goal + 1),
                highlight: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                _dayDot(
                  _letters[i],
                  trained: workouts.countOn(days[i]) > 0,
                  isToday: i == todayIndex,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayDot(String letter,
      {required bool trained, required bool isToday}) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: trained ? AppColors.goldGradient : null,
            color: trained ? null : const Color(0x14FFFFFF),
            border: isToday ? Border.all(color: AppColors.goldLight) : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          letter,
          style: AppTextStyles.label.copyWith(
            fontSize: 10,
            color: isToday ? AppColors.goldLight : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap,
      {bool highlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: highlight ? const Color(0x66E8C48A) : AppColors.hairline,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: highlight ? AppColors.goldLight : AppColors.textSecondary,
        ),
      ),
    );
  }
}