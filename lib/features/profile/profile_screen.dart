import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_profile.dart';
import 'profile_provider.dart';
import 'achievements_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _edit(
      BuildContext context, {
        required String title,
        required String initial,
        required bool numeric,
        required String? Function(String) validate,
        required UserProfile Function(UserProfile p, String value) apply,
      }) async {
    final provider = context.read<ProfileProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final current = provider.profile;
    if (current == null) return;

    final result = await showDialog<String>(
      context: context,
      builder: (_) =>
          _EditDialog(title: title, initial: initial, numeric: numeric),
    );
    if (result == null) return;

    final error = validate(result.trim());
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await provider.save(apply(current, result.trim()));
  }

  String? _numberIn(String v, double min, double max) {
    final n = double.tryParse(v);
    if (n == null || n < min || n > max) {
      return 'Enter a value between ${min.toInt()} and ${max.toInt()}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>().profile;
    if (p == null) return const SizedBox.shrink();

    String trim(double d) =>
        d == d.roundToDouble() ? d.toInt().toString() : d.toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FITTRACK', style: AppTextStyles.label),
          const SizedBox(height: 12),
          Text('Profile', style: AppTextStyles.headline),
          const SizedBox(height: 32),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0C0E1B),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    p.name.isEmpty ? '?' : p.name[0].toUpperCase(),
                    style: GoogleFonts.sora(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(fontSize: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Text('GOALS & BODY', style: AppTextStyles.label),
          const SizedBox(height: 8),
          _Row(
            label: 'Name',
            value: p.name,
            onTap: () => _edit(
              context,
              title: 'Name',
              initial: p.name,
              numeric: false,
              validate: (v) => v.isEmpty ? 'Enter your name' : null,
              apply: (old, v) => UserProfile(
                name: v,
                weightKg: old.weightKg,
                heightCm: old.heightCm,
                dailyStepGoal: old.dailyStepGoal,
              ),
            ),
          ),
          _Row(
            label: 'Weight',
            value: '${trim(p.weightKg)} kg',
            onTap: () => _edit(
              context,
              title: 'Weight (kg)',
              initial: trim(p.weightKg),
              numeric: true,
              validate: (v) => _numberIn(v, 20, 300),
              apply: (old, v) => UserProfile(
                name: old.name,
                weightKg: double.parse(v),
                heightCm: old.heightCm,
                dailyStepGoal: old.dailyStepGoal,
              ),
            ),
          ),
          _Row(
            label: 'Height',
            value: '${trim(p.heightCm)} cm',
            onTap: () => _edit(
              context,
              title: 'Height (cm)',
              initial: trim(p.heightCm),
              numeric: true,
              validate: (v) => _numberIn(v, 100, 250),
              apply: (old, v) => UserProfile(
                name: old.name,
                weightKg: old.weightKg,
                heightCm: double.parse(v),
                dailyStepGoal: old.dailyStepGoal,
              ),
            ),
          ),
          _Row(
            label: 'Daily step goal',
            value: '${p.dailyStepGoal} steps',
            onTap: () => _edit(
              context,
              title: 'Daily step goal',
              initial: '${p.dailyStepGoal}',
              numeric: true,
              validate: (v) => _numberIn(v, 1000, 50000),
              apply: (old, v) => UserProfile(
                name: old.name,
                weightKg: old.weightKg,
                heightCm: old.heightCm,
                dailyStepGoal: double.parse(v).round(),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text('ACHIEVEMENTS', style: AppTextStyles.label),
          const SizedBox(height: 16),
          const AchievementsSection(),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _Row({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.body)),
            Text(value, style: AppTextStyles.bodyStrong),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _EditDialog extends StatefulWidget {
  final String title;
  final String initial;
  final bool numeric;
  const _EditDialog({
    required this.title,
    required this.initial,
    required this.numeric,
  });

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final TextEditingController _c =
  TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
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
        keyboardType: widget.numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.hairline),
          ),
          focusedBorder: UnderlineInputBorder(
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
          onPressed: () => Navigator.pop(context, _c.text),
          child: Text(
            'Save',
            style: AppTextStyles.bodyStrong
                .copyWith(color: AppColors.goldLight),
          ),
        ),
      ],
    );
  }
}