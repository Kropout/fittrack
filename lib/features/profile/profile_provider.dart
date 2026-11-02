import 'package:flutter/foundation.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repo;
  UserProfile? _profile;

  ProfileProvider(this._repo) {
    _profile = _repo.get();
  }

  UserProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  Future<void> save(UserProfile profile) async {
    await _repo.save(profile);
    _profile = profile;
    notifyListeners();
  }

  /// Wipes every piece of locally stored app data. With no profile left,
  /// the app returns to onboarding automatically.
  Future<void> deleteAccount() async {
    await HiveService.workouts.clear();
    await HiveService.profile.clear();
    _profile = null;
    notifyListeners();
  }
}