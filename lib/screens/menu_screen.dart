import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets.dart';
import '../game/progress_store.dart';
import '../game/session_model.dart';
import '../theme.dart';
import '../widgets/garden_strip.dart';
import '../widgets/primary_button.dart';
import '../widgets/session_stat_card.dart';

/// Study Home — asymmetric editorial layout: left-aligned hero wordmark, art
/// pushed to the right margin, the plan ledger beneath a single large CTA.
class MenuScreen extends StatefulWidget {
  final ProgressStore store;
  final VoidCallback onBeginSession;
  final VoidCallback onOpenPlanner;
  final VoidCallback onOpenSettings;

  const MenuScreen({
    super.key,
    required this.store,
    required this.onBeginSession,
    required this.onOpenPlanner,
    required this.onOpenSettings,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final List<CurvedAnimation> _steps;

  @override
  void initState() {
    super.initState();
    _steps = List<CurvedAnimation>.generate(4, (int i) {
      final double begin = i * 0.12;
      return CurvedAnimation(
        parent: _intro,
        curve: Interval(begin, begin + 0.64, curve: Curves.easeOutCubic),
      );
    });
    // One-shot: the menu must settle so the capture harness sees idle frames.
    _intro.forward();
  }

  @override
  void dispose() {
    for (final CurvedAnimation step in _steps) {
      step.dispose();
    }
    _intro.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) {
    final Animation<double> anim = _steps[index];
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProgressStore store = widget.store;
    final SessionPlan plan = store.plan;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bgTop,
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
                  AppColors.fade(AppColors.bgTop, 0.88),
                  AppColors.fade(AppColors.bgBottom, 0.96),
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
                    _header(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 16),
                            _stagger(0, _heroWordmark()),
                            const SizedBox(height: 4),
                            _stagger(1, _heroArt(store.menuStage)),
                            const SizedBox(height: 4),
                            _stagger(2, _planCard(plan)),
                            if (store.hasGardenHistory) ...<Widget>[
                              const SizedBox(height: 14),
                              _stagger(2, GardenStrip(
                                days: store.garden,
                                compact: true,
                              )),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      _planHint(plan),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _stagger(
                      3,
                      PrimaryButton(
                        label: 'START SESSION',
                        icon: Icons.play_arrow_rounded,
                        onTap: widget.onBeginSession,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: SessionStatCard.cardHeight,
                      child: SessionStatRow(
                        stats: <StatData>[
                          StatData(
                            value: '${store.streak}',
                            label: 'STREAK',
                            color: AppColors.secondary,
                          ),
                          StatData(
                            value: '${store.totalBlocks}',
                            label: 'BLOCKS',
                            color: AppColors.primary,
                          ),
                          StatData(
                            value: '${store.totalMinutes}',
                            label: 'MINUTES',
                            color: AppColors.textPrimary,
                          ),
                        ],
                        fallback: const Center(
                          child: Text(
                            'START YOUR FIRST BLOCK TODAY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
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

  String _planHint(SessionPlan plan) {
    if (plan.isEmpty) {
      return 'DEFAULT: MATH · 30 SEC WARM-UP · 3 STEPS';
    }
    return '${plan.subject} · ${plan.lengthLabel} · ${plan.steps} STEPS';
  }

  Widget _header() {
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              AppAssets.icon,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                  const Icon(Icons.eco, size: 24, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.fade(AppColors.surface, 0.90),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'TODAY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            iconSize: 24,
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            onPressed: widget.onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.textPrimary,
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _heroWordmark() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'STUDY',
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.w800,
            height: 0.98,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const Text(
          'SPROUT',
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.w800,
            height: 0.98,
            letterSpacing: -0.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 14),
        Container(width: 56, height: 3, color: AppColors.secondary),
        const SizedBox(height: 12),
        const FractionallySizedBox(
          widthFactor: 0.82,
          child: Text(
            'PLAN SMALL BLOCKS. GROW EVERY DAY.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
              letterSpacing: 0.3,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroArt(int stage) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 196,
        height: 196,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 196,
              height: 196,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.fade(AppColors.accent, 0.45),
              ),
            ),
            Image.asset(
              stageAsset(stage),
              width: 168,
              height: 168,
              fit: BoxFit.contain,
              errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                  const Icon(Icons.eco, size: 120, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard(SessionPlan plan) {
    final int rows = plan.steps > 3 ? 3 : plan.steps;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fade(AppColors.surface, 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.fade(AppColors.textPrimary, 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'TODAY\'S PLAN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: TextButton(
                  onPressed: widget.onOpenPlanner,
                  child: const Text(
                    'EDIT PLAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (plan.isEmpty)
            _emptyPlan()
          else
            for (int i = 0; i < rows; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: <Widget>[
                    Icon(
                      i == 0
                          ? Icons.check_circle_outline
                          : Icons.circle_outlined,
                      size: 18,
                      color: i == 0 ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        plan.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      plan.stepLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _emptyPlan() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          const Icon(Icons.eco_outlined, size: 28, color: Color(0xFFA9BF97)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'NO BLOCKS YET',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'TAP EDIT PLAN TO ADD ONE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
