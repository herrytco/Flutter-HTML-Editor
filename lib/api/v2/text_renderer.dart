import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:light_html_editor/api/v2/node_v2.dart';
import 'package:light_html_editor/data/text_constants.dart';
import 'package:light_html_editor/light_html_editor.dart';
import 'package:url_launcher/url_launcher.dart';

///
/// Used to conver the tree of [NodeV2] nodes into a list of [RichText]
/// which resemble the paragraphs of the text
///
class TextRenderer {
  /// root of the tree to be converted
  final String rawHtml;

  /// renderer settings to be applied
  final RendererStyle rendererDecoration;

  /// optional maxLength used to cut off the text after a certain number of
  /// characters (tags excluded)
  final int? maxLength;

  /// optional maximum number of lines to be displayed
  final int? maxLines;

  /// variables used in the text
  final List<RichTextPlaceholder> placeholders;

  /// trialing and leading string to identify variables in the text
  final String placeholderMarker;

  /// should linebreaks like in the <h1> ignored?
  final bool ignoreLinebreaks;

  /// intermediate representation of the tree
  List<_TextNode> _flattenedNodes = [];

  /// current paragraph - will become one [RichText] in the final result
  List<TextSpan> _currentParagraph = [];

  /// all currently rendered paragraphs
  List<List<TextSpan>> _paragraphs = [];

  /// displayable widgets
  RichText get paragraphs {
    List<TextSpan> content = [];

    for (List<TextSpan> line in _paragraphs) {
      for (TextSpan part in line) content.add(part);

      if (_paragraphs.indexOf(line) < _paragraphs.length - 1)
        content.add(TextSpan(text: "\n"));
    }

    return RichText(
      key: UniqueKey(),
      maxLines: maxLines,
      text: TextSpan(
        children: content,
      ),
    );
  }

  Map<String, double> _fontSizes = {};
  Map<String, String> _fontFamilies = {};

  /// recursively parses the richtext-tree
  TextRenderer(
    this.rawHtml,
    this.rendererDecoration,
    this.maxLength,
    this.maxLines,
    this.placeholders,
    this.placeholderMarker,
    this.ignoreLinebreaks,
  ) {
    _initFontStyles();

    NodeV2 root = Parser().parse(rawHtml);
    _proccessNode(root);

    int textLength = 0;
    bool full = false;

    for (int i = 0; i < _flattenedNodes.length; i++) {
      _TextNode node = _flattenedNodes[i];

      String nodeText = node.text;
      if (maxLength != null && textLength + nodeText.length > maxLength!) {
        nodeText = nodeText.substring(
                0, min(maxLength! - textLength, nodeText.length)) +
            rendererDecoration.overflowIndicator;
        full = true;
      }

      nodeText = Parser.replaceVariables(
        nodeText,
        placeholders: placeholders,
        placeholderMarker: placeholderMarker,
      );

      // linebreak before the new text
      if (!ignoreLinebreaks && _currentParagraph.length > 0) {
        if (node.invokesNewlineBefore) _performLinebreak();
      }

      GestureRecognizer? linkTapRecognizer;

      if (node.linkTarget != null) {
        final String target = node.linkTarget!;

        linkTapRecognizer = TapGestureRecognizer()
          ..onTap = () {
            launchUrl(Uri.parse(target));
          };
      }

      _currentParagraph.add(
        TextSpan(
          text: nodeText,
          style: node.style,
          recognizer: linkTapRecognizer,
        ),
      );
      textLength += nodeText.length;

      // linebreak before the new text
      if (!ignoreLinebreaks && _currentParagraph.length > 0) {
        if (node.invokesNewlineAfter) _performLinebreak();
      }

      if (full) break;
    }

    _performLinebreak();
  }

  ///
  /// fills in the default values for font-size and font-family
  ///
  void _initFontStyles() {
    for (RendererTextProperties textProperties
        in rendererDecoration.textProperties) {
      _fontSizes[textProperties.tagName] = textProperties.fontSize;
      if (textProperties.fontFamily != null)
        _fontFamilies[textProperties.tagName] = textProperties.fontFamily!;
    }

    if (!_fontSizes.containsKey("")) {
      _fontSizes[""] = TextConstants.defaultFontSize;
      _fontSizes["sub"] = TextConstants.defaultFontSize / 2;
    }

    if (!_fontFamilies.containsKey("")) {
      _fontFamilies[""] = TextConstants.defaultFontFamily;
    }

    for (String tag in TextConstants.headerSizes.keys) {
      if (!_fontSizes.containsKey(tag))
        _fontSizes[tag] = TextConstants.headerSizes[tag]!;

      if (!_fontFamilies.containsKey(tag)) {
        _fontFamilies[tag] = TextConstants.defaultFontFamily;
      }
    }
  }

  void _performLinebreak() {
    if (_currentParagraph.length > 0) _paragraphs.add(_currentParagraph);
    _currentParagraph = [];
  }

  ///
  /// returns the underline-value for this node. checks first if the node is
  /// descendant of a link-node and looks for <u> tags afterwards
  ///
  TextDecoration _textDecoration(SimpleNode node) {
    if (node.isLink) {
      if (rendererDecoration.linkUnderline != null)
        return rendererDecoration.linkUnderline!
            ? TextConstants.defaultLinkUnderline
            : TextDecoration.none;
      else
        return TextConstants.defaultLinkUnderline;
    }

    return node.textDecoration;
  }

  ///
  /// returns the underline-value for this node. checks first if the node is
  /// descendant of a link-node and looks for <u> tags afterwards
  ///
  Color _color(SimpleNode node) {
    if (node.isLink) {
      if (rendererDecoration.linkColor != null)
        return rendererDecoration.linkColor!;
      else
        return TextConstants.defaultLinkColor;
    }

    return node.textColor ?? rendererDecoration.defaultColor;
  }

  ///
  /// converts a subtree into a list of [_TextNode], resulting into an in-order
  /// flattening of the subtree.
  ///
  void _proccessNode(NodeV2 node) {
    if (node is SimpleNode) {
      bool addLineBreakBefore =
          (node.isHeader || node.isParagraph) && node.isFirstChild;
      bool addLineBreakAfter =
          (node.isHeader || node.isParagraph) && node.isLastChild;

      _flattenedNodes.add(
        _TextNode(
          node.body,
          TextStyle(
            fontSize: node.fontSize(_fontSizes),
            fontFamily: node.fontFamily ?? _fontFamilies[""],
            fontWeight: node.fontWeight,
            fontStyle: node.fontStyle,
            color: _color(node),
            decoration: _textDecoration(node),
            backgroundColor: node.backgroundColor,
          ),
          addLineBreakBefore,
          addLineBreakAfter,
          node.linkTarget,
        ),
      );
    }

    for (NodeV2 child in node.children) {
      _proccessNode(child);
    }
  }
}

///
/// representation of a single node with a corresponding [TextStyle] and if the
/// node invokes a linebreak after it
///
class _TextNode {
  final String text;
  final TextStyle style;
  final bool invokesNewlineBefore;
  final bool invokesNewlineAfter;
  final String? linkTarget;

  _TextNode(
    this.text,
    this.style,
    this.invokesNewlineBefore,
    this.invokesNewlineAfter,
    this.linkTarget,
  );

  @override
  String toString() {
    return "TextNode($text, $linkTarget)";
  }
}
