import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/local/hive_service.dart';

class ProteinProvider extends ChangeNotifier {
  static const _goalKey = 'protein_goal';

  static String _logKey(DateTime d) =>
      'protein_log_${DateFormat('yyyy-MM-dd').format(d)}';

  /// Every individual entry (in grams) logged on [d].
  List<int> entriesFor(DateTime d) {
    final raw = HiveService.profile.get(_logKey(d));
    if (raw is List) return raw.whereType<int>().toList();
    return [];
  }

  int totalFor(DateTime d) => entriesFor(d).fold(0, (a, b) => a + b);

  DateTime get _now => DateTime.now();

  int get today => totalFor(_now);
  List<int> get todayEntries => entriesFor(_now);

  /// A goal the user has set themselves, or null if they haven't.
  int? get savedGoal => HiveService.profile.get(_goalKey) as int?;

  /// Default is 1.6 g per kg of body weight until the user sets their own.
  int goalFor(double weightKg) => savedGoal ?? (weightKg * 1.6).round();

  /// Average grams per day over the last 7 days.
  int get weekAverage {
    final now = _now;
    var total = 0;
    for (var i = 0; i < 7; i++) {
      total += totalFor(DateTime(now.year, now.month, now.day - i));
    }
    return (total / 7).round();
  }

  Future<void> setGoal(int grams) async {
    await HiveService.profile.put(_goalKey, grams);
    notifyListeners();
  }

  Future<void> add(int grams) async {
    final list = [...todayEntries, grams];
    await HiveService.profile.put(_logKey(_now), list);
    notifyListeners();
  }

  Future<void> undoLast() async {
    final list = todayEntries;
    if (list.isEmpty) return;
    list.removeLast();
    await HiveService.profile.put(_logKey(_now), list);
    notifyListeners();
  }
}