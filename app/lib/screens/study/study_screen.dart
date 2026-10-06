import '../../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../../app/study_controller.dart';
import '../../models/progress.dart';
import '../../models/question.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/study_card.dart';

class StudyOptions {
  final List<Question>? questions;
  final int start;
  final String label;
  const StudyOptions({this.questions, this.start = 0, this.label = 'Study'});
}

class StudyScreen extends StatefulWidget {
  final StudyController controller;
  final StudyOptions options;
  const StudyScreen({
    super.key,
    required this.controller,
    this.options = const StudyOptions(),
  });
  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late List<Question> questions;
  late int index;
  bool revealed = false, randomOrder = false;
  @override
  void initState() {
    super.initState();
    questions = List.of(
      widget.options.questions ?? widget.controller.content!.questions,
    );
    randomOrder = widget.options.label.contains('Random');
    index = questions.isEmpty
        ? 0
        : widget.options.start.clamp(0, questions.length - 1);
  }

  void move(int offset) {
    widget.controller.speech.stop();
    setState(() {
      index += offset;
      revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    if (questions.isEmpty) {
      return PageShell(
        controller: c,
        title: widget.options.label,
        selected: 1,
        child: const EmptyState(
          title: 'Your collection starts here',
          message:
              'Mark questions as favorites or Needs Practice while studying, then return to this mode.',
        ),
      );
    }
    final q = questions[index], record = c.record(questions[index].id);
    return PageShell(
      controller: c,
      title: widget.options.label,
      selected: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              AppText('${index + 1} / ${questions.length} in this session'),
              DropdownButton<bool>(
                isExpanded: true,
                value: randomOrder,
                items: const [
                  DropdownMenuItem(
                    value: false,
                    child: AppText('Official Order'),
                  ),
                  DropdownMenuItem(value: true, child: AppText('Random Order')),
                ],
                onChanged: (v) {
                  c.speech.stop();
                  setState(() {
                    randomOrder = v!;
                    if (v) {
                      questions.shuffle();
                    } else {
                      questions.sort((a, b) => a.number.compareTo(b.number));
                    }
                    index = 0;
                    revealed = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (index + 1) / questions.length,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 20),
          StudyCard(
            controller: c,
            question: q,
            revealed: revealed,
            onReveal: () {
              setState(() => revealed = true);
              c.markStudied(q.id);
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: revealed
                    ? () => c.toggleStudyStatus(q.id, StudyStatus.mastered)
                    : null,
                icon: Icon(
                  record?.status == StudyStatus.mastered
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                ),
                label: AppText(
                  record?.status == StudyStatus.mastered
                      ? 'Undo Know It'
                      : 'Know It',
                ),
              ),
              OutlinedButton.icon(
                onPressed: revealed
                    ? () => c.toggleStudyStatus(q.id, StudyStatus.needsPractice)
                    : null,
                icon: Icon(
                  record?.status == StudyStatus.needsPractice
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                ),
                label: AppText(
                  record?.status == StudyStatus.needsPractice
                      ? 'Undo Needs Practice'
                      : 'Needs Practice',
                ),
              ),
              TextButton.icon(
                onPressed: () => c.toggleFavorite(q.id),
                icon: Icon(
                  record?.favorite == true
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                ),
                label: AppText(
                  record?.favorite == true ? 'Remove Favorite' : 'Favorite',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: MediaQuery.textScalerOf(context).scale(16) > 20
                    ? double.infinity
                    : 148,
                child: OutlinedButton.icon(
                  onPressed: index > 0 ? () => move(-1) : null,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const AppText('Previous'),
                ),
              ),
              SizedBox(
                width: MediaQuery.textScalerOf(context).scale(16) > 20
                    ? double.infinity
                    : 148,
                child: FilledButton.icon(
                  onPressed: index < questions.length - 1
                      ? () => move(1)
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const AppText('Next'),
                ),
              ),
            ],
          ),
          if (index == questions.length - 1 && revealed)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: AppText(
                'You reached the end of this collection. Keep practicing the questions you want to strengthen.',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
