import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:light_html_editor/api/stack.dart' as stack;
import 'package:light_html_editor/api/style_utils.dart';
import 'package:light_html_editor/api/v3/flat_node.dart';
import 'package:light_html_editor/api/v3/node_v3.dart';
import 'package:light_html_editor/data/text_constants.dart';
import 'package:light_html_editor/light_html_editor.dart';
import 'package:url_launcher/url_launcher.dart';

class LightHtmlTextRenderer {
  /// renderer settings to be applied
  final RendererStyle rendererStyle;

  /// optional maxLength used to cut off the text after a certain number of
  /// characters (tags excluded)
  final int? maxLength;

  /// optional maximum number of lines to be displayed
  final int? maxLines;

  /// variables used in the text
  final List<RichTextPlaceholder> placeholders;

  /// trialing and leading string to identify variables in the text
  final String placeholderMarker;

  List<FlatNodeV3> _flattenedTree = [];
  List<FlatNodeV3> get flattenedTree => List<FlatNodeV3>.from(_flattenedTree);

  Map<String, double> _fontSizes = {};
  Map<String, String> _fontFamilies = {};

  /// should linebreaks like in the <h1> ignored?
  final bool ignoreLinebreaks;

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

  factory LightHtmlTextRenderer.simple(String html, {RendererStyle? style}) =>
      LightHtmlTextRenderer(
        html,
        style ?? RendererStyle(),
        null,
        null,
        [],
        "\$",
        false,
      );

  LightHtmlTextRenderer(
    String html,
    this.rendererStyle,
    this.maxLength,
    this.maxLines,
    this.placeholders,
    this.placeholderMarker,
    this.ignoreLinebreaks,
  ) {
    _initFontStyles();

    _flatten(LightHtmlParserV3().parse(html));

    _render();
  }

  void _render() {
    int textLength = 0;
    bool full = false;

    for (var node in _flattenedTree) {
      String nodeText = node.text;

      if (maxLength != null && textLength + nodeText.length > maxLength!) {
        nodeText = nodeText.substring(
                0, min(maxLength! - textLength, nodeText.length)) +
            rendererStyle.overflowIndicator;
        full = true;
      }

      nodeText = Parser.replaceVariables(
        nodeText,
        placeholders: placeholders,
        placeholderMarker: placeholderMarker,
      );

      // linebreak before the new text
      if (!ignoreLinebreaks && _currentParagraph.length > 0) {
        if (node.invokesNewLineBefore) _performLinebreak();
      }

      _currentParagraph.add(
        TextSpan(
          text: nodeText,
          style: node.style,
          recognizer: buildTabRecognizer(node),
        ),
      );
      textLength += nodeText.length;

      // linebreak before the new text
      if (!ignoreLinebreaks && _currentParagraph.length > 0) {
        if (node.invokesNewLineAfter) _performLinebreak();
      }

      if (full) break;
    }

    _performLinebreak();
  }

  GestureRecognizer? buildTabRecognizer(FlatNodeV3 node) {
    GestureRecognizer? linkTapRecognizer;

    if (node.linkTarget != null) {
      final String target = node.linkTarget!;

      linkTapRecognizer = TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Uri.parse(target));
        };
    }

    return linkTapRecognizer;
  }

  void _performLinebreak() {
    if (_currentParagraph.length > 0) _paragraphs.add(_currentParagraph);
    _currentParagraph = [];
  }

  void _flatten(NodeV3 node) {
    var nodeStack = stack.Stack<NodeV3>();
    nodeStack.push(node);

    while (nodeStack.isNotEmpty) {
      var k = nodeStack.pop();

      if (k.isPlaintext) {
        bool isHeaderOrParagraph = k.query(
                NodeQuery(
                  [QueryType.tag],
                  ["h1", "h2", "h3", "h4", "h5", "h6", "p"],
                ),
                maxDepth: 1) !=
            null;

        double fontSize = _fontSizes[""]!;

        String? fontSizeQueryResult = k.query(NodeQuery(
          [QueryType.property, QueryType.styleProperty],
          ["fontSize", "font-size"],
        ));

        if (fontSizeQueryResult == null) {
          fontSizeQueryResult = k.query(NodeQuery(
            [QueryType.tag],
            ["h1", "h2", "h3", "h4", "h5", "h6"],
          ));

          if (fontSizeQueryResult != null) {
            if (_fontSizes.containsKey(fontSizeQueryResult))
              fontSize = _fontSizes[fontSizeQueryResult]!;
          }
        } else {
          fontSize = double.parse(fontSizeQueryResult);
        }

        String? fontFamilyQueryResult = k.query(NodeQuery(
          [QueryType.property, QueryType.styleProperty],
          ["fontFamily", "font-family"],
        ));

        String? fontWeight = k.query(NodeQuery(
          [QueryType.styleProperty, QueryType.tag],
          ["font-weight", "b"],
        ));

        String? fontStyleQueryResult = k.query(NodeQuery(
          [QueryType.tag],
          ["i"],
        ));

        String? colorQueryResult = k.query(NodeQuery(
          [QueryType.tag],
          ["a"],
        ));

        if (colorQueryResult == "a" && rendererStyle.linkColor != null) {
          colorQueryResult =
              "#${rendererStyle.linkColor!.value.toRadixString(16)}";
        }

        if (colorQueryResult == null)
          colorQueryResult = k.query(NodeQuery(
            [QueryType.property, QueryType.styleProperty],
            ["color"],
          ));

        String? backgroundColorQueryResult = k.query(NodeQuery(
          [QueryType.styleProperty],
          ["background-color"],
        ));

        String? underlineQueryResult = k.query(NodeQuery(
          [QueryType.tag],
          ["u", "a"],
        ));
        String? strikeThroughQueryResult = k.query(NodeQuery(
          [QueryType.tag],
          ["s"],
        ));
        String? overlineThroughQueryResult = k.query(NodeQuery(
          [QueryType.styleProperty],
          ["text-decoration"],
        ));

        TextDecoration decoration = TextDecoration.none;

        String? linkTarget = k.findFirstTag(["a"])?.properties["href"];

        if (underlineQueryResult != null) {
          decoration = TextDecoration.underline;
        } else if (strikeThroughQueryResult != null) {
          decoration = TextDecoration.lineThrough;
        } else if (overlineThroughQueryResult != null) {
          decoration = TextDecoration.overline;
        }

        _flattenedTree.add(
          FlatNodeV3(
            k.content!,
            TextStyle(
              fontSize: fontSize,
              fontFamily: fontFamilyQueryResult ?? _fontFamilies[""],
              fontWeight: fontWeight != null
                  ? StyleUtils.propertyToWeight(fontWeight)
                  : FontWeight.normal,
              fontStyle: fontStyleQueryResult != null
                  ? FontStyle.italic
                  : FontStyle.normal,
              color: colorQueryResult != null
                  ? StyleUtils.propertyToColor(colorQueryResult)
                  : rendererStyle.defaultColor,
              backgroundColor: backgroundColorQueryResult != null
                  ? StyleUtils.propertyToColor(backgroundColorQueryResult)
                  : rendererStyle.defaultBackgroundColor,
              decoration: decoration,
            ),
            linkTarget,
            isHeaderOrParagraph && k.isFirstChild,
            isHeaderOrParagraph && k.isLastChild,
          ),
        );
      }

      k.children.reversed.forEach((element) {
        nodeStack.push(element);
      });
    }
  }

  ///
  /// fills in the default values for font-size and font-family
  ///
  void _initFontStyles() {
    // add user-defined settings to the maps
    for (RendererTextProperties textProperties
        in rendererStyle.textProperties) {
      _fontSizes[textProperties.tagName] = textProperties.fontSize;
      if (textProperties.fontFamily != null)
        _fontFamilies[textProperties.tagName] = textProperties.fontFamily!;
    }

    // add default styles
    if (!_fontSizes.containsKey("")) {
      _fontSizes[""] = TextConstants.defaultFontSize;
      _fontSizes["sub"] = TextConstants.defaultFontSize / 2;
    }
    if (!_fontFamilies.containsKey("")) {
      _fontFamilies[""] = TextConstants.defaultFontFamily;
    }

    // add header settings
    for (String tag in TextConstants.headerSizes.keys) {
      if (!_fontSizes.containsKey(tag))
        _fontSizes[tag] = TextConstants.headerSizes[tag]!;

      if (!_fontFamilies.containsKey(tag)) {
        _fontFamilies[tag] = TextConstants.defaultFontFamily;
      }
    }
  }
}
