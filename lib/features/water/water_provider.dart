import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/local/hive_service.dart';

class WaterProvider extends ChangeNotifier {
  static const goal = 8; // glasses per day
  static const _max = 20;

  static String _key(DateTime d) =>
      'water_${DateFormat('yyyy-MM-dd').format(d)}';

  int get today => (HiveService.profile.get(_key(DateTime.now())) ?? 0) as int;

  Future<void> add() async {
    if (today >= _max) return;
    await HiveService.profile.put(_key(DateTime.now()), today + 1);
    notifyListeners();
  }

  Future<void> remove() async {
    if (today <= 0) return;
    await HiveService.profile.put(_key(DateTime.now()), today - 1);
    notifyListeners();
  }
}