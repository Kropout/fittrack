import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';


class WorkoutTimer extends StatefulWidget {
  /// Called with the elapsed time rounded up to whole minutes.
  final ValueChanged<int> onUse;
  const WorkoutTimer({super.key, required this.onUse});

  @override
  State<WorkoutTimer> createState() => _WorkoutTimerState();
}

class _WorkoutTimerState extends State<WorkoutTimer> {
  Timer? _ticker;
  Duration _accum = Duration.zero;
  DateTime? _startedAt;

  bool get _running => _startedAt != null;

  // Based on timestamps, so the time stays correct if the app is backgrounded.
  Duration get _elapsed =>
      _accum +
          (_startedAt == null
              ? Duration.zero
              : DateTime.now().difference(_startedAt!));

  void _start() {
    _startedAt = DateTime.now();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
          (_) => setState(() {}),
    );
    setState(() {});
  }

  void _pause() {
    _accum = _elapsed;
    _startedAt = null;
    _ticker?.cancel();
    setState(() {});
  }

  void _reset() {
    _ticker?.cancel();
    _startedAt = null;
    _accum = Duration.zero;
    setState(() {});
  }

  void _use() {
    final seconds = _elapsed.inSeconds;
    final minutes = math.min(999, math.max(1, (seconds / 60).ceil()));
    _pause();
    widget.onUse(minutes);
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTime = _elapsed.inSeconds > 0;

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
          Text('TIMER', style: AppTextStyles.label),
          const SizedBox(height: 10),
          Text(
            _format(_elapsed),
            style: GoogleFonts.sora(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _pill(_running ? 'Pause' : (hasTime ? 'Resume' : 'Start'),
                  _running ? _pause : _start,
                  highlight: true),
              if (hasTime) _pill('Reset', _reset),
              if (hasTime && !_running) _pill('Use time', _use),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, VoidCallback onTap, {bool highlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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