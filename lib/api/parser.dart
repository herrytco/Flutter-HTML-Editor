import 'package:light_html_editor/api/regex_provider.dart';
import 'package:light_html_editor/api/richtext_node.dart';
import 'package:light_html_editor/placeholder.dart';

///
/// used to transform written HTML-Richtext into a parse-tree and holds a number
/// of utility-methods like stripping tags from a text to access the tagless text
///
class Parser {
  /// remove all tags from a HTML-Richtext and return the raw, unformatted text
  String cleanTagsFromRichtext(String text) {
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
  String replaceVariables(
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

  /// Parse HTML-Richtext into a ParseTree that holds all information needed
  /// to create a Flutter widget out of it
  DocumentNode parse(String text) {
    DocumentNode currentNode = DocumentNode(
      Tag("", {}, true, 0),
      null,
    );

    String remainingText = text;

    while (remainingText.isNotEmpty) {
      RegExpMatch? nextTagMatch =
          RegExProvider.tagRegex.firstMatch(remainingText);

      if (nextTagMatch == null) {
        currentNode.text.add(remainingText);
        remainingText = "";
        break;
      }

      Tag tag = Tag.decodeTag(
          remainingText.substring(nextTagMatch.start, nextTagMatch.end));

      String tagName, leading;

      if (tag.isStart) {
        tagName = tag.name;

        leading = remainingText.substring(0, nextTagMatch.start);
        remainingText = remainingText.substring(nextTagMatch.end);

        currentNode.text.add(leading);
        currentNode = DocumentNode(tag, currentNode);
      } else {
        tagName = tag.name;

        if (tagName != currentNode.scope.name) return currentNode;

        leading = remainingText.substring(0, nextTagMatch.start);
        remainingText = remainingText.substring(nextTagMatch.end);

        currentNode.text.add(leading);
        if (currentNode.parent != null) currentNode = currentNode.parent!;
      }
    }

    return currentNode.root;
  }
}
