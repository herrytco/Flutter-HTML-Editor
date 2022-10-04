import 'dart:math';

import 'package:flutter/material.dart';

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

    wrapWithStartAndEnd(startTag, endTag);
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
  void wrapWithStartAndEnd(String startTag, String endTag) {
    _cache();

    int start = min(selection.baseOffset, selection.extentOffset);
    int end = max(selection.baseOffset, selection.extentOffset);

    String before = text;
    String after;

    if (before.length == 0) {
      after = "$startTag$endTag";
    } else if (start == -1 && end == -1) {
      after = "$before$startTag$endTag";
    } else if (start == end) {
      if (start == 0)
        after = "$startTag$endTag$before";
      else {
        String a = before.substring(0, start);
        String b = before.substring(start);

        after = "$a$startTag$endTag$b";
      }
    } else {
      String a = before.substring(0, start);
      String b = before.substring(start, end);
      String c = before.substring(end);

      after = "$a$startTag$b$endTag$c";
    }

    text = after;

    if (editorFocusNode != null) {
      editorFocusNode!.requestFocus();
    }

    if (before.length == 0) {
      selection = TextSelection(
        baseOffset: startTag.length,
        extentOffset: startTag.length,
      );
    } else if (start == -1 && end == -1) {
      selection = TextSelection(
        baseOffset: "$before$startTag".length,
        extentOffset: "$before$startTag".length,
      );
    } else if (start == end) {
      if (start == 0)
        selection = TextSelection(
          baseOffset: startTag.length,
          extentOffset: startTag.length,
        );
      else {
        String a = before.substring(0, start);

        selection = TextSelection(
          baseOffset: "$a$startTag".length,
          extentOffset: "$a$startTag".length,
        );
      }
    } else {
      String a = before.substring(0, start);
      String b = before.substring(start, end);

      selection = TextSelection(
        baseOffset: "$a$startTag".length,
        extentOffset: "$a$startTag$b".length,
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
