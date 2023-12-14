import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:light_html_editor/api/v3/text_renderer.dart';
import 'package:light_html_editor/light_html_editor.dart';

void main() {
  test('node: simple node test', () {
    var flatTree = LightHtmlTextRenderer.simple("hello").flattenedTree;

    expect(flatTree.length, equals(1));
    expect(flatTree.first.text, equals("hello"));
  });

  test('node: node order test', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><b>tag2</b>",
    ).flattenedTree;

    expect(flatTree.length, equals(3));
    expect(flatTree.first.text, equals("hello"));
    expect(flatTree[1].text, equals("tag1"));
    expect(flatTree[2].text, equals("tag2"));
  });

  test('node: node subtree order test', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><b><b>tag2</b><b>tag3</b></b>",
    ).flattenedTree;

    expect(flatTree.length, equals(4));
    expect(flatTree.first.text, equals("hello"));
    expect(flatTree[1].text, equals("tag1"));
    expect(flatTree[2].text, equals("tag2"));
    expect(flatTree[3].text, equals("tag3"));
  });

  test('node: node fontSize default test', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><b><b>tag2</b><b>tag3</b></b>",
      style: RendererStyle(textProperties: [RendererTextProperties("", 99.0)]),
    ).flattenedTree;

    expect(flatTree.length, equals(4));
    var tag3 = flatTree[3];
    expect(tag3.text, equals("tag3"));
    expect(tag3.style.fontSize, equals(99.0));
  });

  test('node: node fontSize tag test', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><b fontSize=\"20\"><b>tag2</b><b>tag3</b></b>",
    ).flattenedTree;

    expect(flatTree.length, equals(4));
    var tag3 = flatTree[3];
    expect(tag3.text, equals("tag3"));
    expect(tag3.style.fontSize, equals(20.0));
  });

  test('node: node fontFamily property test', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><b fontFamily=\"Arial\"><b>tag2</b><b>tag3</b></b>",
    ).flattenedTree;

    expect(flatTree.length, equals(4));
    var tag3 = flatTree[3];
    expect(tag3.text, equals("tag3"));
    expect(tag3.style.fontFamily, equals("Arial"));
  });

  test('node: node font-family style property test', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><b style=\"font-family:Arial\"><b>tag2</b><b>tag3</b></b>",
    ).flattenedTree;

    expect(flatTree.length, equals(4));
    var tag3 = flatTree[3];
    expect(tag3.text, equals("tag3"));
    expect(tag3.style.fontFamily, equals("Arial"));
  });

  test('node: node font-weight style property test', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><b style=\"font-weight:bold\"><b>tag2</b><b>tag3</b></b>",
    ).flattenedTree;

    expect(flatTree.length, equals(4));
    var tag3 = flatTree[3];
    expect(tag3.text, equals("tag3"));
    expect(tag3.style.fontWeight, equals(FontWeight.bold));
    expect(tag3.style.fontWeight, equals(FontWeight.w700));
  });

  test('node: node font-weight style property numeric test', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><span style=\"font-weight:200\"><b>tag2</b><a>tag3</a></span>",
    ).flattenedTree;

    expect(flatTree.length, equals(4));
    var tag3 = flatTree[3];
    expect(tag3.text, equals("tag3"));
    expect(tag3.style.fontWeight, equals(FontWeight.w200));
  });

  test('node: node color style property #010000', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><b style=\"color:#010000\"><b>tag2</b><b>tag3</b></b>",
    ).flattenedTree;

    expect(flatTree.length, equals(4));
    var tag3 = flatTree[3];
    expect(tag3.text, equals("tag3"));
    expect(tag3.style.color, equals(Color.fromRGBO(1, 0, 0, 1.0)));
  });

  test('node: node color style property 010000', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><b style=\"color:010000\"><b>tag2</b><b>tag3</b></b>",
    ).flattenedTree;

    expect(flatTree.length, equals(4));
    var tag3 = flatTree[3];
    expect(tag3.text, equals("tag3"));
    expect(tag3.style.color, equals(Color.fromRGBO(1, 0, 0, 1.0)));
  });

  test('node: node color style property 0xff010000', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><b style=\"color:010000\"><b>tag2</b><b>tag3</b></b>",
    ).flattenedTree;

    expect(flatTree.length, equals(4));
    var tag3 = flatTree[3];
    expect(tag3.text, equals("tag3"));
    expect(tag3.style.color, equals(Color.fromRGBO(1, 0, 0, 1.0)));
  });

  test('node: node background-color style property #010000', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "hello<b>tag1</b><b style=\"background-color:#010000\"><b>tag2</b><b>tag3</b></b>",
    ).flattenedTree;

    expect(flatTree.length, equals(4));
    var tag3 = flatTree[3];
    expect(tag3.text, equals("tag3"));
    expect(tag3.style.backgroundColor, equals(Color.fromRGBO(1, 0, 0, 1.0)));
  });

  test('node: node underlined property', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "<u>tag1</u>",
    ).flattenedTree;

    expect(flatTree.length, equals(1));
    var tag = flatTree[0];
    expect(tag.text, equals("tag1"));
    expect(tag.style.decoration, equals(TextDecoration.underline));
  });

  test('node: node strike through property', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "<s>tag1</s>",
    ).flattenedTree;

    expect(flatTree.length, equals(1));
    var tag = flatTree[0];
    expect(tag.text, equals("tag1"));
    expect(tag.style.decoration, equals(TextDecoration.lineThrough));
  });

  test('node: node overline property', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "<b style=\"text-decoration:overline\">tag1</b>",
    ).flattenedTree;

    expect(flatTree.length, equals(1));
    var tag = flatTree[0];
    expect(tag.text, equals("tag1"));
    expect(tag.style.decoration, equals(TextDecoration.overline));
  });

  test('node: fontWeight tag', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "<b>tag1</b>",
    ).flattenedTree;

    expect(flatTree.length, equals(1));
    var tag = flatTree[0];
    expect(tag.text, equals("tag1"));
    expect(tag.style.fontWeight, equals(FontWeight.bold));
  });

  test('node: fontWeight tag', () {
    var flatTree = LightHtmlTextRenderer.simple(
      "<a href=\"https://www.google.at\">tag1</a>",
    ).flattenedTree;

    expect(flatTree.length, equals(1));
    var tag = flatTree[0];
    expect(tag.text, equals("tag1"));
    expect(tag.linkTarget, equals("https://www.google.at"));
  });
}
