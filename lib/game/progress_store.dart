import 'session_model.dart';

/// In-memory progress for the current app run: streak, totals, the 7-day
/// garden, the saved plan and the local settings.
///
/// Reads and writes go through [load] / [_persist] so that swapping the backing
/// store for a real key-value store stays a single-file change; the app ships
/// with no extra plugin dependency.
class ProgressStore {
  ProgressStore() {
    _history = List<int>.of(const <int>[-1, -1, -1, -1, -1, -1, -1]);
  }

  static const List<String> _weekdayLabels = <String>[
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  int streak = 0;
  int totalBlocks = 0;
  int totalMinutes = 0;
  int sproutStage = 0;

  SessionPlan plan = const SessionPlan(subject: 'MATH', seconds: 30, steps: 3);
  AppSettings settings = const AppSettings();

  late List<int> _history;
  String? _lastCountedDay;

  Future<void> load() async {
    // No persistent backend in this build; state is seeded by the constructor.
  }

  Future<void> _persist() async {
    // Intentionally a no-op seam for a future persistent backend.
  }

  /// Last seven days, oldest first, labelled by weekday.
  List<GardenDay> get garden {
    final DateTime today = DateTime.now();
    return List<GardenDay>.generate(7, (int i) {
      final DateTime day = today.subtract(Duration(days: 6 - i));
      return GardenDay(
        label: _weekdayLabels[day.weekday - 1],
        stage: _history[i],
      );
    });
  }

  bool get hasGardenHistory => _history.any((int stage) => stage >= 0);

  /// Growth stage shown on the menu hero — starts as a sprout, not a bare seed.
  int get menuStage {
    final int grown = 1 + (totalBlocks ~/ 2);
    return grown > 3 ? 3 : grown;
  }

  void savePlan(SessionPlan next) {
    plan = next;
    _persist();
  }

  void saveSettings(AppSettings next) {
    settings = next;
    _persist();
  }

  void recordSession(SessionResult result) {
    totalBlocks += 1;
    totalMinutes += result.minutesFocused;
    if (result.stage > sproutStage) {
      sproutStage = result.stage;
    }
    if (result.stage > _history[6]) {
      _history[6] = result.stage;
    }

    final String today = _dayKey(DateTime.now());
    if (_lastCountedDay != today) {
      streak += 1;
      _lastCountedDay = today;
    }
    _persist();
  }

  void resetGarden() {
    streak = 0;
    totalBlocks = 0;
    totalMinutes = 0;
    sproutStage = 0;
    _lastCountedDay = null;
    _history = List<int>.of(const <int>[-1, -1, -1, -1, -1, -1, -1]);
    plan = const SessionPlan.empty();
    _persist();
  }

  static String _dayKey(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
