import '../local/hive_service.dart';
import '../models/workout.dart';

class WorkoutRepository {
  List<Workout> getAll() {
    final list = HiveService.workouts.values
        .map((e) => Workout.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date)); // newest first
    return list;
  }

  Future<void> add(Workout workout) =>
      HiveService.workouts.put(workout.id, workout.toMap());

  Future<void> delete(String id) => HiveService.workouts.delete(id);
}