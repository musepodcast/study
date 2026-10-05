import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../app/study_controller.dart';

Future<void> playSpeech(
  BuildContext context,
  StudyController controller,
  String text,
) async {
  bool reported = false;
  void unavailable() {
    if (reported || !context.mounted) {
      return;
    }
    reported = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: AppText(
          'Audio is unavailable. Read the English text aloud, or enable an English voice on your device.',
        ),
      ),
    );
  }

  final ok = await controller.speech.speak(
    text,
    slow: controller.settings.slowAudio,
    onError: unavailable,
  );
  if (!ok) {
    unavailable();
  }
}

class QuestionAudioControls extends StatelessWidget {
  final StudyController controller;
  final String text;
  const QuestionAudioControls({
    super.key,
    required this.controller,
    required this.text,
  });
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      OutlinedButton.icon(
        onPressed: () => playSpeech(context, controller, text),
        icon: const Icon(Icons.volume_up_outlined),
        label: const AppText('Play Question'),
      ),
      TextButton.icon(
        onPressed: () => playSpeech(context, controller, text),
        icon: const Icon(Icons.replay_rounded),
        label: const AppText('Repeat Question'),
      ),
    ],
  );
}
