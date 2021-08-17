import 'package:flutter/material.dart';
import 'package:light_html_editor/data/text_constants.dart';

class EditorDecoration {
  final Color backgroundColor;
  final Color cursorColor;
  final String? editorLabel;
  final TextStyle inputStyle;
  final TextStyle labelStyle;
  final TextStyle focusedLabelStyle;

  const EditorDecoration({
    this.editorLabel,
    this.backgroundColor = Colors.white,
    this.cursorColor = Colors.black,
    this.inputStyle = TextConstants.labelStyle,
    this.labelStyle = TextConstants.labelStyle,
    this.focusedLabelStyle = TextConstants.labelStyle,
  });
}
