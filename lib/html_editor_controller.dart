import 'dart:math';

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

    wrapWithStartAndEnd(TagOperation(startTag, endTag, tagName));
  }

  ///
  /// Adds a style-property to the current selection of text. If there is an
  /// existing tag around the exact selection, the property gets added to this
  /// tag. A <span>-tag will be created otherwise.
  ///
  void insertStyleProperty(StylePropertyOperation op) {
    _cache();

    op.setSelection(selection);

    NodeV2 tree = Parser().parse(text);

    List<SimpleNode> affectedNodes =
        tree.getNodesInSelection(op.start!, op.end!);

    for (SimpleNode affectedNode in affectedNodes) {
      NodeV2 affectedParent = affectedNode.parent!;

      // selection fully contains a node -> insert the attribute in its parent
      if (op.start! <= affectedNode.textIndexStart &&
          op.end! >= affectedNode.textIndexEnd) {
        if (affectedParent is SimpleNode || affectedParent.tagName.isEmpty) {
          _insertTagNodeBetween(affectedParent, affectedNode,
              TagOperation('<span $op>', '</span>', 'span'));
        } else {
          _extendNodeWithStyle(affectedParent, op);
        }
      }
      // selection is only partially in a node -> split it into at least 2
      else {
        int opEnd = op.end!;

        int startLocal = max(0, op.start! - affectedNode.textIndexStart);
        int endLocal = min(
            opEnd - affectedNode.textIndexStart, affectedNode.body.length - 1);

        List<String> bodyParts = [
          affectedNode.body.substring(0, startLocal),
          affectedNode.body.substring(startLocal, endLocal + 1),
          affectedNode.body.substring(endLocal + 1),
        ];

        int offsetChild = affectedNode.textIndexStart;
        int startIndex = affectedParent.children.indexOf(affectedNode);
        affectedParent.children.remove(affectedNode);

        for (String part in bodyParts) {
          if (part.isEmpty) continue;

          var childNew = SimpleNode(affectedParent, offsetChild, part);
          offsetChild += part.length;

          affectedParent.addChild(childNew, startIndex++);

          // check if the new child is affected
          if (op.start! <= childNew.textIndexStart &&
              op.end! >= childNew.textIndexEnd) {
            // fully enclosed
            if (op.start! <= childNew.textIndexStart &&
                op.end! >= childNew.textIndexEnd) {
              _insertTagNodeBetween(affectedParent, childNew,
                  TagOperation('<span $op>', '</span>', 'span'));
            }
          }
        }
      }
    }

    text = tree.toHtml();
  }

  void _extendNodeWithStyle(NodeV2 node, StylePropertyOperation op) {
    if (node.styleProperty == null) {
      node.properties.add(StyleProperty.fromStyleString(
          "${op.propertyKey}:${op.propertyValue}"));
    } else {
      node.styleProperty!.putProperty(op.propertyKey, op.propertyValue);
    }
  }

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

    List<SimpleNode> changedNodes = [];

    for (SimpleNode affectedNode in affectedNodes) {
      NodeV2 affectedParent = affectedNode.parent!;

      // selection fully contains a node -> insert the attribute in its parent
      if (op.start! <= affectedNode.textIndexStart &&
          op.end! >= affectedNode.textIndexEnd) {
        _insertTagNodeBetween(affectedParent, affectedNode, op);

        changedNodes.add(affectedNode);
      }
      // selection is only partially in a node -> split it into at least 2
      else {
        int opEnd = op.end!;

        int startLocal = max(0, op.start! - affectedNode.textIndexStart);
        int endLocal = min(
            opEnd - affectedNode.textIndexStart, affectedNode.body.length - 1);

        List<String> bodyParts = [
          affectedNode.body.substring(0, startLocal),
          affectedNode.body.substring(startLocal, endLocal + 1),
          affectedNode.body.substring(endLocal + 1),
        ];

        int offsetChild = affectedNode.textIndexStart;
        int startIndex = affectedParent.children.indexOf(affectedNode);
        affectedParent.children.remove(affectedNode);

        for (String part in bodyParts) {
          if (part.isEmpty) continue;

          var childNew = SimpleNode(affectedParent, offsetChild, part);
          offsetChild += part.length;

          affectedParent.addChild(childNew, startIndex++);

          // check if the new child is affected
          if (op.start! <= childNew.textIndexStart &&
              op.end! >= childNew.textIndexEnd) {
            _insertTagNodeBetween(affectedParent, childNew, op);
          }
        }
      }
    }

    if (changedNodes.isNotEmpty) {
      int iStart = changedNodes.map((e) => e.textIndexStart).reduce(min);
      int iEnd = changedNodes.map((e) => e.textIndexEnd).reduce(max) + 1;

      if (editorFocusNode != null) {
        print("selection: $iStart-$iEnd");

        editorFocusNode!.requestFocus();
        value = value.copyWith(
          text: tree.toHtml(),
          selection: TextSelection(baseOffset: iStart, extentOffset: iEnd),
        );
      }
    } else {
      value = value.copyWith(
        text: tree.toHtml(),
      );
    }
  }

  void _insertTagNodeBetween(NodeV2 parent, NodeV2 child, TagOperation op) {
    // ignore the operation if the parent already has the correct type
    if (parent.tagName == op.tagName) return;

    NodeV2 parentNew = NodeV2.fromTag(
      parent,
      Tag.decodeTag(op.startTag),
    );

    parent.children[parent.children.indexOf(child)] = parentNew;
    parentNew.children.add(child);

    if (child is SimpleNode) {
      child.textIndexStart = child.textIndexStart + parentNew.fullTag.length;
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
