import 'package:flutter_test/flutter_test.dart';
import 'package:light_html_editor/api/v3/node_v3.dart';

void main() {
  test('node: root node has height of 0', () {
    expect(NodeV3.root().height, equals(0));
  });
}
