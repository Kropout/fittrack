import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../profile/profile_provider.dart';
import 'protein_provider.dart';

class ProteinCard extends StatelessWidget {
  const ProteinCard({super.key});

  static const _quickAmounts = [10, 20, 30];

  Future<void> _addCustom(BuildContext context) async {
    final provider = context.read<ProteinProvider>();
    final grams = await showDialog<int>(
      context: context,
      builder: (_) => const _NumberDialog(
        title: 'Add protein',
        suffix: 'g',
        min: 1,
        max: 200,
      ),
    );
    if (grams != null) await provider.add(grams);
  }

  Future<void> _editGoal(BuildContext context, int current) async {
    final provider = context.read<ProteinProvider>();
    final grams = await showDialog<int>(
      context: context,
      builder: (_) => _NumberDialog(
        title: 'Daily protein goal',
        suffix: 'g',
        min: 20,
        max: 400,
        initial: '$current',
      ),
    );
    if (grams != null) await provider.setGoal(grams);
  }

  @override
  Widget build(BuildContext context) {
    final protein = context.watch<ProteinProvider>();
    final profile = context.watch<ProfileProvider>().profile;

    final goal = protein.goalFor(profile?.weightKg ?? 70);
    final today = protein.today;
    final progress = goal == 0 ? 0.0 : (today / goal).clamp(0.0, 1.0);
    final canUndo = protein.todayEntries.isNotEmpty;

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
                    Text('PROTEIN', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Text('$today / $goal g', style: AppTextStyles.title),
                  ],
                ),
              ),
              if (canUndo)
                GestureDetector(
                  onTap: () => protein.undoLast(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: const Icon(
                      Icons.undo,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
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
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final g in _quickAmounts)
                _chip('+$g g', () {
                  HapticFeedback.selectionClick();
                  protein.add(g);
                }),
              _chip('Custom', () => _addCustom(context), highlight: true),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  '7-day average ${protein.weekAverage} g',
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _editGoal(context, goal),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'Edit goal',
                    style: AppTextStyles.bodyStrong.copyWith(
                      fontSize: 13,
                      color: AppColors.goldLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (protein.savedGoal == null) ...[
            const SizedBox(height: 4),
            Text(
              'Default goal is 1.6 g per kg of body weight. '
                  'Needs vary, so adjust it to your own plan.',
              style: AppTextStyles.body.copyWith(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, VoidCallback onTap, {bool highlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: highlight ? AppColors.goldLight : AppColors.hairline,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyStrong.copyWith(
            color: highlight ? AppColors.goldLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _NumberDialog extends StatefulWidget {
  final String title;
  final String suffix;
  final int min;
  final int max;
  final String initial;

  const _NumberDialog({
    required this.title,
    required this.suffix,
    required this.min,
    required this.max,
    this.initial = '',
  });

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  late final TextEditingController _c =
  TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    final v = int.tryParse(_c.text.trim());
    if (v == null || v < widget.min || v > widget.max) {
      setState(
            () => _error = 'Enter a value between ${widget.min} and ${widget.max}',
      );
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
      title: Text(widget.title, style: AppTextStyles.title),
      content: TextField(
        controller: _c,
        autofocus: true,
        cursorColor: AppColors.goldLight,
        style: AppTextStyles.bodyStrong,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          suffixText: widget.suffix,
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