import 'package:flutter/material.dart';

enum StudyLanguage { english, bilingual, onTap }

enum AppLanguage { portuguese, english }

class StudySettings {
  ThemeMode theme;
  StudyLanguage language;
  static const speechRates = [0.5, 0.7, 1.0, 1.25, 1.5, 2.0];
  static String speechRateLabel(double rate) =>
      '${rate.toStringAsFixed(rate == 1.25 ? 2 : 1)}×';
  double speechRate;
  bool get slowAudio => speechRate < 1;
  set slowAudio(bool value) => speechRate = value ? 0.7 : 1;
  AppLanguage appLanguage;
  StudySettings({
    this.theme = ThemeMode.system,
    this.language = StudyLanguage.onTap,
    this.speechRate = 1.0,
    this.appLanguage = AppLanguage.portuguese,
  });
  Map<String, dynamic> toJson() => {
    'theme': theme.name,
    'language': language.name,
    'speechRate': speechRate,
    'appLanguage': appLanguage.name,
  };
  factory StudySettings.fromJson(Map<String, dynamic> j) => StudySettings(
    theme: ThemeMode.values.byName(j['theme']),
    language: StudyLanguage.values.byName(j['language']),
    speechRate: speechRates.contains(j['speechRate'])
        ? (j['speechRate'] as num).toDouble()
        : j['slowAudio'] == true
        ? 0.7
        : 1.0,
    appLanguage: j['appLanguage'] == null
        ? AppLanguage.portuguese
        : AppLanguage.values.byName(j['appLanguage']),
  );
}
