import 'dart:math';
import '../models/question.dart';

enum TestOutcome { inProgress, passed, notPassed }

class TestSession {
  static const maxQuestions = 20;
  static const requiredCorrect = 12;
  final List<Question> questions;
  int correct = 0, incorrect = 0;
  TestSession(List<Question> pool, {Random? random})
    : questions = _select(pool, random) {
    if (pool.length != 128 || pool.map((q) => q.id).toSet().length != 128) {
      throw ArgumentError('Official simulation requires 128 unique questions');
    }
  }
  static List<Question> _select(List<Question> pool, Random? random) {
    final shuffled = List<Question>.of(pool)..shuffle(random ?? Random());
    return List.unmodifiable(shuffled.take(maxQuestions));
  }

  int get asked => correct + incorrect;
  int get remaining => maxQuestions - asked;
  TestOutcome get outcome {
    if (correct >= requiredCorrect) {
      return TestOutcome.passed;
    }
    if (correct + remaining < requiredCorrect) {
      return TestOutcome.notPassed;
    }
    return TestOutcome.inProgress;
  }

  Question get current {
    if (outcome != TestOutcome.inProgress) {
      throw StateError('Test is finished');
    }
    return questions[asked];
  }

  void grade(bool wasCorrect) {
    if (outcome != TestOutcome.inProgress) {
      throw StateError('Test is finished');
    }
    if (wasCorrect) {
      correct++;
    } else {
      incorrect++;
    }
  }
}
