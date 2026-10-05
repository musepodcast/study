import '../../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../../app/study_controller.dart';
import '../../models/progress.dart';
import '../../models/question.dart';
import '../../widgets/page_shell.dart';
import '../study/study_screen.dart';

class QuestionsScreen extends StatefulWidget {
  final StudyController controller;
  const QuestionsScreen({super.key, required this.controller});
  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  String search = '', filter = 'All', category = 'All categories';
  bool matches(Question q) {
    final c = widget.controller, p = c.record(q.id);
    if (category != 'All categories' && q.category != category) {
      return false;
    }
    if (filter == 'Mastered' && p?.status != StudyStatus.mastered) {
      return false;
    }
    if (filter == 'Needs Practice' && p?.status != StudyStatus.needsPractice) {
      return false;
    }
    if (filter == 'Favorites' && p?.favorite != true) {
      return false;
    }
    if (filter == 'Not Studied' && p?.lastStudied != null) {
      return false;
    }
    if (filter == '65/20 Questions' && !q.special65_20) {
      return false;
    }
    return '${q.number} ${q.questionEnglish} ${q.questionPortuguese} ${q.answersEnglish.join(' ')} ${q.answersPortuguese.join(' ')} ${c.content!.answers(q).join(' ')} ${q.vocabulary.join(' ')}'
        .toLowerCase()
        .contains(search.toLowerCase().trim());
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller,
        visible = c.content!.questions.where(matches).toList();
    return PageShell(
      controller: c,
      title: 'All Questions',
      selected: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            'Your civics collection',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              labelText: tr(context, 'Search questions, answers, or numbers'),
            ),
            onChanged: (v) => setState(() => search = v),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in [
                'All',
                'Mastered',
                'Needs Practice',
                'Favorites',
                'Not Studied',
                '65/20 Questions',
              ])
                FilterChip(
                  label: AppText(f),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            itemHeight: null,
            initialValue: category,
            isExpanded: true,
            decoration: InputDecoration(labelText: tr(context, 'Category')),
            items:
                [
                      'All categories',
                      ...c.content!.questions.map((q) => q.category).toSet(),
                    ]
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: AppText(v, maxLines: 2),
                      ),
                    )
                    .toList(),
            onChanged: (v) => setState(() => category = v!),
          ),
          const SizedBox(height: 16),
          AppText('${visible.length} questions'),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            const EmptyState(
              title: 'No matches yet',
              message: 'Try a different search or filter.',
            ),
          for (final q in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () =>
                      Navigator.pushNamed(context, '/question/${q.number}'),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 38,
                          child: AppText(
                            '${q.number}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q.questionEnglish),
                              const SizedBox(height: 6),
                              AppText(
                                '${q.category}${q.special65_20 ? ' · ★ 65/20' : ''}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        if (c.record(q.id)?.favorite == true)
                          const Icon(Icons.star_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (visible.isNotEmpty)
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/study',
                arguments: StudyOptions(
                  questions: visible,
                  label: 'Filtered Study',
                ),
              ),
              child: const AppText('Study This Collection'),
            ),
        ],
      ),
    );
  }
}
