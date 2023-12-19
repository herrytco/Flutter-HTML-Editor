import 'package:flutter_test/flutter_test.dart';
import 'package:light_html_editor/api/v3/parser.dart';

void main() {
  var parser = LightHtmlParserV3();

  test('encode/decode: just plaintext', () {
    _equalityTest(
      parser,
      "some input",
    );
  });

  test('encode/decode: one tag', () {
    _equalityTest(
      parser,
      "<p>some input</p>",
    );
  });

  test('encode/decode: one tag with property', () {
    _equalityTest(
      parser,
      "<p property=\"noice\">some input</p>",
    );
  });

  test('encode/decode: one tag with style property', () {
    _equalityTest(
      parser,
      "<p property=\"noice\" style=\"color:black;\">some input</p>",
    );
  });

  test('encode/decode: two simple tags', () {
    _equalityTest(
      parser,
      "<p>some </p><p>input</p>",
    );
  });

  test('encode/decode: two simple tags', () {
    _equalityTest(
      parser,
      "<p>some </p><p>input</p>",
    );
  });
}

void _equalityTest(LightHtmlParserV3 parser, String input) {
  var tree = parser.parse(input);
  expect(tree.toHtml(), input);
}
