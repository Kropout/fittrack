import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../workouts/workout_provider.dart';
import 'profile_provider.dart';

class DeleteAccountSection extends StatelessWidget {
  const DeleteAccountSection({super.key});

  static const _danger = Color(0xFFE57373);

  Future<void> _start(BuildContext context) async {
    // Grab what we need before any await, because this screen
    // disappears once the account is deleted.
    final profileProvider = context.read<ProfileProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    final navigator = Navigator.of(context);

    // Step 1
    final first = await _confirm(
      context,
      title: 'Delete account?',
      message: 'This removes your profile and every workout, step count, '
          'water and weight record stored on this device.',
      confirmLabel: 'Continue',
      warning: false,
    );
    if (first != true || !context.mounted) return;

    // Step 2
    final second = await _confirm(
      context,
      title: 'This cannot be undone',
      message: 'All your user data will be permanently cleared and cannot be '
          'recovered. You will be taken back to the start of onboarding.',
      confirmLabel: 'Delete everything',
      warning: true,
    );
    if (second != true) return;

    await profileProvider.deleteAccount();
    workoutProvider.reload();
    navigator.popUntil((route) => route.isFirst);
  }

  Future<bool?> _confirm(
      BuildContext context, {
        required String title,
        required String message,
        required String confirmLabel,
        required bool warning,
      }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: warning ? _danger.withOpacity(0.5) : AppColors.hairline,
          ),
        ),
        title: Row(
          children: [
            if (warning) ...[
              const Icon(Icons.warning_amber_rounded, color: _danger),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(title, style: AppTextStyles.title)),
          ],
        ),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: AppTextStyles.bodyStrong.copyWith(color: _danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ACCOUNT', style: AppTextStyles.label),
        const SizedBox(height: 12),
        Text(
          'Permanently remove your profile and all data from this device.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _start(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: _danger.withOpacity(0.6)),
            ),
            alignment: Alignment.center,
            child: Text(
              'Delete account',
              style: AppTextStyles.bodyStrong.copyWith(color: _danger),
            ),
          ),
        ),
      ],
    );
  }
}