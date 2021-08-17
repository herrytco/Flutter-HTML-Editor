import 'package:flutter/material.dart';

///
/// Contains utility operations concerning colors
///
class ColorUtils {
  ///
  /// Parses a HTML-like color in the form #aaabbb into a [Color]. The # in the
  /// beginning is optional
  ///
  static Color colorForHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
