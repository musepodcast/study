import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civics_study/app/civics_app.dart';
import 'package:civics_study/app/study_controller.dart';
import 'package:civics_study/models/settings.dart';
import 'package:civics_study/models/progress.dart';
import 'package:civics_study/screens/study/study_screen.dart';
import 'package:civics_study/screens/practice_test/practice_test_screen.dart';
import 'package:civics_study/screens/home/home_screen.dart';
import 'package:civics_study/screens/questions/questions_screen.dart';
import 'package:civics_study/screens/progress/progress_screen.dart';
import 'package:civics_study/screens/settings/settings_screen.dart';
import 'package:civics_study/theme/app_theme.dart';
import 'test_support.dart';

void main() {
  testWidgets(
    'Portuguese interface defaults, English questions, and persistent English switch',
    (tester) async {
      final storage = MemoryStorage();
      final c = createUninitializedController(storage: storage);
      await tester.runAsync(c.initialize);
      await tester.pumpWidget(CivicsApp(controller: c));
      await tester.pumpAndSettle();
      expect(find.text('Estudo Cívico dos EUA'), findsOneWidget);
      expect(find.text('Teste de Cidadania 2025'), findsOneWidget);
      Navigator.of(
        tester.element(find.byType(NavigationBar)),
      ).pushNamed('/study');
      await tester.pumpAndSettle();
      expect(
        find.text('What is the form of government of the United States?'),
        findsOneWidget,
      );
      expect(find.text('Revelar resposta'), findsOneWidget);
      Navigator.of(
        tester.element(find.byType(NavigationBar)),
      ).pushNamed('/settings');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<AppLanguage>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inglês').last);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(c.settings.appLanguage, AppLanguage.english);
      await c.writesComplete;
      final restored = (await tester.runAsync(
        () => createController(storage: storage),
      ))!;
      expect(restored.settings.appLanguage, AppLanguage.english);
    },
  );
  testWidgets('Portuguese screens fit 360px with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = (await tester.runAsync(createController))!;
    await tester.pumpWidget(CivicsApp(controller: c));
    await tester.pumpAndSettle();
    for (final route in [
      '/study',
      '/test',
      '/questions',
      '/progress',
      '/settings',
    ]) {
      Navigator.of(
        tester.element(find.byType(NavigationBar)),
      ).pushReplacementNamed(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
    }
  });
  Future<StudyController> fixture(WidgetTester tester) async {
    final controller = (await tester.runAsync(createController))!;
    controller.settings.appLanguage = AppLanguage.english;
    return controller;
  }

  Future<void> screen(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(theme: civicsTheme(Brightness.light), home: child),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('application startup and named-route navigation', (tester) async {
    final c = await fixture(tester);
    await tester.pumpWidget(CivicsApp(controller: c));
    await tester.pumpAndSettle();
    expect(find.text('U.S. Civics Study'), findsOneWidget);
    expect(find.text('2025 Citizenship Test'), findsOneWidget);
    final context = tester.element(find.text('U.S. Civics Study'));
    Navigator.pushNamed(context, '/question/23');
    await tester.pumpAndSettle();
    expect(find.text('QUESTION 23 OF 128'), findsOneWidget);
    await tester.ensureVisible(find.text('Reveal Answer'));
    await tester.tap(find.text('Reveal Answer'));
    await tester.pumpAndSettle();
    expect(find.text('• Rick Scott'), findsOneWidget);
    expect(find.text('• Ashley Moody'), findsOneWidget);
    expect(
      find.text('Answer for your configured location: Pensacola, Florida'),
      findsOneWidget,
    );
  });
  testWidgets(
    'study card reveal, Portuguese tap, vocabulary, and persistence controls',
    (tester) async {
      final c = await fixture(tester);
      await screen(
        tester,
        StudyScreen(controller: c, options: const StudyOptions(start: 1)),
      );
      expect(find.text('What is the supreme law of the land?'), findsOneWidget);
      expect(find.text('Qual é a lei suprema do país?'), findsNothing);
      await tester.tap(find.text('Portuguese Help'));
      await tester.pumpAndSettle();
      expect(find.text('Qual é a lei suprema do país?'), findsOneWidget);
      await tester.ensureVisible(find.text('Reveal Answer'));
      await tester.tap(find.text('Reveal Answer'));
      await tester.pumpAndSettle();
      expect(find.text('• (U.S.) Constitution'), findsOneWidget);
      expect(c.studied, 1);
      await tester.ensureVisible(find.text('Know It'));
      await tester.tap(find.text('Know It'));
      await tester.pumpAndSettle();
      expect(c.mastered, 1);
      await tester.tap(find.text('Needs Practice'));
      await tester.pumpAndSettle();
      expect(c.needsPractice, 1);
      await tester.ensureVisible(find.text('Favorite'));
      await tester.tap(find.text('Favorite'));
      await tester.pumpAndSettle();
      expect(c.favorites, 1);
      await tester.ensureVisible(find.text('Constitution'));
      await tester.tap(find.text('Constitution'));
      await tester.pumpAndSettle();
      expect(find.text('Constituição'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    },
  );
  testWidgets('audio unavailable shows useful fallback', (tester) async {
    final c = await fixture(tester);
    (c.speech as FakeSpeech).available = false;
    await screen(tester, StudyScreen(controller: c));
    await tester.tap(find.text('Play Question'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Audio is unavailable.'), findsOneWidget);
  });
  testWidgets('all extra practice collections open with the intended sizes', (
    tester,
  ) async {
    final c = await fixture(tester);
    c.toggleFavorite(c.content!.questions.first.id);
    c.markStudied(
      c.content!.questions[1].id,
      status: StudyStatus.needsPractice,
    );
    await tester.pumpWidget(CivicsApp(controller: c));
    await tester.pumpAndSettle();
    final expected = {
      'Random 10': 10,
      'Random 20': 20,
      'All 128 Random': 128,
      'All 128 In Order': 128,
      'Needs Practice': 1,
      'Favorites': 1,
      '65/20 Questions': 20,
    };
    for (final entry in expected.entries) {
      Navigator.of(
        tester.element(find.byType(NavigationBar)),
      ).pushReplacementNamed('/test');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(entry.key));
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.text('1 / ${entry.value} in this session'), findsOneWidget);
      expect(
        find.text('Random Order'),
        entry.key.contains('Random') ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets(
    'official simulation self-grading completes and stores result exactly once',
    (tester) async {
      tester.view.physicalSize = const Size(768, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = await fixture(tester);
      await screen(tester, PracticeTestScreen(controller: c));
      await tester.tap(find.text('Start Official Simulation'));
      await tester.pumpAndSettle();
      expect(find.text('Portuguese Help'), findsNothing);
      for (var i = 0; i < 12; i++) {
        await tester.ensureVisible(find.text('Show Answer'));
        await tester.tap(find.text('Show Answer'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Correct'));
        await tester.tap(find.text('Correct'));
        await tester.pumpAndSettle();
      }
      expect(find.text('PASSED'), findsOneWidget);
      expect(c.progress.tests.length, 1);
      expect(c.progress.tests.single.correct, 12);
      expect(c.progress.tests.single.asked, 12);
      expect(find.text('Show Answer'), findsNothing);
    },
  );
  testWidgets('search matches configured answers and 65/20 filtering', (
    tester,
  ) async {
    final c = await fixture(tester);
    await screen(tester, QuestionsScreen(controller: c));
    await tester.enterText(find.byType(TextField), 'Jimmy Patronis');
    await tester.pumpAndSettle();
    expect(find.text('1 questions'), findsOneWidget);
    expect(find.text('Name your U.S. representative.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('65/20 Questions'));
    await tester.pumpAndSettle();
    expect(find.text('20 questions'), findsOneWidget);
  });
  testWidgets('reset requires confirmation and preserves progress on cancel', (
    tester,
  ) async {
    final c = await fixture(tester);
    c.markStudied(c.content!.questions.first.id);
    await screen(tester, SettingsScreen(controller: c));
    await tester.ensureVisible(find.text('Reset Progress'));
    await tester.tap(find.text('Reset Progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(c.studied, 1);
    await tester.tap(find.text('Reset Progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reset Progress'));
    await tester.pumpAndSettle();
    expect(c.studied, 0);
  });
  for (final width in [360.0, 390.0, 412.0, 768.0, 1440.0]) {
    testWidgets(
      'all screens fit ${width.toInt()}px, including bilingual answers',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final c = await fixture(tester);
        c.settings.language = StudyLanguage.bilingual;
        for (final child in [
          HomeScreen(controller: c),
          StudyScreen(controller: c, options: const StudyOptions(start: 47)),
          PracticeTestScreen(controller: c),
          QuestionsScreen(controller: c),
          ProgressScreen(controller: c),
          SettingsScreen(controller: c),
        ]) {
          await screen(tester, child);
          expect(tester.takeException(), isNull);
          if (child is StudyScreen) {
            await tester.ensureVisible(find.text('Reveal Answer'));
            await tester.tap(find.text('Reveal Answer'));
            await tester.pumpAndSettle();
            await tester.ensureVisible(find.text('Next'));
            expect(tester.takeException(), isNull);
          }
        }
      },
    );
  }
  testWidgets('360px layout supports enlarged text and dark theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = await fixture(tester);
    for (final child in [
      HomeScreen(controller: c),
      StudyScreen(controller: c),
      SettingsScreen(controller: c),
      ProgressScreen(controller: c),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: civicsTheme(Brightness.dark),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: child,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: child.runtimeType.toString(),
      );
    }
  });
}
