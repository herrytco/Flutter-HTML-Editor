import 'package:light_html_editor/api/exceptions/parse_exceptions.dart';
import 'package:light_html_editor/api/tag.dart';
import 'package:light_html_editor/api/stack.dart';
import 'package:light_html_editor/api/v3/node_v3.dart';
import 'package:light_html_editor/api/v3/tokenizer.dart';

class LightHtmlParserV3 {
  NodeV3 parse(String? rawHtml) {
    return _ParserV3(rawHtml).root;
  }
}

class _ParserV3 {
  final String? rawHtml;
  late String _html;
  int _parserPosition = 0;

  late NodeV3 root;

  _ParserV3(this.rawHtml) {
    root = NodeV3.root();

    if (rawHtml == null || rawHtml!.isEmpty) return;
    _html = rawHtml!;

    var nodeStack = Stack<NodeV3>();
    nodeStack.push(root);

    do {
      Token t;
      try {
        t = Tokenizer.instance.getNextToken(_html);
      } on EOFException catch (_) {
        break;
      }

      switch (t.type) {
        case TokenType.plain:
          nodeStack.peek.addChild(
            NodeV3(
              _parserPosition,
              _parserPosition + t.size,
              content: t.content,
              parent: nodeStack.peek,
            ),
          );
          break;

        case TokenType.start:
          var newChild = NodeV3(
            _parserPosition,
            _parserPosition + t.size,
            tag: Tag.decodeTag(t.content),
            parent: nodeStack.peek,
          );

          nodeStack.peek.addChild(newChild);
          nodeStack.push(newChild);
          break;

        case TokenType.end:
          Tag tag = Tag.decodeTag(t.content);

          if (nodeStack.peek.isRoot) {
            throw AdditionalEndTagException();
          }

          if (tag.name != nodeStack.peek.tag!.name) {
            throw UnexpectedEndTagException(nodeStack.peek.tag!.name, tag.name);
          }

          nodeStack.pop();
          break;
      }

      // readjust the raw text by the size of the new found token
      _html = _html.substring(t.size);
      _parserPosition += t.size;
    } while (true);
  }
}
