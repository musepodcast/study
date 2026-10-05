import '../../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/study_controller.dart';
import '../../models/settings.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/reset_progress.dart';

class SettingsScreen extends StatelessWidget {
  final StudyController controller;
  const SettingsScreen({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    final c = controller, location = controller.content!.location;
    return PageShell(
      controller: c,
      title: 'Settings',
      selected: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            'Make it feel like you.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<AppLanguage>(
            itemHeight: null,
            initialValue: c.settings.appLanguage,
            isExpanded: true,
            decoration: InputDecoration(labelText: tr(context, 'App language')),
            items: const [
              DropdownMenuItem(
                value: AppLanguage.portuguese,
                child: AppText('Brazilian Portuguese'),
              ),
              DropdownMenuItem(
                value: AppLanguage.english,
                child: AppText('English'),
              ),
            ],
            onChanged: (value) {
              c.settings.appLanguage = value!;
              c.save();
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<ThemeMode>(
            initialValue: c.settings.theme,
            decoration: InputDecoration(labelText: tr(context, 'Theme')),
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: AppText('System'),
              ),
              DropdownMenuItem(value: ThemeMode.light, child: AppText('Light')),
              DropdownMenuItem(value: ThemeMode.dark, child: AppText('Dark')),
            ],
            onChanged: (v) {
              c.settings.theme = v!;
              c.save();
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<StudyLanguage>(
            itemHeight: null,
            initialValue: c.settings.language,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: tr(context, 'Study language'),
            ),
            items: const [
              DropdownMenuItem(
                value: StudyLanguage.english,
                child: AppText('English Only'),
              ),
              DropdownMenuItem(
                value: StudyLanguage.bilingual,
                child: AppText('English + Portuguese'),
              ),
              DropdownMenuItem(
                value: StudyLanguage.onTap,
                child: AppText('Portuguese Help on Tap'),
              ),
            ],
            onChanged: (v) {
              c.settings.language = v!;
              c.save();
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<bool>(
            initialValue: c.settings.slowAudio,
            decoration: InputDecoration(
              labelText: tr(context, 'Audio speech rate'),
            ),
            items: const [
              DropdownMenuItem(value: false, child: AppText('Normal')),
              DropdownMenuItem(value: true, child: AppText('Slow')),
            ],
            onChanged: (v) {
              c.settings.slowAudio = v!;
              c.save();
            },
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Your location',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  AppText(c.content!.locationLabel),
                  AppText(
                    '${location['county'] ?? 'County unavailable'}\n${location['congressionalDistrict'] ?? 'District unavailable'}',
                  ),
                  const SizedBox(height: 16),
                  for (final key in ['representative', 'senators', 'governor'])
                    AppText(
                      '${{'representative': 'U.S. Representative', 'senators': 'U.S. Senators', 'governor': 'Governor'}[key]}: ${(c.content!.currentAnswers[key]?['english'] as List?)?.join(', ') ?? 'Unavailable'}',
                    ),
                  AppText(
                    'State capital: ${location['stateCapital'] ?? 'Unavailable'}',
                  ),
                  const SizedBox(height: 16),
                  const AppText(
                    'These state/local answers use your configured location and may need updating if you move or elected officials change.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          AppText(
            'About U.S. Civics Study',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const AppText(
            'Version 1.0 · 2025 Citizenship Test\nOfficial English first. Brazilian Portuguese translations and vocabulary are unofficial study assistance.',
          ),
          const SizedBox(height: 16),
          const AppText(
            'This study tool is not affiliated with or endorsed by U.S. Citizenship and Immigration Services. Official civics questions and answers are sourced from USCIS.',
          ),
          TextButton.icon(
            icon: const Icon(Icons.open_in_new_rounded),
            label: const AppText('USCIS Source'),
            onPressed: () async {
              try {
                final ok = await launchUrl(
                  Uri.parse(c.content!.source),
                  mode: LaunchMode.externalApplication,
                );
                if (!ok) {
                  throw StateError('Cannot open source');
                }
              } catch (e) {
                if (context.mounted) {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const AppText('USCIS Source'),
                      content: SelectableText(c.content!.source),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const AppText('Close'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),
          const AppText(
            'Local progress is specific to this browser or device. Clearing browser data removes it. Audio availability depends on installed device/browser voices.',
          ),
          const SizedBox(height: 16),
          ResetProgressButton(controller: c),
        ],
      ),
    );
  }
}
