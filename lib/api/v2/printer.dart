import 'package:light_html_editor/api/v2/node_v2.dart';

class PrinterV2 {
  static String printTree(NodeV2 tree) {
    return printTreeAtLevel(tree, 0).trim();
  }

  static String printTreeAtLevel(NodeV2 tree, int level) {
    String result =
        "${getSpaced(level)} ${tree.prettyTag} (${tree.startIndex}, ${tree.endIndex}): ";

    if (tree is SimpleNode) {
      result += " ${tree.body}";
    }

    result += "\n";

    for (NodeV2 child in tree.children) {
      result += printTreeAtLevel(child, level + 2);
    }

    return result;
  }

  static String getSpaced(int level) {
    String result = "";

    for (int i = 0; i < level; i++) {
      result += " ";
    }

    return result;
  }
}
