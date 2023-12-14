import 'package:flutter_test/flutter_test.dart';
import 'package:light_html_editor/api/style_utils.dart';

void main() {
  test('color: [format] decoding of #ffffff test', () {
    var color = StyleUtils.propertyToColor("#ffffff");

    expect(color.alpha, 255);
    expect(color.red, 255);
    expect(color.green, 255);
    expect(color.blue, 255);
  });

  test('color: [format] decoding of ffffff test', () {
    var color = StyleUtils.propertyToColor("ffffff");

    expect(color.alpha, 255);
    expect(color.red, 255);
    expect(color.green, 255);
    expect(color.blue, 255);
  });

  test('color: [format] decoding of 0xFFFFFFFF test', () {
    var color = StyleUtils.propertyToColor("0xFFFFFFFF");

    expect(color.alpha, 255);
    expect(color.red, 255);
    expect(color.green, 255);
    expect(color.blue, 255);
  });

  test('color: [value] decoding of ff0000 test', () {
    var color = StyleUtils.propertyToColor("ff0000");

    expect(color.alpha, 255);
    expect(color.red, 255);
    expect(color.green, 0);
    expect(color.blue, 0);
  });

  test('color: [value] decoding of 00ff00 test', () {
    var color = StyleUtils.propertyToColor("00ff00");

    expect(color.alpha, 255);
    expect(color.red, 0);
    expect(color.green, 255);
    expect(color.blue, 0);
  });

  test('color: [value] decoding of 0000ff test', () {
    var color = StyleUtils.propertyToColor("0000ff");

    expect(color.alpha, 255);
    expect(color.red, 0);
    expect(color.green, 0);
    expect(color.blue, 255);
  });

  test('color: [value] decoding of 00003c test', () {
    var color = StyleUtils.propertyToColor("00003c");

    expect(color.alpha, 255);
    expect(color.red, 0);
    expect(color.green, 0);
    expect(color.blue, 60);
  });
}
