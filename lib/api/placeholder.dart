///
/// data structure for variables usable in the richtext.
///
class RichTextPlaceholder {
  /// symbol that can be used in the code
  final String symbol;

  /// substitute of the symbol
  final String value;

  /// creates a new [RichTextPlaceholder] out of its components
  RichTextPlaceholder(this.symbol, this.value);
}
