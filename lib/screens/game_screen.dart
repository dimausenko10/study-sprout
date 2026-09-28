import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/session_model.dart';
import '../theme.dart';
import '../widgets/painters.dart';
import '../widgets/primary_button.dart';
import '../widgets/session_stat_card.dart';

/// Focus session — split panel: growth bed on top, one large action below.
///
/// The ring advances from a one-second ticker rather than a free-running
/// AnimationController: a continuously animating window never goes idle, and
/// the screenshot harness waits for idle before it can capture this screen.
class GameScreen extends StatefulWidget {
  final SessionPlan plan;
  final int streak;
  final bool haptics;
  final ValueChanged<SessionResult> onSessionEnd;
  final VoidCallback onBack;

  const GameScreen({
    super.key,
    required this.plan,
    required this.streak,
    required this.haptics,
    required this.onSessionEnd,
    required this.onBack,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _elapsed = 0;
  int _stepsDone = 0;
  bool _paused = false;
  bool _finished = false;

  Timer? _ticker;
  Timer? _idleBackstop;
  Timer? _engagedBackstop;

  int get _totalSteps => widget.plan.steps < 1 ? 1 : widget.plan.steps;
  int get _blockSeconds =>
      widget.plan.seconds < 5 ? AppConfig.sprintBlockSeconds : widget.plan.seconds;
  int get _stage => _stepsDone > 3 ? 3 : _stepsDone;
  double get _progress => (_elapsed / _blockSeconds).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
    // Passive backstop: a run with no interaction at all still resolves.
    // Not re-armed on taps — the short engaged backstop covers that case.
    _idleBackstop = Timer(
      const Duration(milliseconds: AppConfig.idleBackstopMs),
      () => _finish(SessionOutcome.saved),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _idleBackstop?.cancel();
    _engagedBackstop?.cancel();
    super.dispose();
  }

  void _onTick(Timer timer) {
    if (_finished || _paused || !mounted) {
      return;
    }
    setState(() => _elapsed += 1);
    if (_elapsed >= _blockSeconds) {
      _finish(SessionOutcome.saved);
    }
  }

  void _togglePause() {
    if (_finished) return;
    setState(() => _paused = !_paused);
  }

  void _onGo() {
    if (_finished) return;

    if (widget.haptics) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {
        // Vibration is unavailable on some devices; never break the session.
      }
    }

    setState(() {
      _paused = false;
      _stepsDone = _stepsDone + 1 > _totalSteps ? _totalSteps : _stepsDone + 1;
    });

    if (_stepsDone >= _totalSteps) {
      _finish(SessionOutcome.complete);
      return;
    }

    // Re-armed on every tap and deliberately shorter than the harness tap
    // interval, so a single GO always produces a result.
    _engagedBackstop?.cancel();
    _engagedBackstop = Timer(
      const Duration(milliseconds: AppConfig.engagedBackstopMs),
      () => _finish(SessionOutcome.saved),
    );
  }

  void _finish(SessionOutcome outcome) {
    if (_finished || !mounted) {
      return;
    }
    _finished = true;
    _ticker?.cancel();
    _idleBackstop?.cancel();
    _engagedBackstop?.cancel();

    widget.onSessionEnd(
      SessionResult(
        subject: widget.plan.subject,
        stepsDone: _stepsDone,
        stepsPlanned: _totalSteps,
        secondsFocused: _elapsed < 1 ? 1 : _elapsed,
        outcome: outcome,
      ),
    );
  }

  String get _clock {
    final int remaining = _blockSeconds - _elapsed;
    final int safe = remaining < 0 ? 0 : remaining;
    final String mm = (safe ~/ 60).toString().padLeft(2, '0');
    final String ss = (safe % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bgTop,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.bgGame),
              fit: BoxFit.cover,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.fade(AppColors.bgTop, 0.92),
                  AppColors.fade(const Color(0xFFE7F1DA), 0.96),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 44,
                  left: 20,
                  right: 20,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _header(),
                    Expanded(child: _growthBed()),
                    const Text(
                      'TAP GO TO CHECK OFF THE CURRENT STEP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    PrimaryButton(
                      label: 'GO',
                      icon: Icons.eco_rounded,
                      onTap: _onGo,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: SessionStatCard.cardHeight,
                      child: SessionStatRow(
                        stats: <StatData>[
                          StatData(
                            value: '$_stepsDone/$_totalSteps',
                            label: 'DONE',
                            color: AppColors.primary,
                          ),
                          StatData(
                            value: '${_totalSteps - _stepsDone}',
                            label: 'LEFT',
                            color: AppColors.secondary,
                          ),
                          StatData(
                            value: '${widget.streak}',
                            label: 'STREAK',
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          IconButton(
            iconSize: 24,
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              widget.plan.subject.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.fade(AppColors.surface, 0.90),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _clock,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthBed() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double byWidth = constraints.maxWidth - 56;
        final double byHeight = constraints.maxHeight - 110;
        final double ring =
            math.max(140, math.min(math.min(byWidth, byHeight), 300));
        final double dim = _paused ? 0.6 : 1.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 16,
                top: 20,
                child: Opacity(opacity: 0.5, child: _leaf(40)),
              ),
              Positioned(
                right: 18,
                bottom: 22,
                child: Opacity(opacity: 0.5, child: _leaf(46)),
              ),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: _togglePause,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: ring,
                        height: ring,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            CustomPaint(
                              size: Size.square(ring),
                              painter: FocusRingPainter(
                                progress: _progress,
                                trackColor: AppColors.border,
                                gradientColors: const <Color>[
                                  AppColors.accent,
                                  AppColors.primary,
                                ],
                                dim: dim,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 420),
                              transitionBuilder:
                                  (Widget child, Animation<double> anim) {
                                return FadeTransition(
                                  opacity: anim,
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.9,
                                      end: 1.0,
                                    ).animate(anim),
                                    child: child,
                                  ),
                                );
                              },
                              child: Image.asset(
                                stageAsset(_stage),
                                key: ValueKey<int>(_stage),
                                width: ring * 0.5,
                                height: ring * 0.5,
                                fit: BoxFit.contain,
                                errorBuilder: (
                                  BuildContext c,
                                  Object e,
                                  StackTrace? s,
                                ) =>
                                    Icon(
                                  Icons.eco,
                                  size: ring * 0.36,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (_paused)
                              Positioned(
                                bottom: 18,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.fade(
                                      AppColors.surface,
                                      0.92,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'PAUSED',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.4,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'STEP ${_stepsDone + 1 > _totalSteps ? _totalSteps : _stepsDone + 1} OF $_totalSteps',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        for (int i = 0; i < _totalSteps; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: _stepDot(i),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stepDot(int index) {
    final bool done = index < _stepsDone;
    final bool current = index == _stepsDone;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.primary : AppColors.border,
        border: current
            ? Border.all(color: AppColors.secondary, width: 2)
            : null,
      ),
    );
  }

  Widget _leaf(double size) {
    return Image.asset(
      AppAssets.spriteLeaf,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (BuildContext c, Object e, StackTrace? s) => Icon(
        Icons.spa_outlined,
        size: size * 0.8,
        color: AppColors.fade(AppColors.primary, 0.5),
      ),
    );
  }
}
