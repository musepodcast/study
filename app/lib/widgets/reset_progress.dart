import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../app/study_controller.dart';

class ResetProgressButton extends StatelessWidget {
  final StudyController controller;
  const ResetProgressButton({super.key, required this.controller});
  @override
  Widget build(BuildContext context) => TextButton.icon(
    icon: const Icon(Icons.restart_alt_rounded),
    label: const AppText('Reset Progress'),
    onPressed: () async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const AppText('Reset your progress?'),
          content: const AppText(
            'This deletes studied status, favorites, and test history on this device. Your settings are kept.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const AppText('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const AppText('Reset Progress'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        controller.resetProgress();
      }
    },
  );
}
