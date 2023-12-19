import 'package:flutter_test/flutter_test.dart';
import 'package:light_html_editor/api/v3/parser.dart';

void main() {
  var parser = LightHtmlParserV3();

  test('selection: just one node', () {
    var tree = parser.parse("some input");

    expect(tree.scopeStart, equals(0));
    expect(tree.scopeEnd, equals(10));
  });

  test('selection: no selection for stationary index on end', () {
    var tree = parser.parse("0123456789");

    expect(tree.select(10, 10), []);
  });

  test('selection: selection for stationary index in the middle', () {
    var tree = parser.parse("0123456789");

    expect(tree.select(9, 9).length, equals(1));
  });

  test('selection: no selection for stationary index at the start', () {
    var tree = parser.parse("0123456789");

    expect(tree.select(0, 0), []);
  });

  test('selection: no match for selection before scope', () {
    var tree = parser.parse("some input");

    expect(tree.select(-5, 0), []);
  });

  test('selection: no match for selection after scope', () {
    var tree = parser.parse("some input");

    expect(tree.select(10, 12), []);
  });

  test('selection: match for overlap on start but not on end', () {
    var tree = parser.parse("some input");

    expect(tree.select(-2, 2).length, equals(1));
  });

  test('selection: match for overlap on end but not on start', () {
    var tree = parser.parse("some input");

    expect(tree.select(8, 12).length, equals(1));
  });

  test('selection: 3 nodes in total on total selection', () {
    var tree = parser.parse("<p>some</p> <p>input</p>");

    expect(tree.scopeStart, equals(0));
    expect(tree.scopeEnd, equals(24));

    expect(tree.select(0, 24).length, equals(3));
  });

  test('selection: 3 nodes in total on total selection', () {
    var tree = parser.parse("<p>some</p> <p><p>in</p><p>put</p></p>");

    expect(tree.scopeStart, equals(0));
    expect(tree.scopeEnd, equals(38));

    expect(tree.select(0, 38).length, equals(4));
  });
}
