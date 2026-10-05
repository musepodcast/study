import 'dart:io';
import 'package:flutter/services.dart';
import 'package:civics_study/app/study_controller.dart';
import 'package:civics_study/repositories/content_repository.dart';
import 'package:civics_study/services/storage_service.dart';
import 'package:civics_study/services/speech_service.dart';

class FileBundle extends CachingAssetBundle {
  final Set<String> missing;
  FileBundle({this.missing = const {}});
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (missing.contains(key)) {
      throw const FormatException('Missing fixture');
    }
    return File(key).readAsString();
  }

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(await File(key).readAsBytes());
}

class MemoryStorage implements StorageService {
  String? value;
  bool failRead = false, failWrite = false;
  @override
  Future<String?> read() async {
    if (failRead) {
      throw StateError('Unavailable');
    }
    return value;
  }

  @override
  Future<void> write(String data) async {
    if (failWrite) {
      throw StateError('Unavailable');
    }
    value = data;
  }
}

class FakeSpeech implements SpeechService {
  bool available = true;
  String? lastText;
  bool? lastSlow;
  @override
  Future<bool> speak(
    String text, {
    bool slow = false,
    VoidCallback? onError,
  }) async {
    lastText = text;
    lastSlow = slow;
    return available;
  }

  @override
  Future<void> stop() async {}
}

Future<StudyController> createController({
  MemoryStorage? storage,
  FileBundle? bundle,
}) async {
  final controller = StudyController(
    repository: AssetContentRepository(bundle: bundle ?? FileBundle()),
    storage: storage ?? MemoryStorage(),
    speech: FakeSpeech(),
  );
  await controller.initialize();
  return controller;
}
