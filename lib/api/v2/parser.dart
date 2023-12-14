import 'package:light_html_editor/api/exceptions/parse_exceptions.dart';
import 'package:light_html_editor/api/regex_provider.dart';
import 'package:light_html_editor/api/tag.dart';
import 'package:light_html_editor/api/v2/node_v2.dart';
import 'package:light_html_editor/api/v2/parse_state.dart';
import 'package:light_html_editor/light_html_editor.dart';

class Parser {
  ///
  /// remove all tags from a HTML-Richtext and return the raw, unformatted text
  ///
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

    _parseAndAddTo(root, ParseState.fromRawText(rawText));

    return root;
  }

  ParseState _parseAndAddTo(NodeV2 k, ParseState state) {
    while (state.remainingText.isNotEmpty) {
      RegExpMatch? nextTagMatch =
          RegExProvider.tagRegex.firstMatch(state.remainingText);

      // no tags left, just plaintext
      if (nextTagMatch == null) {
        k.addChild(SimpleNode(k, state.textOffset, state.remainingText));
        state.remainingText = "";
        break;
      }

      // a tag has been found - was it at string-start though?
      if (nextTagMatch.start > 0) {
        k.addChild(
          SimpleNode(
            k,
            state.textOffset,
            state.remainingText.substring(0, nextTagMatch.start),
          ),
        );
        state.textOffset += nextTagMatch.start;
        state.remainingText = state.remainingText.substring(nextTagMatch.start);
      } else {
        Tag tag = Tag.decodeTag(state.remainingText
            .substring(nextTagMatch.start, nextTagMatch.end));

        if (tag.isStart) {
          // encountered a start-tag
          NodeV2 nodeNew = NodeV2.fromTag(k, tag);
          k.addChild(nodeNew);

          state.textOffset += nextTagMatch.start + tag.size;
          state.remainingText = state.remainingText.substring(tag.size);
          state = _parseAndAddTo(nodeNew, state);
        } else {
          // encountered an end-tag
          if (k.tagName != tag.name) {
            throw UnexpectedEndTagException(k.tagName, tag.name);
          }

          state.textOffset += tag.size;
          state.remainingText = state.remainingText.substring(tag.size);
          return state;
        }
      }
    }

    return state;
  }
}
