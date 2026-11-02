import 'package:flutter/foundation.dart';
import '../../data/local/hive_service.dart';

class GoalProvider extends ChangeNotifier {
  static const _key = 'weekly_workout_goal';

  int get weeklyWorkouts => (HiveService.profile.get(_key) ?? 3) as int;

  Future<void> setWeeklyWorkouts(int value) async {
    await HiveService.profile.put(_key, value.clamp(1, 7).toInt());
    notifyListeners();
  }
}