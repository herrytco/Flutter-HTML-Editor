import 'package:flutter/material.dart';
import 'package:light_html_editor/api/operations/property_operation.dart';
import 'package:light_html_editor/api/operations/tag_operation.dart';
import 'package:light_html_editor/api/parser.dart';
import 'package:light_html_editor/api/richtext_node.dart';
import 'package:light_html_editor/api/v2/node_v2.dart';

class HtmlEditorController extends TextEditingController {
  HtmlEditorController({String? text}) : super(text: text) {
    addListener(() {
      if (!canUndo || _oldText == null) {
        _oldText = this.text;
        return;
      }

      if (this.text.length == _oldText!.length + 1) _clearCache();

      _oldText = this.text;
    });
  }

  /// Cache for the text-value before the last change to detect single-stroke entries
  String? _oldText;

  ///
  /// Adds [textToInsert] to the text of the controller while also keeping the
  /// selection intact
  ///
  void insertAtCursor(String textToInsert) {
    final textBefore =
        selection.baseOffset < 1 ? "" : text.substring(0, selection.baseOffset);
    final textAfter =
        selection.baseOffset < 1 ? "" : text.substring(selection.extentOffset);
    final newText = textBefore + textToInsert + textAfter;
    final endPositionAfterInsert = textBefore.length + textToInsert.length;
    final newSelection = TextSelection(
      baseOffset: endPositionAfterInsert,
      extentOffset: endPositionAfterInsert,
    );
    value = value.copyWith(
      text: newText,
      selection: newSelection,
    );
  }

  ///
  /// node of the TextField used in the editor. Used to ensure the editor input
  /// is selected after the ButtonRow was clicked
  ///
  FocusNode? editorFocusNode;

  ///
  /// Placeholder to hold text for the undo-operation
  ///
  String? _cachedText;

  ///
  /// Placeholder to hold the selection for the undo-operation
  ///
  TextSelection? _cachedSelection;

  bool get canUndo => _cachedText != null;

  ///
  /// Replaces the text/selection with the cached version. This wipes the two
  /// cached properties => this method is not idempotent
  ///
  void undo() {
    if (_cachedText == null) {
      throw Exception("Cannot call undo if _cachedText is null!");
    }

    editorFocusNode?.requestFocus();

    value = value.copyWith(
      text: _cachedText!,
      selection: _cachedSelection,
    );

    _clearCache();
  }

  ///
  /// Wraps the current text-selection a symmetric pair of tags. If no text is
  /// selected, an empty tag-pair is inserted at the current cursor position.
  /// If the field is not focused, the empty tag-pair is appended to the current
  /// text.
  ///
  void wrapWithTag(String tagName) {
    _cache();

    String startTag = "<$tagName>";
    String endTag = "</$tagName>";

    wrapWithStartAndEnd(TagOperation(startTag, endTag));
  }

  ///
  /// Adds a style-property to the current selection of text. If there is an
  /// existing tag around the exact selection, the property gets added to this
  /// tag. A <span>-tag will be created otherwise.
  ///
  void insertStyleProperty(StylePropertyOperation op) {}

  ///
  /// Wraps the current text-selection with the provided tags. If no text is
  /// selected, an empty tag-pair is inserted at the current cursor position.
  /// If the field is not focused, the empty tag-pair is appended to the current
  /// text.
  ///
  /// Start- and End-Tag do not have to be the same, allowing properties in the
  /// tag.
  ///
  void wrapWithStartAndEnd(TagOperation op) {
    _cache();

    op.setSelection(selection);

    NodeV2 tree = Parser().parse(text);

    List<SimpleNode> affectedNodes =
        tree.getNodesInSelection(op.start!, op.end!);

    for (SimpleNode affectedNode in affectedNodes) {
      NodeV2 affectedParent = affectedNode.parent!;

      // print("selection: ${op.start} - ${op.end}");
      // print(
      //     "node range: ${affectedNode.startIndex} - ${affectedNode.endIndex}");

      // selection fully contains a node -> insert the attribute in its parent
      if (op.start! <= affectedNode.startIndex &&
          op.end! >= affectedNode.endIndex) {
        NodeV2 parentNew = NodeV2.fromTag(
          affectedParent,
          Tag.decodeTag(op.startTag),
        );

        affectedParent.children[affectedParent.children.indexOf(affectedNode)] =
            parentNew;
        parentNew.children.add(affectedNode);
      }
    }

    String before = text;
    // String after = op.applyOperationTo(text);

    text = tree.toHtml();

    return;

    if (editorFocusNode != null) {
      editorFocusNode!.requestFocus();
    }

    // adjust selection
    if (before.length == 0) {
      selection = TextSelection(
        baseOffset: op.startTag.length,
        extentOffset: op.startTag.length,
      );
    } else if (op.start == -1 && op.end == -1) {
      selection = TextSelection(
        baseOffset: "$before${op.startTag}".length,
        extentOffset: "$before${op.startTag}".length,
      );
    } else if (op.start == op.end) {
      if (op.start == 0)
        selection = TextSelection(
          baseOffset: op.startTag.length,
          extentOffset: op.startTag.length,
        );
      else {
        String a = before.substring(0, op.start);

        selection = TextSelection(
          baseOffset: "$a${op.startTag}".length,
          extentOffset: "$a${op.startTag}".length,
        );
      }
    } else {
      String a = before.substring(0, op.start);
      String b = before.substring(op.start!, op.end);

      selection = TextSelection(
        baseOffset: "$a${op.startTag}".length,
        extentOffset: "$a${op.startTag}$b".length,
      );
    }
  }

  void _cache() {
    _cachedText = text;
    _cachedSelection = selection;
  }

  void _clearCache() {
    _cachedText = null;
    _cachedSelection = null;
  }
}
