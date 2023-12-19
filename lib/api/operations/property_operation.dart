class StylePropertyOperation {
  final String propertyKey;
  final String propertyValue;

  StylePropertyOperation(this.propertyKey, this.propertyValue);

  @override
  String toString() {
    return 'style="$propertyKey:$propertyValue"';
  }
}
