import 'dart:math';

import 'package:flutter/material.dart';

class StylePropertyOperation {
  final String propertyKey;
  final String propertyValue;
  int? start;
  int? end;

  void setSelection(TextSelection selection) {
    start = min(selection.baseOffset, selection.extentOffset - 1);
    end = max(selection.baseOffset, selection.extentOffset - 1);
  }

  StylePropertyOperation(this.propertyKey, this.propertyValue);

  @override
  String toString() {
    return 'style="$propertyKey:$propertyValue"';
  }
}
