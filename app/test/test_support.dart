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

class FakeSpeech extends SpeechService {
  bool available = true;
  String? lastText;
  double? lastRate;
  @override
  Future<bool> speak(
    String text, {
    double rate = 1,
    VoidCallback? onError,
  }) async {
    lastText = text;
    lastRate = rate;
    updateState(available ? PlaybackState.playing : PlaybackState.idle);
    return available;
  }

  @override
  Future<void> stop() async => updateState(PlaybackState.idle);
  @override
  Future<bool> pause() async {
    updateState(PlaybackState.paused);
    return true;
  }

  @override
  Future<bool> resume() async {
    updateState(PlaybackState.playing);
    return true;
  }
}

Future<StudyController> createController({
  MemoryStorage? storage,
  FileBundle? bundle,
}) async {
  final controller = createUninitializedController(
    storage: storage,
    bundle: bundle,
  );
  await controller.initialize();
  return controller;
}

StudyController createUninitializedController({
  MemoryStorage? storage,
  FileBundle? bundle,
}) => StudyController(
  repository: AssetContentRepository(bundle: bundle ?? FileBundle()),
  storage: storage ?? MemoryStorage(),
  speech: FakeSpeech(),
);
