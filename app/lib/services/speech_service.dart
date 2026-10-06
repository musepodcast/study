import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'speech_factory_stub.dart'
    if (dart.library.js_interop) 'speech_factory_web.dart'
    as platform;

SpeechService createSpeechService() => platform.createPlatformSpeech();

enum PlaybackState { idle, playing, paused }

abstract class SpeechService extends ChangeNotifier {
  PlaybackState state = PlaybackState.idle;
  void updateState(PlaybackState value) {
    state = value;
    notifyListeners();
  }

  Future<bool> speak(String text, {double rate = 1, VoidCallback? onError});
  Future<bool> pause();
  Future<bool> resume();
  Future<void> stop();
}

class DeviceSpeechService extends SpeechService {
  FlutterTts? _engine;
  bool _configured = false;
  String _text = '';
  int _generation = 0;
  @override
  Future<bool> speak(
    String text, {
    double rate = 1,
    VoidCallback? onError,
  }) async {
    final generation = ++_generation;
    updateState(PlaybackState.playing);
    try {
      final engine = _engine ??= FlutterTts();
      engine.setCompletionHandler(() {
        if (generation == _generation) updateState(PlaybackState.idle);
      });
      engine.setErrorHandler((message) {
        if (generation != _generation) return;
        final reason = message.toString().toLowerCase();
        if (reason.contains('canceled') ||
            reason.contains('cancelled') ||
            reason.contains('interrupted')) {
          return;
        }
        debugPrint('Speech engine: $message');
        updateState(PlaybackState.idle);
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
      if (generation != _generation) return true;
      await engine.stop();
      if (generation != _generation) return true;
      _text = text;
      await engine.setSpeechRate((rate * 0.5).clamp(0.0, 1.0));
      if (generation != _generation) return true;
      updateState(PlaybackState.playing);
      final result = await engine.speak(text);
      if (generation != _generation) return true;
      if (result == 0) updateState(PlaybackState.idle);
      return result != 0;
    } catch (e) {
      if (generation != _generation) return true;
      debugPrint('Speech unavailable: $e');
      updateState(PlaybackState.idle);
      return false;
    }
  }

  @override
  Future<bool> pause() async {
    if (state != PlaybackState.playing) return false;
    try {
      final generation = _generation;
      final result = await _engine?.pause();
      if (generation != _generation) return true;
      if (result == 0) return false;
      updateState(PlaybackState.paused);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> resume() async {
    if (state != PlaybackState.paused) return false;
    try {
      final generation = _generation;
      final result = await _engine?.speak(_text);
      if (generation != _generation) return true;
      if (result == 0) return false;
      updateState(PlaybackState.playing);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> stop() async {
    _generation++;
    updateState(PlaybackState.idle);
    try {
      await _engine?.stop();
    } catch (e) {
      debugPrint('Speech stop: $e');
    }
  }
}
