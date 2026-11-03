import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../profile/profile_provider.dart';
import '../protein/protein_card.dart';
import '../protein/protein_provider.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final protein = context.watch<ProteinProvider>();
    final profile = context.watch<ProfileProvider>().profile;

    final goal = protein.goalFor(profile?.weightKg ?? 70);
    final now = DateTime.now();
    final days = List.generate(
      7,
          (i) => DateTime(now.year, now.month, now.day - (6 - i)),
    );
    final values = days.map((d) => protein.totalFor(d)).toList();

    final maxValue = values.reduce(math.max);
    final maxY = math.max(math.max(maxValue, goal) * 1.2, 50.0);
    final goalDays = goal > 0 ? values.where((v) => v >= goal).length : 0;
    final weekTotal = values.fold<int>(0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FITTRACK', style: AppTextStyles.label),
          const SizedBox(height: 12),
          Text('Diet', style: AppTextStyles.headline),
          const SizedBox(height: 28),
          const ProteinCard(),
          const SizedBox(height: 36),
          Text('LAST 7 DAYS  ·  PROTEIN', style: AppTextStyles.label),
          const SizedBox(height: 10),
          Text(
            '$weekTotal g',
            style: AppTextStyles.hero.copyWith(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            weekTotal == 0
                ? 'Log protein above to see your week here.'
                : 'Gold bars reached your daily goal.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(show: false),
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
                          color: (goal > 0 && values[i] >= goal)
                              ? AppColors.goldLight
                              : const Color(0xFF3A3F66),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _row('Days goal reached', '$goalDays / 7'),
          _row('Best day', '$maxValue g'),
          _row('7-day average', '${protein.weekAverage} g'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
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