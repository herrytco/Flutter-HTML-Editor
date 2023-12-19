import 'package:flutter_test/flutter_test.dart';
import 'package:light_html_editor/api/exceptions/parse_exceptions.dart';
import 'package:light_html_editor/api/tag.dart';

void main() {
  test('tag: decode simple start tag', () {
    var t = Tag.decodeTag("<b>");

    expect(t.name, equals("b"));
    expect(t.isStart, equals(true));
    expect(t.size, 3);
  });

  test('tag: decode simple end tag', () {
    var t = Tag.decodeTag("</b>");

    expect(t.name, equals("b"));
    expect(t.isStart, equals(false));
    expect(t.size, 4);
  });

  test('tag: decode tag with a property', () {
    var t = Tag.decodeTag("<b hello=\"world\">");

    expect(t.name, equals("b"));
    expect(t.isStart, equals(true));
    expect(t.size, 17);

    expect(t.properties.entries.length, 1);
    expect(t.styleProperties.entries.length, 0);

    var prop = t.properties.entries.first;
    expect(prop.key, equals("hello"));
    expect(prop.value, equals("world"));
  });

  test('tag: decode tag with a style property', () {
    var t = Tag.decodeTag("<b style=\"color:black;\">");

    expect(t.name, equals("b"));
    expect(t.isStart, equals(true));
    expect(t.size, 24);

    expect(t.properties.entries.length, 1);

    expect(t.styleProperties.entries.length, 1);

    expect(t.properties.keys, contains("style"));

    var prop = t.styleProperties.entries.first;
    expect(prop.key, equals("color"));
    expect(prop.value, equals("black"));
  });

  test('tag: decode undecodable tag', () {
    expect(
      () => Tag.decodeTag("blablabla"),
      throwsA(isA<UndecodableTagException>()),
    );
  });

  test('tag: test style injection in blank node', () {
    var tag = Tag.decodeTag("<b>");

    var before = tag.rawTag;

    expect("<b>", equals(before));

    tag.putStyleProperty("font-size", "12");

    var after = tag.rawTag;

    expect(after, equals("<b style=\"font-size:12;\">"));
  });

  test('tag: test style injection in node with existing style prop', () {
    var tag = Tag.decodeTag("<b style=\"font-size:12\">");

    tag.putStyleProperty("font-size", "40");

    var after = tag.rawTag;

    expect(after, equals("<b style=\"font-size:40;\">"));
  });
}
