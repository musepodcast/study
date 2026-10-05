import '../../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../../app/study_controller.dart';
import '../../widgets/page_shell.dart';

class HomeScreen extends StatelessWidget {
  final StudyController controller;
  const HomeScreen({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    final c = controller;
    return PageShell(
      controller: c,
      title: 'U.S. Civics Study',
      selected: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          AppText(
            'A little practice.\nA confident tomorrow.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 14),
          AppText(
            '2025 Citizenship Test',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          AppText(
            'English practice, with Portuguese by your side.\n${c.content!.locationLabel}',
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 20),
                  AppText(
                    '${c.studied} of 128 studied',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: c.studied / 128,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    '${c.mastered} mastered · ${c.needsPractice} need practice',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _action(
            context,
            'STUDY',
            'One question at a time',
            Icons.style_outlined,
            '/study',
          ),
          _action(
            context,
            'PRACTICE TEST',
            'Speak your answer. Build confidence.',
            Icons.record_voice_over_outlined,
            '/test',
          ),
          _action(
            context,
            'ALL QUESTIONS',
            'Search the complete official collection',
            Icons.search_rounded,
            '/questions',
          ),
          _action(
            context,
            'PROGRESS',
            'See how far you have come',
            Icons.insights_rounded,
            '/progress',
          ),
          _action(
            context,
            'SETTINGS',
            'Language, audio, and your location',
            Icons.tune_rounded,
            '/settings',
          ),
          const SizedBox(height: 14),
          const AppText(
            'Portuguese is study assistance. Practice speaking your answers in English.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _action(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    AppText(subtitle),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    ),
  );
}
