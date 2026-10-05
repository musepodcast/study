import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../models/settings.dart';
import '../screens/home/home_screen.dart';
import '../screens/study/study_screen.dart';
import '../screens/practice_test/practice_test_screen.dart';
import '../screens/questions/questions_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../theme/app_theme.dart';
import 'study_controller.dart';

class CivicsApp extends StatelessWidget {
  final StudyController controller;
  const CivicsApp({super.key, required this.controller});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => MaterialApp(
      title: 'U.S. Civics Study',
      locale: controller.settings.appLanguage == AppLanguage.portuguese
          ? const Locale('pt', 'BR')
          : const Locale('en'),
      supportedLocales: const [Locale('pt', 'BR'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      theme: civicsTheme(Brightness.light),
      darkTheme: civicsTheme(Brightness.dark),
      themeMode: controller.settings.theme,
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (context) => AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (controller.loading) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: tr(context, 'Loading civics questions'),
                  ),
                ),
              );
            }
            if (controller.error != null) {
              return Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_outlined, size: 48),
                          const SizedBox(height: 20),
                          AppText(
                            controller.error!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: controller.initialize,
                            child: const AppText('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            final route = settings.name ?? '/';
            if (route.startsWith('/question/')) {
              final number = int.tryParse(route.split('/').last);
              if (number != null && number >= 1 && number <= 128) {
                return StudyScreen(
                  controller: controller,
                  options: StudyOptions(
                    start: number - 1,
                    label: 'Question $number',
                  ),
                );
              }
            }
            return switch (route) {
              '/' => HomeScreen(controller: controller),
              '/study' => StudyScreen(
                controller: controller,
                options: settings.arguments is StudyOptions
                    ? settings.arguments as StudyOptions
                    : const StudyOptions(),
              ),
              '/test' => PracticeTestScreen(controller: controller),
              '/questions' => QuestionsScreen(controller: controller),
              '/progress' => ProgressScreen(controller: controller),
              '/settings' => SettingsScreen(controller: controller),
              _ => Scaffold(
                appBar: AppBar(title: const AppText('Page not found')),
                body: Center(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/'),
                    child: const AppText('Go Home'),
                  ),
                ),
              ),
            };
          },
        ),
      ),
    ),
  );
}
