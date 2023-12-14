import 'package:flutter_test/flutter_test.dart';
import 'package:light_html_editor/api/exceptions/parse_exceptions.dart';
import 'package:light_html_editor/api/v3/tokenizer.dart';

void main() {
  final Tokenizer tokenizer = Tokenizer.instance;

  test('tokenizer: test exception on empty input string', () {
    expect(
      () => tokenizer.getNextToken(""),
      throwsA(isA<EOFException>()),
    );
  });

  test('tokenizer: empty plain text', () {
    var t = tokenizer.getNextToken("  ");

    expect(t.content, equals("  "));
    expect(t.type, equals(TokenType.plain));
  });

  test('tokenizer: test plain text input without following tag', () {
    var t = tokenizer.getNextToken("some input ");

    expect(t.content, equals("some input "));
    expect(t.type, equals(TokenType.plain));
  });

  test('tokenizer: test plain text input with following tag', () {
    var t = tokenizer.getNextToken("some input <b>tag</b>");

    expect(t.content, equals("some input "));
    expect(t.type, equals(TokenType.plain));
  });

  test('tokenizer: tag at root of string', () {
    var t = tokenizer.getNextToken("<b>tag</b> with some content");

    expect(t.content, equals("<b>"));
    expect(t.type, equals(TokenType.start));
  });

  test('tokenizer: just the end tag', () {
    var t = tokenizer.getNextToken("</b>");

    expect(t.content, equals("</b>"));
    expect(t.type, equals(TokenType.end));
  });

  test('tokenizer: end tag with spaces should be plaintext', () {
    var t = tokenizer.getNextToken("< /b >");

    expect(t.content, equals("< /b >"));
    expect(t.type, equals(TokenType.plain));
  });
}
