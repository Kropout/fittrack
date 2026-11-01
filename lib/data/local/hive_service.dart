import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const workoutsBoxName = 'workouts';
  static const profileBoxName = 'profile';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(workoutsBoxName);
    await Hive.openBox(profileBoxName);
  }

  static Box get workouts => Hive.box(workoutsBoxName);
  static Box get profile => Hive.box(profileBoxName);
}