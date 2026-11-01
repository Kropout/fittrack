import '../../data/models/workout.dart';

class CalorieCalculator {
  // MET = how intense an activity is compared to resting
  static const _met = {
    WorkoutType.run: 9.8,
    WorkoutType.gym: 5.0,
    WorkoutType.cycle: 7.5,
    WorkoutType.yoga: 2.5,
  };

  /// calories = MET x weight (kg) x hours
  static int estimate({
    required WorkoutType type,
    required int durationMinutes,
    required double weightKg,
  }) {
    final hours = durationMinutes / 60.0;
    return (_met[type]! * weightKg * hours).round();
  }
}