import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civics_study/app/civics_app.dart';
import 'package:civics_study/models/settings.dart';
import 'package:civics_study/widgets/study_card.dart';
import 'package:civics_study/widgets/pronounceable_text.dart';
import 'test_support.dart';

void main() {
  testWidgets(
    'hidden study question supports audio and independent answer reveal; next resets text and help',
    (tester) async {
      final c = createUninitializedController();
      await tester.runAsync(c.initialize);
      c.settings.appLanguage = AppLanguage.english;
      c.settings.language = StudyLanguage.bilingual;
      await tester.pumpWidget(CivicsApp(controller: c));
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.byType(NavigationBar)),
      ).pushNamed('/study');
      await tester.pumpAndSettle();
      final q = c.content!.questions.first;
      expect(find.text(q.questionEnglish), findsNothing);
      expect(find.text(q.questionPortuguese), findsNothing);
      expect(find.byType(PronounceableText), findsNothing);
      expect(find.text('Vocabulary · tap for Portuguese help'), findsNothing);
      await tester.tap(find.text('Play Question'));
      await tester.pumpAndSettle();
      expect((c.speech as FakeSpeech).lastText, q.questionEnglish);
      expect(find.text(q.questionEnglish), findsNothing);
      await tester.tap(find.text('Reveal Question'));
      await tester.pumpAndSettle();
      expect(find.text(q.questionEnglish), findsOneWidget);
      expect(find.text(q.questionPortuguese), findsOneWidget);
      expect(c.studied, 0);
      await tester.tap(find.text('Hide Question'));
      await tester.pumpAndSettle();
      expect(find.text(q.questionEnglish), findsNothing);
      expect(find.text(q.questionPortuguese), findsNothing);
      await tester.ensureVisible(find.text('Reveal Answer'));
      await tester.tap(find.text('Reveal Answer'));
      await tester.pumpAndSettle();
      expect(find.text(q.questionEnglish), findsNothing);
      expect(find.text('• ${c.content!.answers(q).first}'), findsOneWidget);
      expect(c.studied, 1);
      await tester.ensureVisible(find.text('Reveal Question'));
      await tester.tap(find.text('Reveal Question'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Next'));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Reveal Question'), findsOneWidget);
      expect(find.text(c.content!.questions[1].questionEnglish), findsNothing);
      expect(
        find.text(c.content!.questions[1].questionPortuguese),
        findsNothing,
      );
      expect(find.byType(PronounceableText), findsNothing);
    },
  );

  testWidgets(
    'official simulation reveals question independently and hides the next one after grading',
    (tester) async {
      final c = createUninitializedController();
      await tester.runAsync(c.initialize);
      c.settings.appLanguage = AppLanguage.english;
      await tester.pumpWidget(CivicsApp(controller: c));
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.byType(NavigationBar)),
      ).pushNamed('/test');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Start Official Simulation'));
      await tester.tap(find.text('Start Official Simulation'));
      await tester.pumpAndSettle();
      final q = tester.widget<StudyCard>(find.byType(StudyCard)).question;
      expect(find.text(q.questionEnglish), findsNothing);
      expect(find.byType(PronounceableText), findsNothing);
      await tester.ensureVisible(find.text('Reveal Question'));
      await tester.tap(find.text('Reveal Question'));
      await tester.pumpAndSettle();
      expect(find.text(q.questionEnglish), findsOneWidget);
      expect(find.text(q.questionPortuguese), findsNothing);
      expect(find.text('Correct'), findsNothing);
      await tester.ensureVisible(find.text('Show Answer'));
      await tester.tap(find.text('Show Answer'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Correct'));
      await tester.tap(find.text('Correct'));
      await tester.pumpAndSettle();
      final next = tester.widget<StudyCard>(find.byType(StudyCard)).question;
      expect(next.id, isNot(q.id));
      expect(find.text(next.questionEnglish), findsNothing);
      expect(find.byType(PronounceableText), findsNothing);
      expect(find.text('Reveal Question'), findsOneWidget);
      expect(find.text('1 correct'), findsOneWidget);
    },
  );
}
