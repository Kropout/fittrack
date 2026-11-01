import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import '../../core/utils/activity_permission.dart';
import '../../data/local/hive_service.dart';

class StepsProvider extends ChangeNotifier {
  static const _lastRawKey = 'steps_last_raw';
  static String _key(DateTime d) =>
      'steps_${DateFormat('yyyy-MM-dd').format(d)}';

  StreamSubscription<StepCount>? _sub;
  bool _tracking = false;
  bool _permissionDenied = false;
  bool _sensorError = false;

  bool get permissionDenied => _permissionDenied;
  bool get sensorError => _sensorError;
  bool get isTracking => _tracking;

  int stepsFor(DateTime d) => (HiveService.profile.get(_key(d)) ?? 0) as int;
  int get today => stepsFor(DateTime.now());

  Future<void> setToday(int steps) async {
    await HiveService.profile.put(_key(DateTime.now()), steps);
    notifyListeners();
  }

  Future<void> startTracking() async {
    if (_tracking) return;
    final granted = await ActivityPermission.request();
    _permissionDenied = !granted;
    if (granted) {
      _sensorError = false;
      _sub = Pedometer.stepCountStream.listen(
        _onStep,
        onError: (_) {
          _sensorError = true;
          notifyListeners();
        },
        cancelOnError: false,
      );
      _tracking = true;
    }
    notifyListeners();
  }

  Future<void> _onStep(StepCount event) async {
    final raw = event.steps;
    final box = HiveService.profile;
    final last = box.get(_lastRawKey) as int?;

    var delta = 0;
    if (last != null) {
      // raw < last means the phone rebooted and the counter restarted.
      delta = raw >= last ? raw - last : raw;
    }
    await box.put(_lastRawKey, raw);
    if (delta > 0) await setToday(today + delta);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}