import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../app/study_controller.dart';
import '../models/question.dart';
import '../models/settings.dart';
import 'question_audio_controls.dart';
import 'pronounceable_text.dart';

class StudyCard extends StatefulWidget {
  final StudyController controller;
  final Question question;
  final bool revealed, officialTest;
  final VoidCallback onReveal;
  const StudyCard({
    super.key,
    required this.controller,
    required this.question,
    required this.revealed,
    required this.onReveal,
    this.officialTest = false,
  });
  @override
  State<StudyCard> createState() => _StudyCardState();
}

class _StudyCardState extends State<StudyCard> {
  bool help = false, questionRevealed = false;
  @override
  void didUpdateWidget(StudyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      help = false;
      questionRevealed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question, c = widget.controller;
    final language = c.settings.language;
    final showPt =
        !widget.officialTest &&
        (language == StudyLanguage.bilingual ||
            (language == StudyLanguage.onTap && help));
    final answers = c.content!.answers(q);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                AppText(
                  'QUESTION ${q.number} OF 128',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                if (q.special65_20)
                  const AppText(
                    '★ 65/20',
                    semanticsLabel: '65/20 special study question',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            AppText(
              q.category,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () => setState(() {
                questionRevealed = !questionRevealed;
                if (!questionRevealed) help = false;
              }),
              icon: Icon(
                questionRevealed
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              label: AppText(
                questionRevealed ? 'Hide Question' : 'Reveal Question',
              ),
            ),
            const SizedBox(height: 16),
            if (questionRevealed)
              PronounceableText(
                q.questionEnglish,
                controller: c,
                style: Theme.of(context).textTheme.headlineSmall,
              )
            else
              const AppText(
                'Listen first. Reveal the question if you need to read it.',
              ),
            const SizedBox(height: 20),
            QuestionAudioControls(controller: c, text: q.questionEnglish),
            if (questionRevealed || widget.revealed)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: AppText(
                  'Tap any English word to hear its pronunciation.',
                ),
              ),
            if (questionRevealed &&
                !widget.officialTest &&
                language == StudyLanguage.onTap)
              TextButton.icon(
                onPressed: () => setState(() => help = !help),
                icon: const Icon(Icons.translate_rounded),
                label: AppText(
                  help ? 'Hide Portuguese Help' : 'Portuguese Help',
                ),
              ),
            if (questionRevealed && showPt)
              _translation(context, q.questionPortuguese),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) => Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY((1 - animation.value) * 0.25),
                    child: child,
                  ),
                ),
              ),
              child: widget.revealed
                  ? Column(
                      key: ValueKey('answer-${q.id}'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 12),
                        AppText(
                          q.isDynamic
                              ? 'CONFIGURED CURRENT ANSWER'
                              : 'USCIS ACCEPTED ANSWERS',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        if (q.locationDependent)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: AppText(
                              'Answer for your configured location: ${c.content!.locationLabel}',
                            ),
                          ),
                        if (!c.content!.resolved(q))
                          const AppText(
                            'Current answer unavailable. The USCIS guidance is shown below; verify the current official before your interview.',
                          ),
                        const SizedBox(height: 12),
                        for (final answer in answers)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: PronounceableText(
                              '• $answer',
                              controller: c,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        QuestionAudioControls(
                          controller: c,
                          text: answers.join('. '),
                          label: 'Hear Answer',
                          showRate: false,
                        ),
                        if (showPt)
                          _translation(
                            context,
                            c.content!
                                .answers(q, portuguese: true)
                                .map((a) => '• $a')
                                .join('\n'),
                          ),
                        if (q.isDynamic)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: AppText(
                              'Current-answer question · Officials can change after elections or appointments.',
                            ),
                          ),
                        if (q.notes != null) Text(q.notes!),
                        if (q.studyTip != null && showPt)
                          _translation(context, q.studyTip!),
                      ],
                    )
                  : FilledButton.icon(
                      key: ValueKey('reveal-${q.id}'),
                      onPressed: widget.onReveal,
                      icon: const Icon(Icons.visibility_outlined),
                      label: AppText(
                        widget.officialTest ? 'Show Answer' : 'Reveal Answer',
                      ),
                    ),
            ),
            if (questionRevealed &&
                !widget.officialTest &&
                language != StudyLanguage.english &&
                q.vocabulary.isNotEmpty) ...[
              const SizedBox(height: 24),
              AppText(
                'Vocabulary · tap for Portuguese help',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final term in q.vocabulary)
                    ActionChip(
                      label: AppText(term),
                      onPressed: () => _vocabulary(context, term),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _translation(BuildContext context, String text) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.secondaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'PORTUGUÊS · AJUDA DE ESTUDO',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 6),
        Text(text),
      ],
    ),
  );
  void _vocabulary(BuildContext context, String term) {
    final matches = widget.controller.content!.vocabulary.where(
      (v) => v['term'] == term,
    );
    if (matches.isEmpty) {
      return;
    }
    final v = matches.first;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(term),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                v['translation'],
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(v['explanationPortuguese']),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => playSpeech(context, widget.controller, term),
            icon: const Icon(Icons.volume_up_outlined),
            label: const AppText('Pronounce Word'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('Close'),
          ),
        ],
      ),
    );
  }
}
