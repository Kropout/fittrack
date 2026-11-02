import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/local/hive_service.dart';

class WeightEntry {
  final DateTime date;
  final double kg;
  const WeightEntry(this.date, this.kg);
}

class WeightProvider extends ChangeNotifier {
  static const _prefix = 'weight_';

  static String _key(DateTime d) =>
      '$_prefix${DateFormat('yyyy-MM-dd').format(d)}';

  /// All entries, oldest first.
  List<WeightEntry> get entries {
    final list = <WeightEntry>[];
    for (final k in HiveService.profile.keys) {
      if (k is String && k.startsWith(_prefix)) {
        final v = HiveService.profile.get(k);
        final date = DateTime.tryParse(k.substring(_prefix.length));
        if (v is num && date != null) {
          list.add(WeightEntry(date, v.toDouble()));
        }
      }
    }
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  Future<void> log(double kg) async {
    await HiveService.profile.put(_key(DateTime.now()), kg);
    notifyListeners();
  }
}