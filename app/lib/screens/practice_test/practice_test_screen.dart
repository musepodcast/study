import '../../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../../app/study_controller.dart';
import '../../core/test_session.dart';
import '../../models/progress.dart';
import '../../models/question.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/study_card.dart';
import '../study/study_screen.dart';

class PracticeTestScreen extends StatefulWidget {
  final StudyController controller;
  const PracticeTestScreen({super.key, required this.controller});
  @override
  State<PracticeTestScreen> createState() => _PracticeTestScreenState();
}

class _PracticeTestScreenState extends State<PracticeTestScreen> {
  TestSession? session;
  bool revealed = false;
  void grade(bool correct) {
    final s = session!, c = widget.controller;
    final q = s.current;
    c.speech.stop();
    setState(() {
      s.grade(correct);
      revealed = false;
    });
    c.markStudied(
      q.id,
      status: correct ? StudyStatus.mastered : StudyStatus.needsPractice,
      correct: correct,
    );
    if (s.outcome != TestOutcome.inProgress) {
      c.addResult(
        TestResult(
          date: DateTime.now(),
          correct: s.correct,
          incorrect: s.incorrect,
          passed: s.outcome == TestOutcome.passed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller, s = session;
    return PageShell(
      controller: c,
      title: 'Practice Test',
      selected: 2,
      child: s == null
          ? _menu(context)
          : s.outcome != TestOutcome.inProgress
          ? _result(context, s)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  'OFFICIAL TEST SIMULATION',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                AppText(
                  'Answer aloud in English, then check your answer. Give as many answers as the question asks for.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    AppText('Question ${s.asked + 1} of up to 20'),
                    AppText('${s.correct} correct'),
                    AppText('${s.incorrect} incorrect'),
                    AppText('${s.remaining} possible questions left'),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: s.correct / 12,
                  semanticsLabel: tr(
                    context,
                    'Correct answers toward 12 required to pass',
                  ),
                ),
                const SizedBox(height: 20),
                StudyCard(
                  controller: c,
                  question: s.current,
                  revealed: revealed,
                  officialTest: true,
                  onReveal: () => setState(() => revealed = true),
                ),
                if (revealed) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => grade(true),
                        icon: const Icon(Icons.check_rounded),
                        label: const AppText('Correct'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => grade(false),
                        icon: const Icon(Icons.close_rounded),
                        label: const AppText('Incorrect'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final quit = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const AppText('End this test?'),
                        content: const AppText(
                          'An unfinished test will not be added to test history.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const AppText('Continue Test'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const AppText('End Test'),
                          ),
                        ],
                      ),
                    );
                    if (quit == true && mounted) {
                      c.speech.stop();
                      setState(() => session = null);
                    }
                  },
                  child: const AppText('End Test'),
                ),
              ],
            ),
    );
  }

  Widget _menu(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppText(
        'Make room for confidence.',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 20),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.record_voice_over_rounded, size: 44),
              const SizedBox(height: 16),
              AppText(
                'OFFICIAL TEST SIMULATION',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const AppText(
                '128-question pool · Up to 20 random questions\n12 correct to pass. The test stops as soon as the result is determined.',
              ),
              const SizedBox(height: 12),
              const AppText(
                'Self-graded oral practice. No speech recognition. Portuguese help is hidden in this simulation.',
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => setState(() {
                  session = TestSession(widget.controller.content!.questions);
                  revealed = false;
                }),
                child: const AppText('Start Official Simulation'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 28),
      AppText(
        'Extra practice',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      const AppText(
        'Flash-card study collections. These do not use official pass/fail scoring.',
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final mode in [
            'Random 10',
            'Random 20',
            'All 128 Random',
            'All 128 In Order',
            'Needs Practice',
            'Favorites',
            '65/20 Questions',
          ])
            OutlinedButton(
              onPressed: () => _study(context, mode),
              child: AppText(mode),
            ),
        ],
      ),
      const SizedBox(height: 20),
      const AppText(
        '65/20 study covers the 20 starred questions. Eligible applicants take a separate USCIS test of 10 questions, with 6 correct required; this app’s official simulator uses the standard rules.',
      ),
    ],
  );
  void _study(BuildContext context, String mode) {
    final c = widget.controller;
    var pool = List<Question>.of(c.content!.questions);
    if (mode == 'Needs Practice') {
      pool = pool
          .where((q) => c.record(q.id)?.status == StudyStatus.needsPractice)
          .toList();
    }
    if (mode == 'Favorites') {
      pool = pool.where((q) => c.record(q.id)?.favorite == true).toList();
    }
    if (mode == '65/20 Questions') {
      pool = pool.where((q) => q.special65_20).toList();
    }
    if (mode.contains('Random')) {
      pool.shuffle();
    }
    if (mode == 'Random 10') {
      pool = pool.take(10).toList();
    }
    if (mode == 'Random 20') {
      pool = pool.take(20).toList();
    }
    Navigator.pushNamed(
      context,
      '/study',
      arguments: StudyOptions(questions: pool, label: mode),
    );
  }

  Widget _result(BuildContext context, TestSession s) => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            s.outcome == TestOutcome.passed
                ? Icons.verified_rounded
                : Icons.auto_stories_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          AppText(
            s.outcome == TestOutcome.passed ? 'PASSED' : 'NOT PASSED',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          AppText(
            '${s.correct} correct\n${s.incorrect} incorrect\n${s.asked} questions asked',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          AppText(
            s.outcome == TestOutcome.passed
                ? 'Your practice is paying off. Keep building your confidence.'
                : 'Every practice session helps. Revisit Needs Practice, then try again.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => setState(() => session = null),
            child: const AppText('Back to Practice'),
          ),
          TextButton(
            onPressed: () => _study(context, 'Needs Practice'),
            child: const AppText('Study Needs Practice'),
          ),
        ],
      ),
    ),
  );
}
