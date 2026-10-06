import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/foundation.dart';
import 'speech_service.dart';

@JS('speechSynthesis')
external BrowserSpeechSynthesis get browserSpeech;

extension type BrowserSpeechSynthesis._(JSObject _) implements JSObject {
  external JSArray<BrowserVoice> getVoices();
  external void speak(BrowserUtterance utterance);
  external void cancel();
  external void pause();
  external void resume();
}

@JS('SpeechSynthesisUtterance')
extension type BrowserUtterance._(JSObject _) implements JSObject {
  external BrowserUtterance(String text);
  external set lang(String value);
  external set rate(double value);
  external set volume(double value);
  external set voice(BrowserVoice value);
  external set onerror(JSFunction? value);
  external set onend(JSFunction? value);
}

extension type BrowserVoice._(JSObject _) implements JSObject {
  external String get lang;
  external bool get localService;
}

extension type BrowserSpeechError._(JSObject _) implements JSObject {
  external String get error;
}

/// Keep browser playback inside the button's user gesture. A fresh utterance
/// avoids reused-utterance failures; cancellation is an expected control action.
class WebSpeechService extends SpeechService {
  BrowserUtterance? _active;
  int _generation = 0;

  bool get _supported =>
      globalContext.hasProperty('speechSynthesis'.toJS).toDart &&
      globalContext.hasProperty('SpeechSynthesisUtterance'.toJS).toDart;

  void _cancel() {
    _generation++;
    _active?.onerror = null;
    _active?.onend = null;
    _active = null;
    browserSpeech.cancel();
  }

  @override
  Future<bool> speak(String text, {double rate = 1, VoidCallback? onError}) {
    try {
      if (!_supported || text.trim().isEmpty) {
        return Future.value(false);
      }
      _cancel();
      final generation = _generation;
      final utterance = BrowserUtterance(text);
      _active = utterance;
      // Voices may still be loading on the first tap. Always set English even
      // when getVoices() is empty; the browser can choose its own English voice.
      utterance.lang = 'en-US';
      utterance.rate = rate;
      utterance.volume = 1.0;
      try {
        final voices = browserSpeech.getVoices().toDart;
        final us = voices.where(
          (v) => v.lang.replaceAll('_', '-').toLowerCase() == 'en-us',
        );
        final local = us.where((v) => v.localService);
        if (local.isNotEmpty) {
          utterance.voice = local.first;
        } else if (us.isNotEmpty) {
          utterance.voice = us.first;
        } else {
          final english = voices.where(
            (v) => v.lang.toLowerCase().startsWith('en'),
          );
          if (english.isNotEmpty) {
            utterance.voice = english.first;
          }
        }
      } catch (e) {
        debugPrint('Using browser-selected English voice: $e');
      }
      utterance.onerror = ((BrowserSpeechError event) {
        if (generation != _generation) {
          return;
        }
        if (event.error == 'canceled' || event.error == 'interrupted') {
          return;
        }
        debugPrint('Browser speech failed: ${event.error}');
        _active = null;
        updateState(PlaybackState.idle);
        onError?.call();
      }).toJS;
      utterance.onend = ((JSObject event) {
        if (generation == _generation) {
          _active = null;
          updateState(PlaybackState.idle);
        }
      }).toJS;
      // No awaited plugin/configuration calls before speak: preserve activation.
      browserSpeech.speak(utterance);
      browserSpeech.resume();
      updateState(PlaybackState.playing);
      return Future.value(true);
    } catch (e) {
      debugPrint('Browser speech unavailable: $e');
      _active = null;
      updateState(PlaybackState.idle);
      return Future.value(false);
    }
  }

  @override
  Future<bool> pause() {
    try {
      if (!_supported || state != PlaybackState.playing) {
        return Future.value(false);
      }
      browserSpeech.pause();
      updateState(PlaybackState.paused);
      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> resume() {
    try {
      if (!_supported || state != PlaybackState.paused) {
        return Future.value(false);
      }
      browserSpeech.resume();
      updateState(PlaybackState.playing);
      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  }

  @override
  Future<void> stop() {
    updateState(PlaybackState.idle);
    try {
      if (_supported) {
        _cancel();
      }
    } catch (e) {
      debugPrint('Browser speech stop: $e');
    }
    return Future.value();
  }
}
