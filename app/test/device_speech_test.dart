import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civics_study/services/speech_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_tts');
  final calls = <MethodCall>[];
  Completer<void>? configuring;
  setUp(() {
    calls.clear();
    configuring = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'setLanguage' && configuring != null) {
            await configuring!.future;
          }
          if (call.method == 'getVoices') return <dynamic>[];
          return 1;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
  test(
    'native adapter maps speed, pauses and resumes through plugin, then stops',
    () async {
      final service = DeviceSpeechService();
      expect(await service.speak('Constitution', rate: 1.5), true);
      expect(
        calls.firstWhere((c) => c.method == 'setSpeechRate').arguments,
        0.75,
      );
      expect(service.state, PlaybackState.playing);
      expect(await service.pause(), true);
      expect(service.state, PlaybackState.paused);
      expect(await service.resume(), true);
      expect(calls.where((c) => c.method == 'speak').length, 2);
      expect(service.state, PlaybackState.playing);
      await service.stop();
      expect(service.state, PlaybackState.idle);
    },
  );
  test('stop while configuring prevents delayed native playback', () async {
    configuring = Completer<void>();
    final service = DeviceSpeechService();
    final playback = service.speak('Do not play after stop');
    await Future<void>.delayed(Duration.zero);
    await service.stop();
    configuring!.complete();
    await playback;
    expect(calls.where((c) => c.method == 'speak'), isEmpty);
    expect(service.state, PlaybackState.idle);
  });
}
