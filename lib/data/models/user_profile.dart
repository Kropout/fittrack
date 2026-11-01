class UserProfile {
  final String name;
  final double weightKg;
  final double heightCm;
  final int dailyStepGoal;

  const UserProfile({
    required this.name,
    required this.weightKg,
    required this.heightCm,
    this.dailyStepGoal = 8000,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'dailyStepGoal': dailyStepGoal,
  };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    name: m['name'] as String,
    weightKg: (m['weightKg'] as num).toDouble(),
    heightCm: (m['heightCm'] as num).toDouble(),
    dailyStepGoal: (m['dailyStepGoal'] ?? 8000) as int,
  );
}