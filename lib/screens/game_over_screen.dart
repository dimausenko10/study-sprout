import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets.dart';
import '../game/progress_store.dart';
import '../game/session_model.dart';
import '../theme.dart';
import '../widgets/garden_strip.dart';
import '../widgets/primary_button.dart';
import '../widgets/session_stat_card.dart';

/// Progress Garden — the session result plus the seven-day history bed.
/// Centred composition, warmer wash: distinct from both the menu and the
/// session screen so every captured frame is visually unique.
class GameOverScreen extends StatefulWidget {
  final SessionResult result;
  final ProgressStore store;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const GameOverScreen({
    super.key,
    required this.result,
    required this.store,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _intro,
    curve: Curves.easeOutBack,
  );
  late final Animation<double> _heroScale =
      Tween<double>(begin: 0.85, end: 1.0).animate(_curve);

  @override
  void initState() {
    super.initState();
    // One-shot — the result frame must settle for the capture harness.
    _intro.forward();
  }

  @override
  void dispose() {
    _curve.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SessionResult result = widget.result;
    final ProgressStore store = widget.store;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.surfaceAlt,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.bgMenu),
              fit: BoxFit.cover,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.fade(AppColors.surfaceAlt, 0.93),
                  AppColors.fade(const Color(0xFFE3F0D3), 0.97),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 44,
                  left: 22,
                  right: 22,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Text(
                              result.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 44,
                              height: 3,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${result.subject} · ${result.minutesFocused} MIN FOCUSED',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            ScaleTransition(
                              scale: _heroScale,
                              child: _hero(result.stage),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: SessionStatCard.cardHeight,
                              child: SessionStatRow(
                                stats: <StatData>[
                                  StatData(
                                    value: '${result.stepsDone}',
                                    label: 'STEPS',
                                    color: AppColors.primary,
                                  ),
                                  StatData(
                                    value: '${result.minutesFocused}',
                                    label: 'MINUTES',
                                    color: AppColors.secondary,
                                  ),
                                  StatData(
                                    value: '${store.streak}',
                                    label: 'STREAK',
                                    color: AppColors.textPrimary,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'PROGRESS GARDEN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.3,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GardenStrip(days: store.garden),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      'KEEP THE STREAK ALIVE TOMORROW',
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
                      label: 'START AGAIN',
                      icon: Icons.refresh_rounded,
                      onTap: widget.onPlayAgain,
                    ),
                    const SizedBox(height: 10),
                    SecondaryButton(
                      label: 'BACK TO HOME',
                      onTap: widget.onHome,
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

  Widget _hero(int stage) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  AppColors.fade(AppColors.accent, 0.55),
                  AppColors.fade(AppColors.accent, 0.10),
                ],
              ),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.fade(AppColors.surface, 0.90),
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              stageAsset(stage),
              width: 132,
              height: 132,
              fit: BoxFit.contain,
              errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                  const Icon(Icons.eco, size: 92, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
