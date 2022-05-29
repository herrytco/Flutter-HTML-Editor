class RendererTextProperties {
  final String tagName;
  final double fontSize;

  RendererTextProperties(this.tagName, this.fontSize);

  @override
  String toString() {
    return "TextProperties(tag:$tagName,size:$fontSize)";
  }
}
