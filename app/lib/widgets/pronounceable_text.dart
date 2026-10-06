import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../app/study_controller.dart';
import 'question_audio_controls.dart';

/// Keep every original character while adding pronunciation gestures to words.
class PronounceableText extends StatefulWidget {
  final String text;
  final StudyController controller;
  final TextStyle? style;
  const PronounceableText(
    this.text, {
    super.key,
    required this.controller,
    this.style,
  });
  @override
  State<PronounceableText> createState() => _PronounceableTextState();
}

class _PronounceableTextState extends State<PronounceableText> {
  final List<TapGestureRecognizer> _recognizers = [];
  late List<InlineSpan> _spans;
  @override
  void initState() {
    super.initState();
    _createSpans();
  }

  @override
  void didUpdateWidget(PronounceableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.controller != widget.controller) {
      _createSpans();
    }
  }

  void _createSpans() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    _spans = [];
    var position = 0;
    for (final match in RegExp(
      r"[A-Za-z]+(?:['’\-][A-Za-z]+)*|[0-9]+",
    ).allMatches(widget.text)) {
      _spans.add(TextSpan(text: widget.text.substring(position, match.start)));
      final word = match.group(0)!;
      final recognizer = TapGestureRecognizer()
        ..onTap = () => playSpeech(context, widget.controller, word);
      _recognizers.add(recognizer);
      _spans.add(
        TextSpan(
          text: word,
          recognizer: recognizer,
          mouseCursor: SystemMouseCursors.click,
        ),
      );
      position = match.end;
    }
    _spans.add(TextSpan(text: widget.text.substring(position)));
  }

  @override
  Widget build(BuildContext context) =>
      Text.rich(TextSpan(children: _spans), style: widget.style);
  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }
}
