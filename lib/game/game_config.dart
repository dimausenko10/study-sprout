/// Tunable session constants. Values here are load-bearing for the capture
/// harness as well as for gameplay — see CLAUDE-flutter.md rules 11/13.
class AppConfig {
  const AppConfig._();

  /// Splash duration, wall-clock. Must stay exactly 8000 (rule 13).
  static const int loaderDurationMs = 8000;

  /// Default focus block used by the one-tap START SESSION path.
  static const int sprintBlockSeconds = 30;

  /// No interaction at all for this long closes the block as BLOCK SAVED.
  /// Deliberately longer than the capture agent's ~22s first-frame latency so
  /// the focus screen is photographed before the result resolves.
  static const int idleBackstopMs = 40000;

  /// Armed after the FIRST GO tap and re-armed on every later tap. Shorter than
  /// the harness tap interval (~13s) so a single tap always yields a result.
  static const int engagedBackstopMs = 8000;

  static const String defaultSubject = 'MATH';
  static const int defaultSteps = 3;
  static const int minSteps = 1;
  static const int maxSteps = 5;

  static const int minDailyGoal = 1;
  static const int maxDailyGoal = 8;
  static const int defaultDailyGoal = 3;

  static const List<String> subjects = <String>[
    'MATH',
    'READING',
    'LANGUAGE',
    'SCIENCE',
    'NOTES',
    'CUSTOM',
  ];

  /// Selectable block lengths.
  static const List<BlockOption> durations = <BlockOption>[
    BlockOption('SPRINT 30s', sprintBlockSeconds),
    BlockOption('5 MIN', 300),
    BlockOption('15 MIN', 900),
    BlockOption('25 MIN', 1500),
  ];
}

/// One selectable focus-block length.
class BlockOption {
  final String label;
  final int seconds;

  const BlockOption(this.label, this.seconds);
}
