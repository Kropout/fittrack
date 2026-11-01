import '../local/hive_service.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  static const _key = 'me';

  bool get hasProfile => HiveService.profile.containsKey(_key);

  UserProfile? get() {
    final raw = HiveService.profile.get(_key);
    if (raw == null) return null;
    return UserProfile.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> save(UserProfile profile) =>
      HiveService.profile.put(_key, profile.toMap());
}