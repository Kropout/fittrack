import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/bmi.dart';
import '../../data/models/user_profile.dart';
import '../profile/profile_provider.dart';
import 'weight_provider.dart';

class WeightCard extends StatelessWidget {
  const WeightCard({super.key});

  Future<void> _log(BuildContext context) async {
    final weightProvider = context.read<WeightProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final current = profileProvider.profile;
    if (current == null) return;

    final kg = await showDialog<double>(
      context: context,
      builder: (_) => _WeightDialog(initial: current.weightKg),
    );
    if (kg == null) return;

    await weightProvider.log(kg);
    // Keep the profile in sync so calorie estimates use the latest weight.
    await profileProvider.save(
      UserProfile(
        name: current.name,
        weightKg: kg,
        heightCm: current.heightCm,
        dailyStepGoal: current.dailyStepGoal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final entries = context.watch<WeightProvider>().entries;
    if (profile == null) return const SizedBox.shrink();

    final bmi = Bmi.value(profile.weightKg, profile.heightCm);
    final recent =
    entries.length > 30 ? entries.sublist(entries.length - 30) : entries;

    String? change;
    if (entries.length >= 2) {
      final d = entries.last.kg - entries.first.kg;
      final sign = d > 0 ? '+' : (d < 0 ? '-' : '');
      change = '$sign${d.abs().toStringAsFixed(1)} kg since first entry';
    }

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
                    Text('WEIGHT', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Text(
                      '${profile.weightKg.toStringAsFixed(1)} kg',
                      style: AppTextStyles.headline.copyWith(fontSize: 34),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _log(context),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.goldLight),
                  ),
                  child: Text(
                    'Log weight',
                    style: AppTextStyles.bodyStrong
                        .copyWith(color: AppColors.goldLight),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'BMI ${bmi.toStringAsFixed(1)}',
                style: AppTextStyles.bodyStrong,
              ),
              const SizedBox(width: 10),
              Text(Bmi.category(bmi), style: AppTextStyles.body),
            ],
          ),
          if (change != null) ...[
            const SizedBox(height: 6),
            Text(change, style: AppTextStyles.body),
          ],
          const SizedBox(height: 20),
          if (recent.length >= 2)
            SizedBox(height: 120, child: _chart(recent))
          else
            Text(
              'Log another weigh-in to see your trend.',
              style: AppTextStyles.body,
            ),
          const SizedBox(height: 14),
          Text(
            'BMI is a rough indicator and does not account for muscle mass.',
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chart(List<WeightEntry> recent) {
    final spots = [
      for (var i = 0; i < recent.length; i++)
        FlSpot(i.toDouble(), recent[i].kg),
    ];
    final minKg = recent.map((e) => e.kg).reduce(math.min);
    final maxKg = recent.map((e) => e.kg).reduce(math.max);

    return LineChart(
      LineChartData(
        minY: minKg - 1,
        maxY: maxKg + 1,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            barWidth: 3,
            gradient: AppColors.goldGradient,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: const LinearGradient(
                colors: [Color(0x33E8C48A), Color(0x00E8C48A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightDialog extends StatefulWidget {
  final double initial;
  const _WeightDialog({required this.initial});

  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  late final TextEditingController _c =
  TextEditingController(text: widget.initial.toStringAsFixed(1));
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    final v = double.tryParse(_c.text.trim());
    if (v == null || v < 20 || v > 300) {
      setState(() => _error = 'Enter a value between 20 and 300');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF14172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.hairline),
      ),
      title: Text('Log weight (kg)', style: AppTextStyles.title),
      content: TextField(
        controller: _c,
        autofocus: true,
        cursorColor: AppColors.goldLight,
        style: AppTextStyles.bodyStrong,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          errorText: _error,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.hairline),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.goldLight),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTextStyles.body),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            'Save',
            style:
            AppTextStyles.bodyStrong.copyWith(color: AppColors.goldLight),
          ),
        ),
      ],
    );
  }
}