import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civics_study/app/civics_app.dart';
import 'package:civics_study/models/settings.dart';
import 'package:civics_study/services/speech_service.dart';
import 'test_support.dart';

void main() {
  testWidgets(
    'word pronunciation, speed, pause, resume, stop and undo controls',
    (tester) async {
      final c = createUninitializedController();
      await tester.runAsync(c.initialize);
      c.settings.appLanguage = AppLanguage.english;
      await tester.pumpWidget(CivicsApp(controller: c));
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.byType(NavigationBar)),
      ).pushNamed('/study');
      await tester.pumpAndSettle();
      final speech = c.speech as FakeSpeech;
      final sentence = c.content!.questions.first.questionEnglish;
      expect(find.text(sentence), findsNothing);
      await tester.tap(find.text('Play Question'));
      await tester.pumpAndSettle();
      expect(speech.lastText, sentence);
      expect(find.text(sentence), findsNothing);
      await tester.tap(find.text('Reveal Question'));
      await tester.pumpAndSettle();
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.text(sentence),
          matching: find.byType(RichText),
        ),
      );
      final start = sentence.indexOf('government');
      final box = paragraph
          .getBoxesForSelection(
            TextSelection(baseOffset: start, extentOffset: start + 10),
          )
          .first;
      await tester.tapAt(paragraph.localToGlobal(box.toRect().center));
      await tester.pumpAndSettle();
      expect(speech.lastText, 'government');
      expect(speech.lastRate, 1);
      await tester.ensureVisible(find.text('Pause Audio'));
      await tester.tap(find.text('Pause Audio'));
      await tester.pumpAndSettle();
      expect(speech.state, PlaybackState.paused);
      await tester.ensureVisible(find.text('Resume Audio'));
      await tester.tap(find.text('Resume Audio'));
      await tester.pumpAndSettle();
      expect(speech.state, PlaybackState.playing);
      await tester.ensureVisible(find.text('Stop Audio'));
      await tester.tap(find.text('Stop Audio'));
      await tester.pumpAndSettle();
      expect(speech.state, PlaybackState.idle);
      await tester.ensureVisible(find.byType(DropdownButtonFormField<double>));
      await tester.tap(find.byType(DropdownButtonFormField<double>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0.5×').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Play Question'));
      await tester.tap(find.text('Play Question'));
      await tester.pumpAndSettle();
      expect(speech.lastText, sentence);
      expect(speech.lastRate, 0.5);
      await tester.ensureVisible(find.text('Reveal Answer'));
      await tester.tap(find.text('Reveal Answer'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Hear Answer'));
      await tester.tap(find.text('Hear Answer'));
      await tester.pumpAndSettle();
      expect(
        speech.lastText,
        c.content!.answers(c.content!.questions.first).join('. '),
      );
      for (final labels in [
        ('Know It', 'Undo Know It'),
        ('Needs Practice', 'Undo Needs Practice'),
        ('Favorite', 'Remove Favorite'),
      ]) {
        await tester.ensureVisible(find.text(labels.$1));
        await tester.tap(find.text(labels.$1));
        await tester.pumpAndSettle();
        await tester.tap(find.text(labels.$2));
        await tester.pumpAndSettle();
      }
      expect(c.mastered, 0);
      expect(c.needsPractice, 0);
      expect(c.favorites, 0);
      speech.updateState(PlaybackState.idle);
      await tester.pumpAndSettle();
      expect(find.text('Pause Audio'), findsNothing);
    },
  );
}
