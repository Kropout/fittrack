import 'package:flutter/foundation.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/workout_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repo;
  List<Workout> _workouts = [];

  WorkoutProvider(this._repo) {
    _workouts = _repo.getAll();
  }

  List<Workout> get workouts => List.unmodifiable(_workouts);
  Workout? get latest => _workouts.isEmpty ? null : _workouts.first;

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Iterable<Workout> _on(DateTime d) =>
      _workouts.where((w) => _sameDay(w.date, d));

  int caloriesOn(DateTime d) => _on(d).fold(0, (s, w) => s + w.calories);
  int minutesOn(DateTime d) => _on(d).fold(0, (s, w) => s + w.durationMinutes);
  int countOn(DateTime d) => _on(d).length;

  int get todayCalories => caloriesOn(DateTime.now());
  int get todayMinutes => minutesOn(DateTime.now());

  /// Consecutive days with at least one workout. A streak stays alive
  /// until the end of today, so it counts from yesterday if you haven't
  /// trained yet today.
  int get streak {
    final days = _workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet();
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    if (!days.contains(day)) {
      day = DateTime(day.year, day.month, day.day - 1);
    }
    var count = 0;
    while (days.contains(day)) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }
  int get totalMinutes => _workouts.fold(0, (s, w) => s + w.durationMinutes);
  int get totalCalories => _workouts.fold(0, (s, w) => s + w.calories);

  /// Best run of consecutive workout days ever, so badges never un-earn.
  int get longestStreak {
    final days = _workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet()
        .toList()
      ..sort();
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final d in days) {
      if (prev != null && d == DateTime(prev.year, prev.month, prev.day + 1)) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  Future<void> add(Workout workout) async {
    await _repo.add(workout);
    _workouts = _repo.getAll();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    _workouts = _repo.getAll();
    notifyListeners();
  }
}