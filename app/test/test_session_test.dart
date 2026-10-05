import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:civics_study/core/test_session.dart';
import 'package:civics_study/models/question.dart';
import 'package:civics_study/repositories/content_repository.dart';
import 'test_support.dart';

void main() {
  late List<Question> pool;
  setUpAll(() async {
    pool = (await AssetContentRepository(
      bundle: FileBundle(),
    ).load()).questions;
  });
  test('official random selection uses full pool without duplicates', () {
    final seen = <String>{};
    for (var seed = 0; seed < 100; seed++) {
      final s = TestSession(pool, random: Random(seed));
      expect(s.questions.length, 20);
      expect(s.questions.map((q) => q.id).toSet().length, 20);
      expect(s.questions.every((q) => pool.contains(q)), true);
      seen.addAll(s.questions.map((q) => q.id));
    }
    expect(seen.length, 128);
    expect(() => TestSession(pool.take(20).toList()), throwsArgumentError);
  });
  test('pass immediately at 12 and reject grading after completion', () {
    final s = TestSession(pool);
    for (var i = 0; i < 11; i++) {
      s.grade(true);
      expect(s.outcome, TestOutcome.inProgress);
    }
    s.grade(true);
    expect(s.outcome, TestOutcome.passed);
    expect(s.asked, 12);
    expect(() => s.grade(false), throwsStateError);
    expect(() => s.current, throwsStateError);
  });
  test('fail immediately on ninth miss, including 8 correct / 9 incorrect', () {
    final s = TestSession(pool);
    for (var i = 0; i < 8; i++) {
      s.grade(true);
    }
    for (var i = 0; i < 8; i++) {
      s.grade(false);
      expect(s.outcome, TestOutcome.inProgress);
    }
    s.grade(false);
    expect(s.outcome, TestOutcome.notPassed);
    expect(s.asked, 17);
    expect(s.remaining, 3);
    final allWrong = TestSession(pool);
    for (var i = 0; i < 9; i++) {
      allWrong.grade(false);
    }
    expect(allWrong.asked, 9);
    expect(allWrong.outcome, TestOutcome.notPassed);
  });
  test(
    '20 is the hard maximum; outcome determined at final possible answer',
    () {
      final s = TestSession(pool);
      for (var i = 0; i < 8; i++) {
        s.grade(false);
      }
      for (var i = 0; i < 11; i++) {
        s.grade(true);
      }
      expect(s.asked, 19);
      expect(s.outcome, TestOutcome.inProgress);
      s.grade(true);
      expect(s.asked, 20);
      expect(s.outcome, TestOutcome.passed);
      for (var seed = 0; seed < 200; seed++) {
        final random = Random(seed), run = TestSession(pool);
        while (run.outcome == TestOutcome.inProgress) {
          run.grade(random.nextBool());
        }
        expect(run.asked, lessThanOrEqualTo(20));
        expect(run.outcome == TestOutcome.passed, run.correct >= 12);
      }
    },
  );
}
