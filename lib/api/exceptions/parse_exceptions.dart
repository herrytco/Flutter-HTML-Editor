class UnexpectedEndTagException implements Exception {
  final String expectedTagName;
  final String actualTagName;

  UnexpectedEndTagException(this.expectedTagName, this.actualTagName);

  @override
  String toString() {
    return "Encountered an unexpected end-tag. Expected </$expectedTagName> but found </$actualTagName>";
  }
}
