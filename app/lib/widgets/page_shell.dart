import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../app/study_controller.dart';

class PageShell extends StatelessWidget {
  final StudyController controller;
  final String title;
  final int selected;
  final Widget child;
  const PageShell({
    super.key,
    required this.controller,
    required this.title,
    required this.selected,
    required this.child,
  });
  static const routes = ['/', '/study', '/test', '/questions', '/progress'];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: AppText(title),
      actions: [
        IconButton(
          tooltip: tr(context, 'Settings'),
          icon: const Icon(Icons.tune_rounded),
          onPressed: () {
            controller.speech.stop();
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    ),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (controller.storageWarning != null)
                  Notice(controller.storageWarning!),
                for (final warning
                    in controller.content?.warnings ?? <String>[])
                  Notice(warning),
                child,
              ],
            ),
          ),
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (i) {
        if (i != selected || title == 'Settings') {
          controller.speech.stop();
          Navigator.pushReplacementNamed(context, routes[i]);
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: tr(context, 'Home'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.style_outlined),
          selectedIcon: const Icon(Icons.style_rounded),
          label: tr(context, 'Study'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.record_voice_over_outlined),
          label: tr(context, 'Test'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.search_rounded),
          label: tr(context, 'Questions'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.insights_rounded),
          label: tr(context, 'Progress'),
        ),
      ],
    ),
  );
}

class Notice extends StatelessWidget {
  final String message;
  const Notice(this.message, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppText(message),
    ),
  );
}

class EmptyState extends StatelessWidget {
  final String title, message;
  const EmptyState({super.key, required this.title, required this.message});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          AppText(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
