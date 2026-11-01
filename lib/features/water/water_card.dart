import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'water_provider.dart';

class WaterCard extends StatelessWidget {
  const WaterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();
    final progress = (water.today / WaterProvider.goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF14172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WATER', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Text(
                      '${water.today} / ${WaterProvider.goal} glasses',
                      style: AppTextStyles.title,
                    ),
                  ],
                ),
              ),
              _roundButton(Icons.remove, () => water.remove()),
              const SizedBox(width: 10),
              _roundButton(Icons.add, () => water.add(), highlight: true),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 4, color: const Color(0x1FFFFFFF)),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 4,
                    decoration:
                    const BoxDecoration(gradient: AppColors.goldGradient),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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