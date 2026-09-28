import 'package:flutter/material.dart';

import '../theme.dart';

/// One ledger figure. Colour carries the meaning; no raster icon is used, so
/// three cards in a row always share identical geometry (rule 22).
class StatData {
  final String value;
  final String label;
  final Color color;

  const StatData({
    required this.value,
    required this.label,
    required this.color,
  });

  bool get isMeaningful => value.isNotEmpty && value != '0';
}

class SessionStatCard extends StatelessWidget {
  /// Fixed so that a row of cards is always geometrically identical.
  static const double cardHeight = 66;

  final StatData data;

  const SessionStatCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.fade(AppColors.surface, 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.fade(data.color, 0.33), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: data.color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 5),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.05,
              color: data.color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the ledger only when at least two figures carry a value — a lone
/// pill reads as a layout mistake (rule 22).
class SessionStatRow extends StatelessWidget {
  final List<StatData> stats;
  final Widget? fallback;

  const SessionStatRow({super.key, required this.stats, this.fallback});

  @override
  Widget build(BuildContext context) {
    final List<StatData> visible =
        stats.where((StatData s) => s.isMeaningful).toList();
    if (visible.length < 2) {
      return fallback ?? const SizedBox.shrink();
    }

    final List<Widget> children = <Widget>[];
    for (int i = 0; i < visible.length; i++) {
      if (i > 0) {
        children.add(const SizedBox(width: 10));
      }
      children.add(Expanded(child: SessionStatCard(data: visible[i])));
    }

    return Row(children: children);
  }
}
