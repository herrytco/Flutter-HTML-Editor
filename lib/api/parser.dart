import 'package:light_html_editor/api/regex_provider.dart';
import 'package:light_html_editor/api/richtext_node.dart';
import 'package:light_html_editor/api/v2/node_v2.dart';
import 'package:light_html_editor/light_html_editor.dart';

class Parser {
  /// remove all tags from a HTML-Richtext and return the raw, unformatted text
  static String cleanTagsFromRichtext(String text) {
    RegExpMatch? match = RegExProvider.tagRegex.firstMatch(text);

    while (match != null) {
      text = text.substring(0, match.start) + text.substring(match.end);
      match = RegExProvider.tagRegex.firstMatch(text);
    }

    return text;
  }

  ///
  /// substitutes the variables occuring in [text] with their respective values
  /// stored in [placeholders]
  ///
  static String replaceVariables(
    String text, {
    List<RichTextPlaceholder> placeholders = const [],
    String placeholderMarker = "\\\$",
  }) {
    for (RichTextPlaceholder placeholder in placeholders) {
      String search =
          "$placeholderMarker${placeholder.symbol}$placeholderMarker";

      text = text.replaceAll(
        RegExp(search),
        "${placeholder.value}",
      );
    }

    return text;
  }

  NodeV2 parse(String? rawText) {
    NodeV2 root = NodeV2.root();
    if (rawText == null) return root;

    _parseAndAddTo(root, rawText);

    return root;
  }

  String _parseAndAddTo(NodeV2 k, String remainingText) {
    while (remainingText.isNotEmpty) {
      RegExpMatch? nextTagMatch =
          RegExProvider.tagRegex.firstMatch(remainingText);

      // no tags left, just plaintext
      if (nextTagMatch == null) {
        k.children.add(SimpleNode(k, remainingText));
        remainingText = "";
        break;
      }

      // a tag has been found - was it at string-start though?
      if (nextTagMatch.start > 0) {
        k.children.add(
          SimpleNode(k, remainingText.substring(0, nextTagMatch.start)),
        );
        remainingText = remainingText.substring(nextTagMatch.start);
      } else {
        Tag tag = Tag.decodeTag(
            remainingText.substring(nextTagMatch.start, nextTagMatch.end));

        if (tag.isStart) {
          // encountered a start-tag
          NodeV2 nodeNew = NodeV2.fromTag(k, tag);
          k.children.add(nodeNew);

          remainingText = remainingText.substring(tag.rawTagLength);
          remainingText = _parseAndAddTo(nodeNew, remainingText);
        } else {
          // encountered an end-tag
          if (k.tag != tag.name) {
            throw Exception(
                "Unexpected end-tag! Expected '</${k.tag}>' but found '</${tag.name}>'");
          }

          remainingText = remainingText.substring(tag.rawTagLength);
          return remainingText;
        }
      }
    }

    return remainingText;
  }
}
