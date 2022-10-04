import 'package:flutter/material.dart';
import 'package:light_html_editor/data/text_constants.dart';

class EditorDecoration {
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final Color backgroundColor;
  final Color cursorColor;
  final String? editorLabel;
  final TextStyle inputStyle;
  final TextStyle labelStyle;
  final TextStyle focusedLabelStyle;
  final int? maxLines;

  final Color buttonColor;

  const EditorDecoration({
    this.border,
    this.borderRadius,
    this.editorLabel,
    this.backgroundColor = Colors.white,
    this.cursorColor = Colors.black,
    this.inputStyle = TextConstants.labelStyle,
    this.labelStyle = TextConstants.labelStyle,
    this.focusedLabelStyle = TextConstants.labelStyle,
    this.buttonColor = TextConstants.defaultColor,
    this.maxLines,
  });
}
