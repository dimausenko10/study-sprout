import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../game/session_model.dart';
import '../theme.dart';
import 'chips.dart';

/// Optional planner. It edits the saved plan only — it never launches a
/// session, so the menu CTA stays the single path into the focus screen.
Future<SessionPlan?> showPlannerSheet(BuildContext context, SessionPlan plan) {
  return showModalBottomSheet<SessionPlan>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) => _PlannerSheet(plan: plan),
  );
}

class _PlannerSheet extends StatefulWidget {
  final SessionPlan plan;

  const _PlannerSheet({required this.plan});

  @override
  State<_PlannerSheet> createState() => _PlannerSheetState();
}

class _PlannerSheetState extends State<_PlannerSheet> {
  late String _subject;
  late int _seconds;
  late int _steps;
  bool _custom = false;
  bool _showError = false;
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final SessionPlan plan = widget.plan;
    _steps = plan.isEmpty ? AppConfig.defaultSteps : plan.steps;
    _seconds = plan.seconds;
    if (AppConfig.subjects.contains(plan.subject)) {
      _subject = plan.subject;
    } else {
      _subject = 'CUSTOM';
      _custom = true;
      _customController.text = plan.subject;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool get _valid => !_custom || _customController.text.trim().isNotEmpty;

  void _save() {
    if (!_valid) {
      setState(() => _showError = true);
      return;
    }
    final String subject =
        _custom ? _customController.text.trim().toUpperCase() : _subject;
    Navigator.of(context).pop(
      SessionPlan(subject: subject, seconds: _seconds, steps: _steps),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
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
                Text(
                  'SESSION PLANNER',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                const Text(
                  'PICK A SUBJECT AND A BLOCK LENGTH',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                _label('SUBJECT'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    for (final String subject in AppConfig.subjects)
                      OptionChip(
                        label: subject,
                        selected: _subject == subject,
                        onTap: () => setState(() {
                          _subject = subject;
                          _custom = subject == 'CUSTOM';
                          _showError = false;
                        }),
                      ),
                  ],
                ),
                if (_custom) ...<Widget>[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customController,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (String value) =>
                        setState(() => _showError = false),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'YOUR SUBJECT',
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  if (_showError) ...<Widget>[
                    const SizedBox(height: 8),
                    const Text(
                      'ENTER A SUBJECT NAME',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                _label('BLOCK LENGTH'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    for (final BlockOption option in AppConfig.durations)
                      OptionChip(
                        label: option.label,
                        selected: _seconds == option.seconds,
                        accent: AppColors.secondary,
                        onTap: () => setState(() => _seconds = option.seconds),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(child: _label('STEPS IN THIS BLOCK')),
                    CountStepper(
                      value: _steps,
                      min: AppConfig.minSteps,
                      max: AppConfig.maxSteps,
                      onChanged: (int next) => setState(() => _steps = next),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Opacity(
                  opacity: _valid ? 1.0 : 0.45,
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _save,
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: const Text(
                          'SAVE PLAN',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.surface,
                          ),
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
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.3,
        color: AppColors.textMuted,
      ),
    );
  }
}
