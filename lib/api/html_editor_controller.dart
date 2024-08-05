import 'dart:math';

import 'package:flutter/material.dart';
import 'package:light_html_editor/api/operations/property_operation.dart';
import 'package:light_html_editor/api/operations/tag_operation.dart';
import 'package:light_html_editor/api/tag.dart';
import 'package:light_html_editor/api/v3/node_v3.dart';
import 'package:light_html_editor/api/v3/parser.dart';

class LightHtmlEditorController extends TextEditingController {
  LightHtmlEditorController({String? text}) : super(text: text) {
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
  /// Adds a style-property to the current selection of text. If there is an
  /// existing tag around the exact selection, the property gets added to this
  /// tag. A <span>-tag will be created otherwise.
  ///
  void insertStyleProperty(StylePropertyOperation op) {
    _cache();

    int opStart = max(0, selection.start);
    int opEnd = max(0, selection.end);

    NodeV3 tree = LightHtmlParserV3().parse(text);

    if (opStart == opEnd) {
      var startTag = "<span style=\"${op.propertyKey}:${op.propertyValue}\">";
      var endTag = "</span>";

      print(text);
      print(opStart);
      print(opEnd);

      text = text.substring(0, opStart) +
          "$startTag$endTag" +
          text.substring(opStart);
      opStart += startTag.length;
      opEnd += startTag.length;
      tree = LightHtmlParserV3().parse(text);
    } else {
      bool wasOffset2 = false, wasOffset = false;

      // pass 1: split only partly affected nodes into new simple nodes
      List<NodeV3> affectedNodes = tree.select(opStart, opEnd);
      affectedNodes.forEach((element) {
        element.splitForSelection(opStart, opEnd);
      });
      affectedNodes = tree.select(opStart, opEnd);

      // pass 2: insert spans for not fully selected nodes
      affectedNodes
          .where((element) =>
              element.parent!.isRoot ||
              !element.parent!.isFullySelected(opStart, opEnd))
          .forEach((element) {
        var tag = Tag.decodeTag("<span>");
        element.insertTagNodeAbove(tag);

        if (!wasOffset) {
          opStart += tag.size;
          wasOffset = true;
        }

        opEnd += tag.endTagSize + tag.size;
      });

      // pass 2: insert/append style tags into selected nodes
      for (NodeV3 affectedNode in affectedNodes) {
        NodeV3 affectedParent = affectedNode.parent!;

        // 2.1 - fully selected parent: add the property to the parent tag
        if (affectedParent.isTag) {
          Tag parentTag = affectedParent.tag!;

          var lengthBefore = parentTag.rawTag.length;
          parentTag.putStyleProperty(op.propertyKey, op.propertyValue);

          int offset = parentTag.rawTag.length - lengthBefore;

          // move the start value to the start of the piece of content that gets wrapped with the style
          if (!wasOffset2) {
            opStart += offset;
            opEnd = opStart + affectedNode.content!.length;
            wasOffset2 = true;
          }
        }
      }
    }

    if (editorFocusNode != null) {
      editorFocusNode!.requestFocus();
    }

    value = value.copyWith(
      text: tree.toHtml(),
      selection: TextSelection(baseOffset: opStart, extentOffset: opEnd),
    );
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

    int opStart = selection.start;
    int opEnd = selection.end;

    NodeV3 tree = LightHtmlParserV3().parse(text);

    if (opStart == opEnd) {
      var startTag = "<${op.tagName}>";
      var endTag = "</${op.tagName}>";
      text = text.substring(0, opStart) +
          "$startTag$endTag" +
          text.substring(opStart);
      opStart += startTag.length;
      opEnd += startTag.length;
      tree = LightHtmlParserV3().parse(text);
    } else {
      bool wasOffset = false;

      // pass 1: split only partly affected nodes into new simple nodes
      List<NodeV3> affectedNodes = tree.select(opStart, opEnd);
      affectedNodes.forEach((element) {
        element.splitForSelection(opStart, opEnd);
      });
      affectedNodes = tree.select(opStart, opEnd);

      // snap selection to closest content node
      opStart = affectedNodes
          .map((e) => e.scopeStart)
          .reduce((value, element) => element > value ? value : element);
      opEnd = affectedNodes
          .map((e) => e.scopeEnd)
          .reduce((value, element) => element < value ? value : element);

      // pass 2: apply new tag to all (now only full-selection) nodes
      Tag tagToInsert = Tag.decodeTag(op.startTag);
      for (var affectedNode in affectedNodes) {
        var subtreeRootNew = affectedNode.insertTagNodeAbove(tagToInsert);

        if (!wasOffset) {
          opStart += subtreeRootNew.tag!.size;
          opEnd = opStart + affectedNode.content!.length;
          wasOffset = true;
        }
      }

      if (editorFocusNode != null) {
        editorFocusNode!.requestFocus();
      }
    }

    value = value.copyWith(
      text: tree.toHtml(),
      selection: TextSelection(
        baseOffset: opStart,
        extentOffset: opEnd,
      ),
    );
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
