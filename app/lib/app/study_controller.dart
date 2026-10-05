import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/progress.dart';
import '../models/settings.dart';
import '../repositories/content_repository.dart';
import '../services/storage_service.dart';
import '../services/speech_service.dart';

class StudyController extends ChangeNotifier {
  final ContentRepository repository;
  final StorageService storage;
  final SpeechService speech;
  ContentData? content;
  ProgressData progress = ProgressData();
  StudySettings settings = StudySettings();
  String? error, storageWarning;
  bool loading = true;
  Future<void> _writes = Future.value();
  StudyController({
    required this.repository,
    required this.storage,
    required this.speech,
  });
  Future<void> initialize() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      content = await repository.load();
    } catch (e) {
      debugPrint('Civics loading: $e');
      error =
          'The civics content could not be loaded. Please reload or try again.';
    }
    try {
      final raw = await storage.read();
      if (raw != null) {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        progress = ProgressData.fromJson(
          Map<String, dynamic>.from(j['progress']),
        );
        settings = StudySettings.fromJson(
          Map<String, dynamic>.from(j['settings']),
        );
      }
    } catch (e) {
      debugPrint('Storage loading: $e');
      storageWarning =
          'Saved data is unavailable. You can study in this session; changes may not persist.';
    }
    loading = false;
    notifyListeners();
  }

  QuestionProgress? record(String id) => progress.questions[id];
  int get studied =>
      progress.questions.values.where((p) => p.lastStudied != null).length;
  int get mastered => progress.questions.values
      .where((p) => p.status == StudyStatus.mastered)
      .length;
  int get needsPractice => progress.questions.values
      .where((p) => p.status == StudyStatus.needsPractice)
      .length;
  int get favorites =>
      progress.questions.values.where((p) => p.favorite).length;
  void markStudied(String id, {StudyStatus? status, bool? correct}) {
    final old = record(id) ?? const QuestionProgress();
    progress.questions[id] = old.copyWith(
      status: status,
      lastStudied: DateTime.now(),
      correct: old.correct + (correct == true ? 1 : 0),
      incorrect: old.incorrect + (correct == false ? 1 : 0),
    );
    save();
  }

  void toggleFavorite(String id) {
    final old = record(id) ?? const QuestionProgress();
    progress.questions[id] = old.copyWith(favorite: !old.favorite);
    save();
  }

  void addResult(TestResult result) {
    progress.tests.insert(0, result);
    save();
  }

  void resetProgress() {
    progress = ProgressData();
    save();
  }

  void save() {
    final snapshot = jsonEncode({
      'progress': progress.toJson(),
      'settings': settings.toJson(),
    });
    _writes = _writes.then((_) async {
      try {
        await storage.write(snapshot);
      } catch (e) {
        debugPrint('Storage saving: $e');
        storageWarning =
            'Progress could not be saved. Your changes remain available in this session.';
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<void> get writesComplete => _writes;
  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }
}
