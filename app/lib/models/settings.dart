import 'package:flutter/material.dart';

enum StudyLanguage { english, bilingual, onTap }

enum AppLanguage { portuguese, english }

class StudySettings {
  ThemeMode theme;
  StudyLanguage language;
  bool slowAudio;
  AppLanguage appLanguage;
  StudySettings({
    this.theme = ThemeMode.system,
    this.language = StudyLanguage.onTap,
    this.slowAudio = false,
    this.appLanguage = AppLanguage.portuguese,
  });
  Map<String, dynamic> toJson() => {
    'theme': theme.name,
    'language': language.name,
    'slowAudio': slowAudio,
    'appLanguage': appLanguage.name,
  };
  factory StudySettings.fromJson(Map<String, dynamic> j) => StudySettings(
    theme: ThemeMode.values.byName(j['theme']),
    language: StudyLanguage.values.byName(j['language']),
    slowAudio: j['slowAudio'],
    appLanguage: j['appLanguage'] == null
        ? AppLanguage.portuguese
        : AppLanguage.values.byName(j['appLanguage']),
  );
}
