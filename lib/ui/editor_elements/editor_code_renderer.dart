import 'package:flutter/material.dart';
import 'package:light_html_editor/api/exceptions/parse_exceptions.dart';
import 'package:light_html_editor/api/v3/text_renderer.dart';
import 'package:light_html_editor/data/renderer_decoration.dart';
import 'package:light_html_editor/editor.dart';
import 'package:light_html_editor/api/placeholder.dart';

///
/// Lightweight HTML renderer converting basic HTML text into Richtext
///
class LightHtmlRenderer extends StatelessWidget {
  ///
  /// Creates a new instance of an HTML renderer. Takes the root of a parse-tree
  /// as an argument which gets displayed.
  ///
  /// The widget can be styled by setting an appropriate [rendererDecoration].
  ///
  LightHtmlRenderer({
    Key? key,
    @required this.rawHtml,
    this.maxLength,
    this.maxLines,
    this.placeholderMarker = "\\\$",
    this.placeholders = const [],
    this.rendererDecoration = const RendererStyle(),
    this.ignoreLinebreaks = false,
    this.displayErrors = true,
    required this.scrollController,
  }) : super(key: key) {
    if (maxLines != null && maxLength != null)
      throw Exception("maxLines == null || maxLength == null must be true");
  }

  final String? rawHtml;
  final int? maxLength;

  /// optional maximum number of lines to be displayed.
  final int? maxLines;

  /// control whether errors should be shown or not
  final bool displayErrors;

  final String placeholderMarker;
  final List<RichTextPlaceholder> placeholders;
  final RendererStyle rendererDecoration;
  final bool ignoreLinebreaks;

  final ScrollController scrollController;

  ///
  /// Creates a new instance of an HTML renderer. Takes a richtext created by
  /// [LightHtmlRichTextEditor] as an argument which is parsed into a ParseTree
  ///
  /// The widget can be styled by setting an appropriate [rendererDecoration].
  ///
  factory LightHtmlRenderer.fromRichtext(
    String richtext, {
    int? maxLength,
    int? maxLines,
    RendererStyle rendererDecoration = const RendererStyle(),
    bool ignoreLinebreaks = false,
    String placeholderMarker = "\\\$",
    List<RichTextPlaceholder> placeholders = const [],
    ScrollController? scrollController,
  }) {
    return LightHtmlRenderer(
      rawHtml: richtext,
      maxLength: maxLength,
      maxLines: maxLines,
      rendererDecoration: rendererDecoration,
      ignoreLinebreaks: ignoreLinebreaks,
      placeholderMarker: placeholderMarker,
      placeholders: placeholders,
      scrollController: scrollController ?? ScrollController(),
    );
  }

  Widget get content {
    String? error;
    RichText? parsedHtml;

    try {
      parsedHtml = LightHtmlTextRenderer(
        rawHtml!,
        rendererDecoration,
        maxLength,
        maxLines,
        placeholders,
        placeholderMarker,
        ignoreLinebreaks,
      ).paragraphs;
    } on UnexpectedEndTagException catch (e) {
      error = "$e";
    } on UndecodableTagException catch (e) {
      error = "$e";
    } on EOFException catch (e) {
      error = "$e";
    }

    if (displayErrors && error != null) {
      return Text(
        error,
        style: rendererDecoration.errorStyle,
      );
    }

    if (rawHtml != null && rawHtml!.isEmpty) return SizedBox();

    if (parsedHtml != null) return parsedHtml;

    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: rendererDecoration.enableScroll
          ? SingleChildScrollView(
              controller: scrollController,
              child: content,
            )
          : content,
    );
  }
}
