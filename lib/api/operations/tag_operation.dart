import 'dart:math';

import 'package:flutter/material.dart';

class TagOperation {
  final String startTag;
  final String endTag;
  final String tagName;

  int? start;
  int? end;

  TagOperation(this.startTag, this.endTag, this.tagName);

  bool get isPunctual => start == end;
  bool get isNoSelection => start == -1 && end == -1;

  void setSelection(TextSelection selection) {
    start = min(selection.baseOffset, selection.extentOffset - 1);
    end = max(selection.baseOffset, selection.extentOffset - 1);
  }

  String applyOperationTo(String text) {
    if (start == null || end == null)
      throw Exception("No selection was applied to this TagOperation!");

    String before = text;
    String after;

    if (before.isEmpty) {
      after = "$startTag$endTag";
    }

    if (isPunctual) {
      if (isNoSelection) {
        after = "$before$startTag$endTag";
      } else {
        if (start == 0)
          after = "$startTag$endTag$before";
        else {
          String a = before.substring(0, start);
          String b = before.substring(start!);

          after = "$a$startTag$endTag$b";
        }
      }
    } else {
      String a = before.substring(0, start);
      String b = before.substring(start!, end);
      String c = before.substring(end!);

      after = "$a$startTag$b$endTag$c";
    }

    return after;
  }
}
