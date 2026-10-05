enum StudyStatus { studied, mastered, needsPractice }

class QuestionProgress {
  final StudyStatus status;
  final bool favorite;
  final int correct, incorrect;
  final DateTime? lastStudied;
  const QuestionProgress({
    this.status = StudyStatus.studied,
    this.favorite = false,
    this.correct = 0,
    this.incorrect = 0,
    this.lastStudied,
  });
  QuestionProgress copyWith({
    StudyStatus? status,
    bool? favorite,
    int? correct,
    int? incorrect,
    DateTime? lastStudied,
  }) => QuestionProgress(
    status: status ?? this.status,
    favorite: favorite ?? this.favorite,
    correct: correct ?? this.correct,
    incorrect: incorrect ?? this.incorrect,
    lastStudied: lastStudied ?? this.lastStudied,
  );
  Map<String, dynamic> toJson() => {
    'status': status.name,
    'favorite': favorite,
    'correct': correct,
    'incorrect': incorrect,
    'lastStudied': lastStudied?.toIso8601String(),
  };
  factory QuestionProgress.fromJson(Map<String, dynamic> j) => QuestionProgress(
    status: StudyStatus.values.byName(j['status']),
    favorite: j['favorite'],
    correct: j['correct'],
    incorrect: j['incorrect'],
    lastStudied: j['lastStudied'] == null
        ? null
        : DateTime.parse(j['lastStudied']),
  );
}

class TestResult {
  final DateTime date;
  final int correct, incorrect;
  final bool passed;
  const TestResult({
    required this.date,
    required this.correct,
    required this.incorrect,
    required this.passed,
  });
  int get asked => correct + incorrect;
  double get score => asked == 0 ? 0 : correct / asked;
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'correct': correct,
    'incorrect': incorrect,
    'passed': passed,
  };
  factory TestResult.fromJson(Map<String, dynamic> j) => TestResult(
    date: DateTime.parse(j['date']),
    correct: j['correct'],
    incorrect: j['incorrect'],
    passed: j['passed'],
  );
}

class ProgressData {
  final Map<String, QuestionProgress> questions;
  final List<TestResult> tests;
  ProgressData({
    Map<String, QuestionProgress>? questions,
    List<TestResult>? tests,
  }) : questions = questions ?? {},
       tests = tests ?? [];
  Map<String, dynamic> toJson() => {
    'version': 1,
    'questions': questions.map((k, v) => MapEntry(k, v.toJson())),
    'tests': tests.map((t) => t.toJson()).toList(),
  };
  factory ProgressData.fromJson(Map<String, dynamic> j) {
    if (j['version'] != 1) {
      throw const FormatException('Unsupported progress version');
    }
    return ProgressData(
      questions: (j['questions'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          k,
          QuestionProgress.fromJson(Map<String, dynamic>.from(v)),
        ),
      ),
      tests: (j['tests'] as List)
          .map((v) => TestResult.fromJson(Map<String, dynamic>.from(v)))
          .toList(),
    );
  }
}
