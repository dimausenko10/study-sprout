// Component-level tests for StudySprout.
//
// These deliberately avoid the full screens: those render AI-generated PNGs
// that are produced later in the build pipeline and are not on disk yet when
// tests run.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_sprout/game/game_config.dart';
import 'package:study_sprout/game/progress_store.dart';
import 'package:study_sprout/game/session_model.dart';
import 'package:study_sprout/widgets/primary_button.dart';
import 'package:study_sprout/widgets/session_stat_card.dart';

void main() {
  testWidgets('PrimaryButton renders its label and reports taps',
      (WidgetTester tester) async {
    int taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'START SESSION',
            icon: Icons.play_arrow_rounded,
            onTap: () => taps += 1,
          ),
        ),
      ),
    );

    expect(find.text('START SESSION'), findsOneWidget);

    await tester.tap(find.text('START SESSION'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('Stat row hides itself when fewer than two figures carry a value',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SessionStatRow(
            stats: <StatData>[
              StatData(value: '0', label: 'STREAK', color: Colors.green),
              StatData(value: '0', label: 'BLOCKS', color: Colors.green),
              StatData(value: '4', label: 'MINUTES', color: Colors.green),
            ],
            fallback: Text('NO FIGURES YET'),
          ),
        ),
      ),
    );

    expect(find.text('NO FIGURES YET'), findsOneWidget);
    expect(find.byType(SessionStatCard), findsNothing);
  });

  testWidgets('Stat row renders every meaningful figure',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SessionStatRow(
            stats: <StatData>[
              StatData(value: '2', label: 'STREAK', color: Colors.green),
              StatData(value: '0', label: 'BLOCKS', color: Colors.green),
              StatData(value: '12', label: 'MINUTES', color: Colors.green),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(SessionStatCard), findsNWidgets(2));
    expect(find.text('BLOCKS'), findsNothing);
  });

  test('Loader duration stays at the value the capture harness needs', () {
    expect(AppConfig.loaderDurationMs, 8000);
  });

  test('Recording a session grows the garden and the streak', () {
    final ProgressStore store = ProgressStore();

    expect(store.streak, 0);
    expect(store.hasGardenHistory, isFalse);

    store.recordSession(
      const SessionResult(
        subject: 'MATH',
        stepsDone: 3,
        stepsPlanned: 3,
        secondsFocused: 30,
        outcome: SessionOutcome.complete,
      ),
    );

    expect(store.streak, 1);
    expect(store.totalBlocks, 1);
    expect(store.totalMinutes, 1);
    expect(store.hasGardenHistory, isTrue);
    expect(store.garden.length, 7);
    expect(store.garden.last.stage, 3);

    // A second block on the same day advances totals but not the streak.
    store.recordSession(
      const SessionResult(
        subject: 'READING',
        stepsDone: 1,
        stepsPlanned: 3,
        secondsFocused: 30,
        outcome: SessionOutcome.saved,
      ),
    );

    expect(store.streak, 1);
    expect(store.totalBlocks, 2);
  });

  test('Resetting the garden empties the plan but keeps a runnable default',
      () {
    final ProgressStore store = ProgressStore();
    store.recordSession(
      const SessionResult(
        subject: 'MATH',
        stepsDone: 2,
        stepsPlanned: 3,
        secondsFocused: 30,
        outcome: SessionOutcome.saved,
      ),
    );

    store.resetGarden();

    expect(store.streak, 0);
    expect(store.totalBlocks, 0);
    expect(store.hasGardenHistory, isFalse);
    expect(store.plan.isEmpty, isTrue);
  });
}
