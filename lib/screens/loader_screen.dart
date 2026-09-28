import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/painters.dart';

/// Branded splash. Dark, centred and grain-textured so it can never be
/// confused with the light editorial menu that follows it.
///
/// The hand-off is driven by a wall-clock [Timer], never by an animation
/// callback: on CI the animator duration scale can be zero, which would finish
/// every controller instantly and skip this screen entirely.
class LoaderScreen extends StatefulWidget {
  final VoidCallback onReady;

  const LoaderScreen({super.key, required this.onReady});

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final CurvedAnimation _fade = CurvedAnimation(
    parent: _intro,
    curve: Curves.easeOut,
  );
  late final CurvedAnimation _pop = CurvedAnimation(
    parent: _intro,
    curve: Curves.easeOutBack,
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 0.88, end: 1.0).animate(_pop);

  Timer? _handoff;

  @override
  void initState() {
    super.initState();
    // One-shot only. A looping controller would keep the window busy and the
    // screenshot harness would never see an idle frame.
    _intro.forward();
    _handoff = Timer(
      const Duration(milliseconds: AppConfig.loaderDurationMs),
      () {
        if (mounted) {
          widget.onReady();
        }
      },
    );
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _fade.dispose();
    _pop.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.loaderBottom,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.bgLoader),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        AppColors.fade(AppColors.loaderTop, 0.82),
                        AppColors.fade(AppColors.loaderBottom, 0.94),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: CustomPaint(painter: SeedGrainPainter()),
              ),
              Positioned.fill(
                child: SafeArea(
                  child: Center(
                    child: FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: _brandMark(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandMark(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 168,
          height: 168,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.fade(AppColors.surface, 0.07),
            border: Border.all(
              color: AppColors.fade(AppColors.accent, 0.35),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Image.asset(
            AppAssets.spriteSprout,
            width: 132,
            height: 132,
            fit: BoxFit.contain,
            errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                const Icon(Icons.eco, size: 88, color: AppColors.accent),
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'STUDYSPROUT',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: AppColors.loaderTitle,
          ),
        ),
        const SizedBox(height: 14),
        Container(width: 48, height: 2, color: AppColors.primary),
        const SizedBox(height: 14),
        const Text(
          'SMALL GOALS · DAILY GROWTH',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: AppColors.loaderSubtitle,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 168,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: AnimatedBuilder(
              animation: _intro,
              builder: (BuildContext context, Widget? child) {
                return LinearProgressIndicator(
                  value: _intro.value,
                  minHeight: 4,
                  backgroundColor: AppColors.fade(AppColors.surface, 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accent,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'LOADING...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: AppColors.loaderStatus,
          ),
        ),
      ],
    );
  }
}
