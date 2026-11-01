import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/workout.dart';
import 'add_workout_screen.dart';
import 'workout_provider.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  // Flattens workouts into [DateTime header, Workout, Workout, DateTime header, ...]
  List<Object> _group(List<Workout> workouts) {
    final out = <Object>[];
    DateTime? last;
    for (final w in workouts) {
      final day = DateTime(w.date.year, w.date.month, w.date.day);
      if (last == null || day != last) {
        out.add(day);
        last = day;
      }
      out.add(w);
    }
    return out;
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    return DateFormat('EEE, d MMM').format(d).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final workouts = context.watch<WorkoutProvider>().workouts;
    final items = _group(workouts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FITTRACK', style: AppTextStyles.label),
                    const SizedBox(height: 12),
                    Text('Workouts', style: AppTextStyles.headline),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => const AddWorkoutScreen(),
                    transitionsBuilder: (_, anim, __, child) => FadeTransition(
                      opacity: CurvedAnimation(
                          parent: anim, curve: Curves.easeOut),
                      child: child,
                    ),
                  ),
                ),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x66E8C48A)),
                  ),
                  child: const Icon(Icons.add,
                      color: AppColors.goldLight, size: 24),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: workouts.isEmpty
              ? Center(
            child: Text(
              'No workouts yet.\nTap + to log your first session.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              if (item is DateTime) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 4),
                  child: Text(_dayLabel(item), style: AppTextStyles.label),
                );
              }
              return _WorkoutRow(workout: item as Workout);
            },
          ),
        ),
      ],
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  final Workout workout;
  const _WorkoutRow({required this.workout});

  @override
  Widget build(BuildContext context) {
    final subtitle = workout.notes.isEmpty
        ? '${workout.durationMinutes} min'
        : '${workout.durationMinutes} min  ·  ${workout.notes}';

    return Dismissible(
      key: ValueKey(workout.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFF2A1520),
        child: const Icon(Icons.delete_outline, color: Color(0xFFE57373)),
      ),
      onDismissed: (_) =>
          context.read<WorkoutProvider>().remove(workout.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.type.label, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${workout.calories}',
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
    );
  }
}