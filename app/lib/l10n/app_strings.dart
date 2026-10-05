import 'package:flutter/material.dart';
import 'strings_pt.dart';

String tr(BuildContext context, String value) {
  if (Localizations.localeOf(context).languageCode != 'pt') {
    return value;
  }
  final exact = portugueseStrings[value];
  if (exact != null) {
    return exact;
  }
  final rules = <(RegExp, String Function(Match))>[
    (RegExp(r'^QUESTION (\d+) OF 128$'), (m) => 'PERGUNTA ${m[1]} DE 128'),
    (RegExp(r'^Question (\d+)$'), (m) => 'Pergunta ${m[1]}'),
    (
      RegExp(r'^(\d+) / (\d+) in this session$'),
      (m) => '${m[1]} / ${m[2]} nesta sessão',
    ),
    (RegExp(r'^(\d+) of 128 studied$'), (m) => '${m[1]} de 128 estudadas'),
    (
      RegExp(r'^(\d+) mastered · (\d+) need practice$'),
      (m) => '${m[1]} dominadas · ${m[2]} precisam de prática',
    ),
    (
      RegExp(r'^English practice, with Portuguese by your side\.\n(.+)$'),
      (m) => 'Pratique inglês com a ajuda do português.\n${m[1]}',
    ),
    (
      RegExp(r'^Answer for your configured location: (.+)$'),
      (m) => 'Resposta para sua localização: ${m[1]}',
    ),
    (
      RegExp(r'^Question (\d+) of up to 20$'),
      (m) => 'Pergunta ${m[1]} de até 20',
    ),
    (RegExp(r'^(\d+) correct$'), (m) => '${m[1]} corretas'),
    (RegExp(r'^(\d+) incorrect$'), (m) => '${m[1]} incorretas'),
    (
      RegExp(r'^(\d+) possible questions left$'),
      (m) => 'Até ${m[1]} perguntas restantes',
    ),
    (RegExp(r'^(\d+) questions$'), (m) => '${m[1]} perguntas'),
    (
      RegExp(r'^(\d+) correct\n(\d+) incorrect\n(\d+) questions asked$'),
      (m) => '${m[1]} corretas\n${m[2]} incorretas\n${m[3]} perguntas feitas',
    ),
    (
      RegExp(r'^(\d+) correct · (\d+) incorrect · (\d+) asked\n(.+)$'),
      (m) =>
          '${m[1]} corretas · ${m[2]} incorretas · ${m[3]} perguntas\n${m[4]}',
    ),
    (RegExp(r'^State capital: (.+)$'), (m) => 'Capital do estado: ${m[1]}'),
    (
      RegExp(r'^(U\.S\. Representative|U\.S\. Senators|Governor): (.+)$'),
      (m) => '${portugueseStrings[m[1]]}: ${m[2]}',
    ),
    (
      RegExp(r'^(.+) · ★ 65/20$'),
      (m) => '${portugueseStrings[m[1]] ?? m[1]} · ★ 65/20',
    ),
  ];
  for (final (pattern, replacement) in rules) {
    final match = pattern.firstMatch(value);
    if (match != null) {
      return replacement(match);
    }
  }
  return value;
}

/// Localizes interface copy only; official English and authored study content
/// remain normal Text widgets and are never translated by this class.
class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final String? semanticsLabel;
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.semanticsLabel,
  });
  @override
  Widget build(BuildContext context) => Text(
    tr(context, data),
    style: style,
    textAlign: textAlign,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel == null
        ? null
        : tr(context, semanticsLabel!),
  );
}
