class RendererTextProperties {
  final String tagName;
  final double fontSize;
  final String? fontFamily;

  RendererTextProperties(this.tagName, this.fontSize, {this.fontFamily});

  @override
  String toString() {
    return "TextProperties(tag:$tagName,size:$fontSize,family:$fontFamily)";
  }
}
