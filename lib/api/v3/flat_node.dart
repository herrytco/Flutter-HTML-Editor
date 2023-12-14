import 'package:flutter/material.dart';

class FlatNodeV3 {
  final String text;
  final TextStyle style;
  final String? linkTarget;
  final bool invokesNewLineBefore;
  final bool invokesNewLineAfter;

  FlatNodeV3(
    this.text,
    this.style, [
    this.linkTarget,
    this.invokesNewLineBefore = false,
    this.invokesNewLineAfter = false,
  ]);

  @override
  String toString() {
    return "FlatNodeV3($text, $invokesNewLineBefore, $invokesNewLineAfter)";
  }
}
