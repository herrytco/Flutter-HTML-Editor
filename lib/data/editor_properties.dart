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

  final double buttonEditorSpacing;
  final double editorPreviewSpacing;

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
    this.buttonEditorSpacing = 4,
    this.editorPreviewSpacing = 8,
    this.maxLines,
  });
}
