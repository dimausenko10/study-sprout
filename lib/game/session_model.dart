import '../assets.dart';

/// A planned focus block: one subject, one length, N check-off steps.
class SessionPlan {
  final String subject;
  final int seconds;
  final int steps;

  const SessionPlan({
    required this.subject,
    required this.seconds,
    required this.steps,
  });

  const SessionPlan.empty()
      : subject = 'MATH',
        seconds = 30,
        steps = 0;

  bool get isEmpty => steps <= 0;

  /// Per-step budget rendered for the plan card ('10s' / '5m').
  String get stepLabel {
    if (steps <= 0) return '--';
    final int per = (seconds / steps).round();
    return per >= 60 ? '${(per / 60).round()}m' : '${per}s';
  }

  String get lengthLabel =>
      seconds >= 60 ? '${(seconds / 60).round()} MIN' : '$seconds SEC';

  SessionPlan copyWith({String? subject, int? seconds, int? steps}) {
    return SessionPlan(
      subject: subject ?? this.subject,
      seconds: seconds ?? this.seconds,
      steps: steps ?? this.steps,
    );
  }
}

enum SessionOutcome { complete, saved }

/// Outcome of one focus block, handed to the result screen.
class SessionResult {
  final String subject;
  final int stepsDone;
  final int stepsPlanned;
  final int secondsFocused;
  final SessionOutcome outcome;

  const SessionResult({
    required this.subject,
    required this.stepsDone,
    required this.stepsPlanned,
    required this.secondsFocused,
    required this.outcome,
  });

  bool get isComplete => outcome == SessionOutcome.complete;

  String get title => isComplete ? 'SESSION COMPLETE' : 'BLOCK SAVED';

  int get minutesFocused {
    final int rounded = (secondsFocused / 60).round();
    return rounded < 1 ? 1 : rounded;
  }

  /// Growth stage reached in this block (0 seed .. 3 bloom).
  int get stage => stepsDone >= 3 ? 3 : stepsDone;
}

/// One column of the progress garden. [stage] < 0 means an unused day.
class GardenDay {
  final String label;
  final int stage;

  const GardenDay({required this.label, required this.stage});

  bool get isEmpty => stage < 0;
}

/// Locally held preferences surfaced through the settings sheet.
class AppSettings {
  final bool chime;
  final bool haptics;
  final int dailyGoal;

  const AppSettings({
    this.chime = true,
    this.haptics = true,
    this.dailyGoal = 3,
  });

  AppSettings copyWith({bool? chime, bool? haptics, int? dailyGoal}) {
    return AppSettings(
      chime: chime ?? this.chime,
      haptics: haptics ?? this.haptics,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }
}

/// Growth-stage sprite lookup — the single place asset paths map to stages.
String stageAsset(int stage) {
  switch (stage) {
    case 0:
      return AppAssets.spriteSeed;
    case 1:
      return AppAssets.spriteSprout;
    case 2:
      return AppAssets.spriteLeafy;
    default:
      return AppAssets.spriteBloom;
  }
}
