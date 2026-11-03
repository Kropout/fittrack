import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Tweak these to taste:
  //   _fill       -> 0x00000000 makes the pill fully transparent
  //   _blur       -> 0 turns the backdrop blur off
  //   _showLabels -> false shows icons only
  static const _fill = Color(0x5914172A);
  static const _blur = 10.0;
  static const _radius = 32.5;
  static const _showLabels = false;
  static const _pillWidth = 80.0;

  // (outlined icon, filled icon, label)
  static const _items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.fitness_center_outlined, Icons.fitness_center, 'Workouts'),
    (Icons.insights_outlined, Icons.insights, 'Stats'),
    (Icons.restaurant_outlined, Icons.restaurant, 'Diet'),
  ];

  Widget _item(int i) {
    final active = i == currentIndex;
    final item = _items[i];
    final color = active ? AppColors.goldLight : AppColors.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(i);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? item.$2 : item.$1, size: 30, color: color),
          if (_showLabels) ...[
            const SizedBox(height: 4),
            Text(
              item.$3,
              style: AppTextStyles.body.copyWith(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      height: 68,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColors.hairline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / _items.length;
          return Stack(
            children: [
              // Highlight pill that slides to the active tab.
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: currentIndex * itemWidth + (itemWidth - _pillWidth) / 2,
                top: 0,
                bottom: 0,
                width: _pillWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x26E8C48A),
                    borderRadius: BorderRadius.circular(_radius - 6),
                    border: Border.all(color: const Color(0x40E8C48A)),
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      Expanded(child: _item(i)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: _blur > 0
          ? BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
        child: bar,
      )
          : bar,
    );
  }
}