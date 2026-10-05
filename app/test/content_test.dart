import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:civics_study/models/question.dart';
import 'package:civics_study/repositories/content_repository.dart';
import 'test_support.dart';

void main() {
  test('missing civics data produces a recoverable loading error', () async {
    final missing = <String>{'assets/data/civics_2025.json'};
    final c = await createController(bundle: FileBundle(missing: missing));
    expect(c.error, isNotNull);
    expect(c.loading, false);
    missing.clear();
    await c.initialize();
    expect(c.error, isNull);
    expect(c.content!.questions.length, 128);
  });
  test(
    '128 unique official questions with full translations and 20 starred questions',
    () async {
      final content = await AssetContentRepository(bundle: FileBundle()).load();
      expect(content.questions.length, 128);
      expect(content.questions.map((q) => q.id).toSet().length, 128);
      expect(
        content.questions.map((q) => q.number).toSet(),
        List.generate(128, (i) => i + 1).toSet(),
      );
      expect(
        content.questions
            .where((q) => q.special65_20)
            .map((q) => q.number)
            .toList(),
        [
          2,
          7,
          12,
          20,
          30,
          36,
          38,
          39,
          44,
          52,
          61,
          66,
          74,
          78,
          86,
          94,
          113,
          115,
          121,
          126,
        ],
      );
      for (final q in content.questions) {
        expect(q.questionEnglish, isNotEmpty);
        expect(q.answersEnglish, isNotEmpty);
        expect(q.questionPortuguese, isNotEmpty);
        expect(q.answersPortuguese.length, q.answersEnglish.length);
        expect(q.answersPortuguese.every((a) => a.trim().isNotEmpty), true);
      }
      expect(
        content.questions.first.questionEnglish,
        'What is the form of government of the United States?',
      );
      expect(content.questions.first.answersEnglish, [
        'Republic',
        'Constitution-based federal republic',
        'Representative democracy',
      ]);
    },
  );
  test('malformed records fail parsing', () {
    final j =
        (jsonDecode(
                  File('assets/data/civics_2025.json').readAsStringSync(),
                )['questions'][0]
                as Map)
            .cast<String, dynamic>();
    for (final key in [
      'number',
      'id',
      'questionEnglish',
      'answersEnglish',
      'questionPortuguese',
      'answersPortuguese',
      'special65_20',
      'dynamic',
      'vocabulary',
    ]) {
      final broken = Map<String, dynamic>.of(j)..remove(key);
      expect(
        () => Question.fromJson(broken),
        throwsFormatException,
        reason: key,
      );
    }
    expect(
      () => Question.fromJson({
        ...j,
        'answersPortuguese': ['One'],
      }),
      throwsFormatException,
    );
  });
  test(
    'Pensacola profile and verified dynamic answers resolve separately',
    () async {
      final c = await AssetContentRepository(bundle: FileBundle()).load();
      expect(c.locationLabel, 'Pensacola, Florida');
      expect(c.location['county'], 'Escambia County');
      expect(c.location['stateCode'], 'FL');
      expect(
        c.location['congressionalDistrict'],
        "Florida's 1st Congressional District",
      );
      final expected = {
        23: ['Rick Scott', 'Ashley Moody'],
        29: ['Jimmy Patronis'],
        30: ['Mike Johnson'],
        38: ['Donald J. Trump'],
        39: ['JD Vance'],
        57: ['John G. Roberts, Jr.'],
        61: ['Ron DeSantis'],
        62: ['Tallahassee'],
      };
      for (final e in expected.entries) {
        final q = c.questions[e.key - 1];
        expect(c.answers(q), e.value);
        expect(c.answers(q, portuguese: true), e.value);
        expect(c.resolved(q), true);
        expect(
          q.answersEnglish,
          isNot(e.value),
          reason: 'Official guidance preserved',
        );
      }
      expect(c.warnings, isEmpty);
    },
  );
  test(
    'missing dynamic and location data leave official guidance and warnings',
    () async {
      final c = await AssetContentRepository(
        bundle: FileBundle(
          missing: {
            'assets/data/dynamic_answers.json',
            'assets/data/location_profile.json',
          },
        ),
      ).load();
      final q = c.questions[28];
      expect(c.questions.length, 128);
      expect(c.warnings.length, 2);
      expect(c.resolved(q), false);
      expect(c.answers(q), q.answersEnglish);
    },
  );
}
