import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../game/session_model.dart';
import '../theme.dart';
import 'chips.dart';

/// Local preferences plus the destructive garden reset.
/// Returns the edited settings, or null when dismissed.
Future<AppSettings?> showSettingsSheet(
  BuildContext context,
  AppSettings settings,
  VoidCallback onResetGarden,
) {
  return showModalBottomSheet<AppSettings>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) => _SettingsSheet(
      settings: settings,
      onResetGarden: onResetGarden,
    ),
  );
}

class _SettingsSheet extends StatefulWidget {
  final AppSettings settings;
  final VoidCallback onResetGarden;

  const _SettingsSheet({required this.settings, required this.onResetGarden});

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late AppSettings _settings = widget.settings;

  Future<void> _confirmReset() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFFDFEFB),
        title: const Text('RESET GARDEN', style: TextStyle(fontSize: 18)),
        content: const Text(
          'This clears your streak, totals and the seven-day bed.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'RESET',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }
    widget.onResetGarden();
    Navigator.of(context).pop(_settings);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFEFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('SETTINGS', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              _row(
                icon: Icons.notifications_none,
                label: 'SESSION CHIME',
                trailing: Switch.adaptive(
                  value: _settings.chime,
                  onChanged: (bool value) => setState(
                    () => _settings = _settings.copyWith(chime: value),
                  ),
                ),
              ),
              _divider(),
              _row(
                icon: Icons.vibration,
                label: 'HAPTICS',
                trailing: Switch.adaptive(
                  value: _settings.haptics,
                  onChanged: (bool value) => setState(
                    () => _settings = _settings.copyWith(haptics: value),
                  ),
                ),
              ),
              _divider(),
              _row(
                icon: Icons.wb_sunny_outlined,
                label: 'DAILY GOAL',
                trailing: CountStepper(
                  value: _settings.dailyGoal,
                  min: AppConfig.minDailyGoal,
                  max: AppConfig.maxDailyGoal,
                  onChanged: (int value) => setState(
                    () => _settings = _settings.copyWith(dailyGoal: value),
                  ),
                ),
              ),
              _divider(),
              SizedBox(
                height: 56,
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.delete_outline,
                      size: 24,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'RESET GARDEN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _confirmReset,
                      child: const Text(
                        'RESET',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'OFFLINE · NO ACCOUNT · v1.0.0',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.fade(AppColors.textMuted, 0.85),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: SecondaryDone(
                  onTap: () => Navigator.of(context).pop(_settings),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return SizedBox(
      height: 56,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 24, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: AppColors.border);
}

/// Small confirm affordance at the foot of the settings sheet.
class SecondaryDone extends StatelessWidget {
  final VoidCallback onTap;

  const SecondaryDone({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 48,
          width: 160,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: const Text(
            'DONE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
