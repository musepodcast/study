import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'speech_factory_stub.dart'
    if (dart.library.js_interop) 'speech_factory_web.dart'
    as platform;

SpeechService createSpeechService() => platform.createPlatformSpeech();

abstract class SpeechService {
  Future<bool> speak(String text, {bool slow = false, VoidCallback? onError});
  Future<void> stop();
}

class DeviceSpeechService implements SpeechService {
  FlutterTts? _engine;
  bool _configured = false;
  @override
  Future<bool> speak(
    String text, {
    bool slow = false,
    VoidCallback? onError,
  }) async {
    try {
      final engine = _engine ??= FlutterTts();
      engine.setErrorHandler((message) {
        final reason = message.toString().toLowerCase();
        if (reason.contains('canceled') ||
            reason.contains('cancelled') ||
            reason.contains('interrupted')) {
          return;
        }
        debugPrint('Speech engine: $message');
        onError?.call();
      });
      if (!_configured) {
        await engine.setLanguage('en-US');
        try {
          final voices = await engine.getVoices;
          if (voices is List) {
            final us = voices.where(
              (v) =>
                  v is Map &&
                  v['locale'] == 'en-US' &&
                  v['network_required'].toString() != 'true',
            );
            if (us.isNotEmpty) {
              await engine.setVoice({
                'name': us.first['name'].toString(),
                'locale': 'en-US',
              });
            }
          }
        } catch (e) {
          debugPrint('Using default English voice: $e');
        }
        _configured = true;
      }
      await engine.stop();
      await engine.setSpeechRate(slow ? 0.32 : 0.5);
      final result = await engine.speak(text);
      return result != 0;
    } catch (e) {
      debugPrint('Speech unavailable: $e');
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _engine?.stop();
    } catch (e) {
      debugPrint('Speech stop: $e');
    }
  }
}
