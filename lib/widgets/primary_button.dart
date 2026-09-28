import 'package:flutter/material.dart';

import '../theme.dart';

/// Gradient call-to-action. Icon box and text line-height are both locked to
/// 24px so the icon and the label always share one baseline (rule 21).
class PrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double height;
  final List<Color> gradient;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.height = 60,
    this.gradient = AppColors.ctaGradient,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 110),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.fade(widget.gradient.first, 0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: Ink(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: widget.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(widget.icon, size: 24, color: AppColors.surface),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.surface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quiet paired action. Text only — a decorative icon here would read as noise.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double height;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fade(AppColors.surface, 0.92),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              height: 24 / 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
