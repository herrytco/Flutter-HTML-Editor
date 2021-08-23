import 'package:flutter/material.dart';
import 'package:light_html_editor/api/parser.dart';
import 'package:light_html_editor/api/text_renderer.dart';
import 'package:light_html_editor/editor.dart';
import 'package:light_html_editor/placeholder.dart';
import 'package:light_html_editor/data/renderer_properties.dart';
import 'package:light_html_editor/api/richtext_node.dart';

///
/// Lightweight HTML renderer converting basic HTML text into Richtext
///
class RichtextRenderer extends StatelessWidget {
  ///
  /// Creates a new instance of an HTML renderer. Takes the root of a parse-tree
  /// as an argument which gets displayed.
  ///
  /// Displays an optional [label] at the bottom, styled by [labelStyle].
  ///
  /// The rendered text is padded by [padding].
  ///
  /// If a different font-size is wanted for text with unspecified font-size,
  /// [defaultFontSize] can be adapted.
  ///
  /// If a different default-text-color is wanted for text with unspecified
  /// text-color, [defaultColor] can be adapted.
  ///
  /// A border gets displayed around the rendered text per default, which can be
  /// turned off by setting [hasBorder]
  ///
  const RichtextRenderer({
    Key? key,
    @required this.root,
    this.maxLength,
    this.placeholderMarker = "\\\$",
    this.placeholders = const [],
    this.rendererDecoration = const RendererDecoration(),
    this.ignoreLinebreaks = false,
  }) : super(key: key);

  final DocumentNode? root;
  final int? maxLength;
  final String placeholderMarker;
  final List<RichTextPlaceholder> placeholders;
  final RendererDecoration rendererDecoration;
  final bool ignoreLinebreaks;

  ///
  /// Creates a new instance of an HTML renderer. Takes a richtext created by
  /// [RichTextEditor] as an argument which is parsed into a ParseTree
  ///
  /// Displays an optional [label] at the bottom, styled by [labelStyle].
  ///
  /// The rendered text is padded by [padding].
  ///
  /// If a different font-size is wanted for text with unspecified font-size,
  /// [defaultFontSize] can be adapted.
  ///
  /// If a different default-text-color is wanted for text with unspecified
  /// text-color, [defaultColor] can be adapted.
  ///
  /// A border gets displayed around the rendered text per default, which can be
  /// turned off by setting [hasBorder]
  ///
  factory RichtextRenderer.fromRichtext(
    String richtext, {
    int? maxLength,
    RendererDecoration rendererDecoration = const RendererDecoration(),
    bool ignoreLinebreaks = false,
    String placeholderMarker = "\\\$",
    List<RichTextPlaceholder> placeholders = const [],
  }) {
    return RichtextRenderer(
      root: Parser().parse(richtext),
      maxLength: maxLength,
      rendererDecoration: rendererDecoration,
      ignoreLinebreaks: ignoreLinebreaks,
      placeholderMarker: placeholderMarker,
      placeholders: placeholders,
    );
  }

  ///
  /// Transforms the written text into an in-order representation which then gets
  /// further processed into a list of [RichText] to display.
  ///
  List<RichText> _renderText() {
    return TextRenderer(
      root!,
      rendererDecoration,
      maxLength,
      placeholders,
      placeholderMarker,
      ignoreLinebreaks,
    ).paragraphs;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: rendererDecoration.border != null
            ? rendererDecoration.border!
            : Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: rendererDecoration.padding,
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: rendererDecoration.maxHeight != null
                  ? rendererDecoration.maxHeight!
                  : double.infinity,
            ),
            child: SingleChildScrollView(
              child: root != null &&
                      root!.children.length == 0 &&
                      root!.text.length == 0
                  ? SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: _renderText()
                          .map(
                            (RichText line) => Container(
                              child: line,
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //     color: Colors.black,
                              //   ),
                              // ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
          if (rendererDecoration.label != null &&
              rendererDecoration.label!.isNotEmpty)
            Container(
              padding: rendererDecoration.padding,
              child: Text(
                rendererDecoration.label!,
                style: rendererDecoration.labelStyle,
              ),
            ),
        ],
      ),
    );
  }
}
