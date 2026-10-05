import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civics_study/models/progress.dart';
import 'package:civics_study/models/settings.dart';
import 'test_support.dart';

void main() {
  test(
    'interface defaults to Brazilian Portuguese and old settings migrate',
    () {
      expect(StudySettings().appLanguage, AppLanguage.portuguese);
      final old = StudySettings.fromJson({
        'theme': 'system',
        'language': 'onTap',
        'slowAudio': false,
      });
      expect(old.appLanguage, AppLanguage.portuguese);
      old.appLanguage = AppLanguage.english;
      expect(
        StudySettings.fromJson(old.toJson()).appLanguage,
        AppLanguage.english,
      );
    },
  );
  test(
    'progress, favorites, needs-practice, mastered, history, settings survive reload',
    () async {
      final storage = MemoryStorage(),
          c = await createController(storage: MemoryStorage());
      final first = c.content!.questions.first.id,
          second = c.content!.questions[1].id;
      c.markStudied(first, status: StudyStatus.mastered, correct: true);
      c.toggleFavorite(first);
      c.markStudied(second, status: StudyStatus.needsPractice, correct: false);
      c.addResult(
        TestResult(
          date: DateTime(2026, 10, 4),
          correct: 12,
          incorrect: 4,
          passed: true,
        ),
      );
      c.settings.theme = ThemeMode.dark;
      c.settings.language = StudyLanguage.bilingual;
      c.settings.slowAudio = true;
      c.save();
      await c.writesComplete;
      final encoded = jsonEncode({
        'progress': c.progress.toJson(),
        'settings': c.settings.toJson(),
      });
      storage.value = encoded;
      final reloaded = await createController(storage: storage);
      expect(reloaded.studied, 2);
      expect(reloaded.mastered, 1);
      expect(reloaded.needsPractice, 1);
      expect(reloaded.favorites, 1);
      expect(reloaded.record(first)!.correct, 1);
      expect(reloaded.record(second)!.incorrect, 1);
      expect(reloaded.progress.tests.single.asked, 16);
      expect(reloaded.progress.tests.single.score, .75);
      expect(reloaded.settings.theme, ThemeMode.dark);
      expect(reloaded.settings.language, StudyLanguage.bilingual);
      expect(reloaded.settings.slowAudio, true);
      reloaded.toggleFavorite(first);
      expect(reloaded.favorites, 0);
      reloaded.resetProgress();
      await reloaded.writesComplete;
      expect(reloaded.studied, 0);
      expect(reloaded.progress.tests, isEmpty);
      expect(reloaded.settings.theme, ThemeMode.dark);
      final afterReset = await createController(storage: storage);
      expect(afterReset.studied, 0);
    },
  );
  test(
    'storage read/write failure and corrupt storage degrade gracefully',
    () async {
      final storage = MemoryStorage()
        ..failRead = true
        ..failWrite = true;
      final c = await createController(storage: storage);
      expect(c.error, isNull);
      expect(c.storageWarning, isNotNull);
      c.markStudied(
        c.content!.questions.first.id,
        status: StudyStatus.mastered,
      );
      await c.writesComplete;
      expect(c.mastered, 1);
      expect(c.storageWarning, contains('could not be saved'));
      final corrupt = await createController(
        storage: MemoryStorage()..value = '{invalid',
      );
      expect(corrupt.storageWarning, isNotNull);
      expect(corrupt.content!.questions.length, 128);
    },
  );
  test('favoriting alone does not mark a question studied', () async {
    final c = await createController();
    c.toggleFavorite(c.content!.questions.first.id);
    expect(c.favorites, 1);
    expect(c.studied, 0);
  });
}
