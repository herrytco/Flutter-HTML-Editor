import 'package:light_html_editor/api/exceptions/parse_exceptions.dart';
import 'package:light_html_editor/api/regex_provider.dart';
import 'package:light_html_editor/api/tag.dart';

class Tokenizer {
  static Tokenizer? _instance;

  static Tokenizer get instance {
    if (_instance == null) _instance = Tokenizer._();

    return _instance!;
  }

  Tokenizer._();

  Token getNextToken(String rawHtml) {
    if (rawHtml.isEmpty) {
      throw EOFException();
    }

    RegExpMatch? nextTagMatch = RegExProvider.tagRegex.firstMatch(rawHtml);

    // if there is no tag or the tag is not at the start of the string, return
    // the plaintext
    if (nextTagMatch == null || nextTagMatch.start > 0) {
      return Token(
        TokenType.plain,
        nextTagMatch == null
            ? rawHtml
            : rawHtml.substring(0, nextTagMatch.start),
      );
    }

    var tag = Tag.decodeTag(
      rawHtml.substring(nextTagMatch.start, nextTagMatch.end),
    );

    return Token(
      tag.isStart ? TokenType.start : TokenType.end,
      tag.rawTag,
    );
  }
}

enum TokenType { start, end, plain }

class Token {
  final TokenType type;
  final String content;

  Token(this.type, this.content);

  int get size => content.length;
}
