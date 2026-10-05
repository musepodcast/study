import '../../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../../app/study_controller.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/reset_progress.dart';

class ProgressScreen extends StatelessWidget {
  final StudyController controller;
  const ProgressScreen({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    final c = controller, tests = controller.progress.tests;
    final passed = tests.where((t) => t.passed).length;
    final average = tests.isEmpty
        ? 0
        : tests.map((t) => t.score).reduce((a, b) => a + b) / tests.length;
    final stats = <String, String>{
      'Questions Studied': '${c.studied} / 128',
      'Mastered': '${c.mastered}',
      'Needs Practice': '${c.needsPractice}',
      'Favorites': '${c.favorites}',
      'Not Studied': '${128 - c.studied}',
      'Official Tests': '${tests.length}',
      'Passed': '$passed',
      'Not Passed': '${tests.length - passed}',
      'Average Score': '${(average * 100).round()}%',
    };
    return PageShell(
      controller: c,
      title: 'Progress',
      selected: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            'Every step counts.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          const AppText(
            'Your progress is saved on this device. No account needed.',
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final entry in stats.entries)
                    SizedBox(
                      width: width,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                entry.value,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 6),
                              AppText(entry.key),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          AppText(
            'Recent test history',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (tests.isEmpty)
            const EmptyState(
              title: 'Your first test is ahead',
              message:
                  'Complete an official simulation to see your results here.',
            ),
          for (final t in tests.take(10))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Icon(
                    t.passed
                        ? Icons.verified_outlined
                        : Icons.auto_stories_outlined,
                  ),
                  title: AppText(t.passed ? 'Passed' : 'Not passed'),
                  subtitle: AppText(
                    '${t.correct} correct · ${t.incorrect} incorrect · ${t.asked} asked\n${t.date.toLocal().toString().substring(0, 16)}',
                  ),
                  trailing: AppText('${(t.score * 100).round()}%'),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const AppText(
            'Average score is the mean percentage correct among questions actually asked in each completed simulation.',
          ),
          const SizedBox(height: 12),
          ResetProgressButton(controller: c),
        ],
      ),
    );
  }
}
