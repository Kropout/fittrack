enum WorkoutType { run, gym, cycle, yoga }

extension WorkoutTypeX on WorkoutType {
  String get label {
    switch (this) {
      case WorkoutType.run:
        return 'Run';
      case WorkoutType.gym:
        return 'Gym';
      case WorkoutType.cycle:
        return 'Cycle';
      case WorkoutType.yoga:
        return 'Yoga';
    }
  }
}

class Workout {
  final String id;
  final WorkoutType type;
  final int durationMinutes;
  final int calories;
  final String notes;
  final DateTime date;

  const Workout({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.calories,
    this.notes = '',
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'durationMinutes': durationMinutes,
    'calories': calories,
    'notes': notes,
    'date': date.toIso8601String(),
  };

  factory Workout.fromMap(Map<String, dynamic> m) => Workout(
    id: m['id'] as String,
    type: WorkoutType.values.byName(m['type'] as String),
    durationMinutes: m['durationMinutes'] as int,
    calories: m['calories'] as int,
    notes: (m['notes'] ?? '') as String,
    date: DateTime.parse(m['date'] as String),
  );
}