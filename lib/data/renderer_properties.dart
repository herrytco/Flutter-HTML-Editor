import 'package:flutter/cupertino.dart';
import 'package:light_html_editor/data/text_constants.dart';

class RendererDecoration {
  final BoxBorder? border;
  final String? label;
  final TextStyle labelStyle;
  final Color defaultColor;
  final double defaultFontSize;
  final EdgeInsets padding;
  final double? maxHeight;
  final Color? linkColor;
  final bool? linkUnderline;

  const RendererDecoration({
    this.border,
    this.label,
    this.labelStyle = TextConstants.labelStyle,
    this.defaultColor = TextConstants.defaultColor,
    this.defaultFontSize = TextConstants.defaultFontSize,
    this.padding = const EdgeInsets.all(8),
    this.maxHeight,
    this.linkColor,
    this.linkUnderline,
  });
}
