import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../steps/steps_provider.dart';
import '../workouts/workout_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _metric = 0; // 0 = steps, 1 = calories

  @override
  Widget build(BuildContext context) {
    final workouts = context.watch<WorkoutProvider>();
    final steps = context.watch<StepsProvider>();
    final fmt = NumberFormat.decimalPattern();

    final now = DateTime.now();
    final days = List.generate(
      7,
          (i) => DateTime(now.year, now.month, now.day - (6 - i)),
    );
    final values = days
        .map((d) => _metric == 0 ? steps.stepsFor(d) : workouts.caloriesOn(d))
        .toList();

    final total = values.fold<int>(0, (a, b) => a + b);
    final maxValue = values.reduce(math.max);
    final maxY = math.max(maxValue * 1.2, _metric == 0 ? 1000.0 : 100.0);
    final sessions = days.fold<int>(0, (s, d) => s + workouts.countOn(d));
    final minutes = days.fold<int>(0, (s, d) => s + workouts.minutesOn(d));

    final dailyAverage = fmt.format((total / 7).round());
    final emptyMessage = _metric == 0
        ? 'Walk with your phone to see steps here.'
        : 'Log a workout to see calories here.';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FITTRACK', style: AppTextStyles.label),
          const SizedBox(height: 12),
          Text('Stats', style: AppTextStyles.headline),
          const SizedBox(height: 24),
          Row(
            children: [
              _toggle('Steps', 0),
              const SizedBox(width: 10),
              _toggle('Calories', 1),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'LAST 7 DAYS  ·  ${_metric == 0 ? 'STEPS' : 'KCAL'}',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              fmt.format(total),
              style: AppTextStyles.hero.copyWith(fontSize: 56),
            ),
          ),
          const SizedBox(height: 8),
          Text('Daily average $dailyAverage', style: AppTextStyles.body),
          if (total == 0) ...[
            const SizedBox(height: 8),
            Text(emptyMessage, style: AppTextStyles.body),
          ],
          const SizedBox(height: 32),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final isToday = i == days.length - 1;
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            DateFormat('E').format(days[i]).toUpperCase(),
                            style: AppTextStyles.label.copyWith(
                              fontSize: 10,
                              color: isToday
                                  ? AppColors.goldLight
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < days.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i].toDouble(),
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(7),
                          ),
                          color: i == days.length - 1
                              ? null
                              : const Color(0xFF3A3F66),
                          gradient: i == days.length - 1
                              ? const LinearGradient(
                            colors: [
                              AppColors.goldLight,
                              AppColors.goldDark,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                              : null,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _summaryRow('Workouts this week', '$sessions'),
          _summaryRow('Active minutes', fmt.format(minutes)),
        ],
      ),
    );
  }

  Widget _toggle(String label, int index) {
    final selected = _metric == index;
    return GestureDetector(
      onTap: () => setState(() => _metric = index),
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
          label,
          style: AppTextStyles.bodyStrong.copyWith(
            color: selected ? AppColors.goldLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}