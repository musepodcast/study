import 'package:flutter/material.dart';
import 'app/civics_app.dart';
import 'app/study_controller.dart';
import 'repositories/content_repository.dart';
import 'services/storage_service.dart';
import 'services/speech_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = StudyController(
    repository: AssetContentRepository(),
    storage: PreferencesStorage(),
    speech: createSpeechService(),
  );
  runApp(CivicsApp(controller: controller));
  controller.initialize();
}
