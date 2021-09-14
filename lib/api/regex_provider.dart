class RegExProvider {
  /// matches supported HTML tags (start and end)
  static final RegExp tagRegex = RegExp(
      r'<\/?[a-zA-Z0-9]+(\s+[a-zA-Z0-9\-]+(="[a-zA-Z0-9#:;\-\.\/]*")?)*\s*>');

  /// matches supported HTML tags
  static RegExp startTagRegex = RegExp(
      r'<[a-zA-Z0-9]+(\s+[a-zA-Z0-9\-]+(="[a-zA-Z0-9#:;\-\.\/]*")?)*\s*>');

  /// matches supported end-tags
  static RegExp endTagRegex = RegExp("</[a-zA-Z0-9]+>");
}
