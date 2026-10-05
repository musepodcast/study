class Question {
  final String id, questionEnglish, questionPortuguese, category;
  final int number;
  final List<String> answersEnglish, answersPortuguese, vocabulary;
  final bool isDynamic, special65_20;
  final String? dynamicType, notes, studyTip;

  const Question({
    required this.id,
    required this.number,
    required this.questionEnglish,
    required this.questionPortuguese,
    required this.answersEnglish,
    required this.answersPortuguese,
    required this.category,
    required this.isDynamic,
    required this.special65_20,
    required this.vocabulary,
    this.dynamicType,
    this.notes,
    this.studyTip,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    String text(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing question field: $key');
      }
      return value;
    }

    List<String> list(String key, {bool allowEmpty = false}) {
      final value = json[key];
      if (value is! List ||
          (!allowEmpty && value.isEmpty) ||
          value.any((v) => v is! String || v.trim().isEmpty)) {
        throw FormatException('Invalid question list: $key');
      }
      return List<String>.from(value);
    }

    if (json['number'] is! int ||
        json['number'] < 1 ||
        json['number'] > 128 ||
        json['dynamic'] is! bool ||
        json['special65_20'] is! bool) {
      throw const FormatException('Invalid question number or flags');
    }
    final english = list('answersEnglish');
    final portuguese = list('answersPortuguese');
    if (english.length != portuguese.length ||
        (json['dynamic'] == true && json['dynamicType'] is! String)) {
      throw const FormatException('Translation or dynamic metadata mismatch');
    }
    return Question(
      id: text('id'),
      number: json['number'],
      questionEnglish: text('questionEnglish'),
      questionPortuguese: text('questionPortuguese'),
      answersEnglish: english,
      answersPortuguese: portuguese,
      category: text('category'),
      isDynamic: json['dynamic'],
      special65_20: json['special65_20'],
      vocabulary: list('vocabulary', allowEmpty: true),
      dynamicType: json['dynamicType'],
      notes: json['notes'],
      studyTip: json['studyTip'],
    );
  }

  bool get locationDependent => const [
    'senators',
    'representative',
    'governor',
    'stateCapital',
  ].contains(dynamicType);
}
