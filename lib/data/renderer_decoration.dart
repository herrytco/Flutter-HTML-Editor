import 'package:flutter/material.dart';
import 'package:light_html_editor/data/renderer_text_properties.dart';
import 'package:light_html_editor/data/text_constants.dart';

///
/// collection of style properties for the RichtextRenderer
///
class RendererStyle {
  final BorderRadiusGeometry? borderRadius;
  final String? label;
  final TextStyle labelStyle;
  final Color defaultColor;
  final Color defaultBackgroundColor;
  final Color? linkColor;
  final bool? linkUnderline;
  final bool autoScroll;
  final bool enableScroll;

  /// displayed at the end of a shortened message due to length limits
  final String overflowIndicator;

  final List<RendererTextProperties> textProperties;

  final TextStyle errorStyle;

  const RendererStyle({
    this.borderRadius,
    this.label,
    this.labelStyle = TextConstants.labelStyle,
    this.defaultColor = TextConstants.defaultColor,
    this.defaultBackgroundColor = TextConstants.defaultBackgroundColor,
    this.autoScroll = true,
    this.linkColor = Colors.blue,
    this.linkUnderline,
    this.overflowIndicator = "...",
    this.textProperties = const [],
    this.errorStyle = TextConstants.errorStyle,
    this.enableScroll = true,
  });
}
