import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/stat_tile.dart';
import '../../data/models/workout.dart';
import '../profile/profile_provider.dart';
import '../steps/steps_provider.dart';
import '../water/water_card.dart';
import '../workouts/workout_provider.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onOpenWorkouts;
  const DashboardScreen({super.key, required this.onOpenWorkouts});

  String _greeting(String name) {
    final h = DateTime.now().hour;
    final part = h < 12 ? 'morning' : (h < 17 ? 'afternoon' : 'evening');
    return 'Good $part, $name';
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final workouts = context.watch<WorkoutProvider>();
    final steps = context.watch<StepsProvider>();

    final fmt = NumberFormat.decimalPattern();
    final goal = profile?.dailyStepGoal ?? 8000;
    final today = steps.today;
    final progress = goal == 0 ? 0.0 : today / goal;
    final latest = workouts.latest;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FITTRACK', style: AppTextStyles.label),
          const SizedBox(height: 12),
          Text(_greeting(profile?.name ?? ''), style: AppTextStyles.title),
          const SizedBox(height: 32),
          Center(
            child: ProgressRing(
              progress: progress,
              size: 280,
              strokeWidth: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('STEPS TODAY', style: AppTextStyles.label),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(fmt.format(today), style: AppTextStyles.hero),
                    ),
                    const SizedBox(height: 10),
                    Text('of ${fmt.format(goal)}', style: AppTextStyles.body),
                  ],
                ),
              ),
            ),
          ),
          if (steps.permissionDenied || steps.sensorError) ...[
            const SizedBox(height: 20),
            _StepNotice(
              message: steps.permissionDenied
                  ? 'Step tracking needs the Physical activity permission. '
                  'If no prompt appears, enable it in Settings → Apps → '
                  'fittrack → Permissions.'
                  : "This device doesn't report steps (emulators don't). "
                  'Try a physical phone.',
              showAllow: steps.permissionDenied,
              onAllow: () => context.read<StepsProvider>().startTracking(),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Calories',
                  value: fmt.format(workouts.todayCalories),
                  unit: 'kcal',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'Active',
                  value: fmt.format(workouts.todayMinutes),
                  unit: 'min',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'Streak',
                  value: '${workouts.streak}',
                  unit: workouts.streak == 1 ? 'day' : 'days',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const WaterCard(),
          const SizedBox(height: 32),
          Text('LATEST WORKOUT', style: AppTextStyles.label),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onOpenWorkouts,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF14172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.hairline),
              ),
              child: latest == null
                  ? Text(
                'No workouts yet. Tap here to log your first session.',
                style: AppTextStyles.body,
              )
                  : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(latest.type.label,
                            style: AppTextStyles.title),
                        const SizedBox(height: 4),
                        Text(
                          '${latest.durationMinutes} min  ·  '
                              '${DateFormat('d MMM').format(latest.date)}',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${latest.calories}',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.goldLight,
                        ),
                      ),
                      Text('KCAL', style: AppTextStyles.label),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepNotice extends StatelessWidget {
  final String message;
  final bool showAllow;
  final VoidCallback onAllow;
  const _StepNotice({
    required this.message,
    required this.showAllow,
    required this.onAllow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x66E8C48A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppTextStyles.body),
          if (showAllow) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onAllow,
              child: Text(
                'Allow',
                style: AppTextStyles.bodyStrong
                    .copyWith(color: AppColors.goldLight),
              ),
            ),
          ],
        ],
      ),
    );
  }
}