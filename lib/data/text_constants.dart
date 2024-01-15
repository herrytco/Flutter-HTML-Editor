import 'package:flutter/material.dart';

class TextConstants {
  /// font-size used when no size is specified
  static const double defaultFontSize = 16;

  /// font-family used when no family is specified
  static const String defaultFontFamily = "Roboto";

  /// color used if no color is specified
  static const Color defaultColor = Colors.black;

  /// color used if no color is specified
  static const Color defaultBackgroundColor = Colors.transparent;

  /// link underline when no override was provided
  static const TextDecoration defaultLinkUnderline = TextDecoration.underline;

  static const Color defaultLinkColor = Colors.blue;

  /// available header tags
  static const List<String> headers = const ["h1", "h2", "h3"];

  /// used when invalid HTML is parsed
  static const TextStyle errorStyle = TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.bold,
  );

  /// corresponding header-sizes
  static const Map<String, double> headerSizes = const {
    "h1": 30,
    "h2": 25,
    "h3": 20,
  };

  /// default style of labels
  static const TextStyle labelStyle = TextStyle(
    color: Colors.black,
  );

  /// available list of colors
  static const List<String> defaultColors = [
    "#ff0000",
    "#cc0000",
    "#00ff00",
    "#6aa84f",
    "#0000ff",
    "#ffff00",
    "#ff77ff",
    "#9900ff",
    "#bf9001",
    "#666666"
  ];
}
