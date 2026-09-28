import 'package:flutter/material.dart';

import 'game/game_config.dart';
import 'game/progress_store.dart';
import 'game/session_model.dart';
import 'screens/game_over_screen.dart';
import 'screens/game_screen.dart';
import 'screens/loader_screen.dart';
import 'screens/menu_screen.dart';
import 'theme.dart';
import 'widgets/planner_sheet.dart';
import 'widgets/settings_sheet.dart';

void main() {
  runApp(const StudySproutApp());
}

/// Screens of the single state machine. 'gameover' is mandatory — it is the
/// frame the capture harness records as the session result.
enum Screen { loader, menu, game, gameover }

class StudySproutApp extends StatelessWidget {
  const StudySproutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudySprout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      builder: (BuildContext context, Widget? child) {
        // Guard the editorial layout against very large system font scales.
        return MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.1,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const SessionPlan _fallbackPlan = SessionPlan(
    subject: AppConfig.defaultSubject,
    seconds: AppConfig.sprintBlockSeconds,
    steps: AppConfig.defaultSteps,
  );

  final ProgressStore _store = ProgressStore();

  Screen _screen = Screen.loader;
  SessionResult? _lastResult;
  int _sessionKey = 0;

  /// The plan a session actually runs with. An emptied plan still starts a
  /// session on the default block — the menu CTA must never be a dead end.
  SessionPlan get _activePlan =>
      _store.plan.isEmpty ? _fallbackPlan : _store.plan;

  void _goMenu() {
    setState(() => _screen = Screen.menu);
  }

  void _beginSession() {
    setState(() {
      _sessionKey += 1;
      _screen = Screen.game;
    });
  }

  void _onSessionEnd(SessionResult result) {
    _store.recordSession(result);
    setState(() {
      _lastResult = result;
      _screen = Screen.gameover;
    });
  }

  Future<void> _openPlanner() async {
    final SessionPlan? next = await showPlannerSheet(context, _store.plan);
    if (next == null || !mounted) {
      return;
    }
    setState(() => _store.savePlan(next));
  }

  Future<void> _openSettings() async {
    final AppSettings? next = await showSettingsSheet(
      context,
      _store.settings,
      _store.resetGarden,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      if (next != null) {
        _store.saveSettings(next);
      }
    });
  }

  Widget _currentScreen() {
    switch (_screen) {
      case Screen.loader:
        return LoaderScreen(
          key: const ValueKey<String>('loader'),
          onReady: _goMenu,
        );
      case Screen.menu:
        return MenuScreen(
          key: const ValueKey<String>('menu'),
          store: _store,
          onBeginSession: _beginSession,
          onOpenPlanner: _openPlanner,
          onOpenSettings: _openSettings,
        );
      case Screen.game:
        return GameScreen(
          key: ValueKey<String>('game-$_sessionKey'),
          plan: _activePlan,
          streak: _store.streak,
          haptics: _store.settings.haptics,
          onSessionEnd: _onSessionEnd,
          onBack: _goMenu,
        );
      case Screen.gameover:
        return GameOverScreen(
          key: const ValueKey<String>('gameover'),
          result: _lastResult ??
              SessionResult(
                subject: _activePlan.subject,
                stepsDone: 0,
                stepsPlanned: _activePlan.steps,
                secondsFocused: _activePlan.seconds,
                outcome: SessionOutcome.saved,
              ),
          store: _store,
          onPlayAgain: _beginSession,
          onHome: _goMenu,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      child: _currentScreen(),
    );
  }
}
