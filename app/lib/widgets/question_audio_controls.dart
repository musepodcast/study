import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../app/study_controller.dart';
import '../models/settings.dart';
import '../services/speech_service.dart';

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
    rate: controller.settings.speechRate,
    onError: unavailable,
  );
  if (!ok) {
    unavailable();
  }
}

class QuestionAudioControls extends StatelessWidget {
  final StudyController controller;
  final String text;
  final String label;
  final bool showRate;
  const QuestionAudioControls({
    super.key,
    required this.controller,
    required this.text,
    this.label = 'Play Question',
    this.showRate = true,
  });
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller.speech,
    builder: (context, _) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => playSpeech(context, controller, text),
          icon: const Icon(Icons.volume_up_outlined),
          label: AppText(label),
        ),
        if (showRate)
          TextButton.icon(
            onPressed: () => playSpeech(context, controller, text),
            icon: const Icon(Icons.replay_rounded),
            label: const AppText('Repeat Question'),
          ),
        if (controller.speech.state != PlaybackState.idle) ...[
          TextButton.icon(
            onPressed: () async {
              final paused = controller.speech.state == PlaybackState.paused;
              final ok = await (paused
                  ? controller.speech.resume()
                  : controller.speech.pause());
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: AppText(
                      'Playback control unavailable. Use Stop and play again.',
                    ),
                  ),
                );
              }
            },
            icon: Icon(
              controller.speech.state == PlaybackState.paused
                  ? Icons.play_arrow
                  : Icons.pause,
            ),
            label: AppText(
              controller.speech.state == PlaybackState.paused
                  ? 'Resume Audio'
                  : 'Pause Audio',
            ),
          ),
          TextButton.icon(
            onPressed: controller.speech.stop,
            icon: const Icon(Icons.stop),
            label: const AppText('Stop Audio'),
          ),
        ],
        if (showRate)
          SizedBox(
            width: 160,
            child: Semantics(
              container: true,
              child: DropdownButtonFormField<double>(
                key: ValueKey(controller.settings.speechRate),
                initialValue: controller.settings.speechRate,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: tr(context, 'Speech speed'),
                ),
                items: [
                  for (final rate in StudySettings.speechRates)
                    DropdownMenuItem(
                      value: rate,
                      child: Text(StudySettings.speechRateLabel(rate)),
                    ),
                ],
                onChanged: (rate) {
                  controller.speech.stop();
                  controller.settings.speechRate = rate!;
                  controller.save();
                },
              ),
            ),
          ),
      ],
    ),
  );
}
