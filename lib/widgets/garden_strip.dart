import 'package:flutter/material.dart';

import '../game/session_model.dart';
import '../theme.dart';

/// Seven-day history bed. Compact on the menu, full height on the result.
class GardenStrip extends StatelessWidget {
  final List<GardenDay> days;
  final bool compact;

  const GardenStrip({super.key, required this.days, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final double tileHeight = compact ? 34 : 56;

    return SizedBox(
      height: compact ? 56 : 82,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (final GardenDay day in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: tileHeight,
                      decoration: BoxDecoration(
                        color: day.isEmpty
                            ? const Color(0xFFEDF3E4)
                            : AppColors.fade(AppColors.accent, 0.45),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: day.isEmpty
                              ? AppColors.border
                              : AppColors.fade(AppColors.primary, 0.45),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: day.isEmpty
                          ? const Icon(
                              Icons.remove,
                              size: 14,
                              color: Color(0xFFC6D6B7),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                stageAsset(day.stage),
                                fit: BoxFit.contain,
                                errorBuilder: (BuildContext c, Object e, StackTrace? s) => const Icon(
                                  Icons.eco,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      day.label,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: 0.4,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
