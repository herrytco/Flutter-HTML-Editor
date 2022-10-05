class ParseState {
  final String rawText;
  String remainingText;
  int textOffset;

  ParseState._(this.rawText, this.remainingText, this.textOffset);

  factory ParseState.fromRawText(String text) => ParseState._(text, text, 0);
}
