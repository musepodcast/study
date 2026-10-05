import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';

class ContentData {
  final List<Question> questions;
  final Map<String, dynamic> location, currentAnswers;
  final List<Map<String, dynamic>> vocabulary;
  final List<String> warnings;
  final String source;
  ContentData({
    required this.questions,
    required this.location,
    required this.currentAnswers,
    required this.vocabulary,
    required this.warnings,
    required this.source,
  });
  String get locationLabel => location.isEmpty
      ? 'Location unavailable'
      : '${location['city']}, ${location['state']}';
  List<String> answers(Question q, {bool portuguese = false}) {
    if (q.dynamicType == 'stateCapital' && location['stateCapital'] is String) {
      return [location['stateCapital']];
    }
    final value = currentAnswers[q.dynamicType];
    if (q.isDynamic && value is Map) {
      return List<String>.from(value[portuguese ? 'portuguese' : 'english']);
    }
    return portuguese ? q.answersPortuguese : q.answersEnglish;
  }

  bool resolved(Question q) =>
      !q.isDynamic ||
      (q.dynamicType == 'stateCapital'
          ? location['stateCapital'] is String
          : currentAnswers.containsKey(q.dynamicType));
}

abstract class ContentRepository {
  Future<ContentData> load();
}

class AssetContentRepository implements ContentRepository {
  final AssetBundle bundle;
  AssetContentRepository({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;
  Future<dynamic> _read(String name) async =>
      jsonDecode(await bundle.loadString('assets/data/$name.json'));
  @override
  Future<ContentData> load() async {
    final data = await _read('civics_2025') as Map<String, dynamic>;
    final questions = (data['questions'] as List)
        .map((j) => Question.fromJson(Map<String, dynamic>.from(j)))
        .toList();
    if (questions.length != 128 ||
        questions.map((q) => q.id).toSet().length != 128 ||
        questions.map((q) => q.number).toSet().length != 128 ||
        questions.where((q) => q.special65_20).length != 20) {
      throw const FormatException(
        'Civics content must contain 128 unique questions and 20 special questions',
      );
    }
    questions.sort((a, b) => a.number.compareTo(b.number));
    final warnings = <String>[];
    Future<Map<String, dynamic>> optional(String file) async {
      try {
        return Map<String, dynamic>.from(await _read(file));
      } catch (e) {
        debugPrint('Content $file: $e');
        warnings.add(
          '$file could not be loaded. Verify current answers before your interview.',
        );
        return {};
      }
    }

    final location = await optional('location_profile');
    final dynamicData = await optional('dynamic_answers');
    final current = <String, dynamic>{};
    final entries = dynamicData['answers'];
    if (entries is Map) {
      for (final key in entries.keys) {
        final v = entries[key];
        if (v is Map &&
            v['english'] is List &&
            v['portuguese'] is List &&
            (v['english'] as List).isNotEmpty &&
            (v['english'] as List).length == (v['portuguese'] as List).length &&
            [
              ...v['english'],
              ...v['portuguese'],
            ].every((a) => a is String && a.trim().isNotEmpty)) {
          current[key.toString()] = v;
        } else {
          warnings.add('A current answer is unavailable ($key).');
        }
      }
    }
    List<Map<String, dynamic>> vocabulary = [];
    try {
      vocabulary = (await _read('vocabulary_pt') as List)
          .map((v) => Map<String, dynamic>.from(v))
          .toList();
    } catch (e) {
      debugPrint('Vocabulary: $e');
      warnings.add('Vocabulary help is unavailable.');
    }
    return ContentData(
      questions: questions,
      location: location,
      currentAnswers: current,
      vocabulary: vocabulary,
      warnings: warnings,
      source: data['source'],
    );
  }
}
