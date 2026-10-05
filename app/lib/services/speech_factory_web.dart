import 'speech_service.dart';
import 'web_speech_service.dart';

SpeechService createPlatformSpeech() => WebSpeechService();
