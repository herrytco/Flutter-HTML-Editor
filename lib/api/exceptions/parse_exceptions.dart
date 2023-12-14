class UnexpectedEndTagException implements Exception {
  final String expectedTagName;
  final String actualTagName;

  UnexpectedEndTagException(this.expectedTagName, this.actualTagName);

  @override
  String toString() {
    return "Encountered an unexpected end-tag. Expected </$expectedTagName> but found </$actualTagName>";
  }
}

class AdditionalEndTagException implements Exception {}

class EOFException implements Exception {}

class UndecodableTagException implements Exception {
  final String tag;

  UndecodableTagException(this.tag);
}
