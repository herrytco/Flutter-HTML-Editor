import 'package:light_html_editor/api/regex_provider.dart';

///
/// contains all information about an HTML tag, including:
///   - tagname
///   - if it is a start- or an end-tag
///   - properties (if any)
///   - style-properties (if any)
///   - the raw length of the tag for offset calculation
///
class Tag {
  /// tagname (without '<', '/' or '>')
  final String name;

  /// complete tag includin properties and brackets
  final String rawTag;

  /// start, or end-tag
  final bool isStart;

  /// map of properties, mapping the html-key to it's value
  final Map<String, dynamic> properties;

  /// "style"-property with further split-up values
  Map<String, dynamic> styleProperties = {};

  /// the raw length of the tag for offset calculation
  final int rawTagLength;

  /// creates a new tag-representation. and decodes the "style" tag if present
  Tag(this.name, this.rawTag, this.properties, this.isStart,
      this.rawTagLength) {
    if (properties.containsKey("style")) {
      String styleProp = this.properties["style"];
      List<String> properties = styleProp.split(";");

      for (String property in properties) {
        List<String> parts = property.split(":");
        String key = parts[0].trim();
        String value = parts.length == 2 ? parts[1].trim() : "";

        styleProperties[key] = value;
      }
    }
  }

  @override
  String toString() {
    return "Tag($name, $properties)";
  }

  /// Decodes a random start- or end-tag encountered in HTML. [tag] is the full
  /// tag including brackets, properties, etc.
  ///
  /// Valid inputs:
  ///   - <p>
  ///   - <p style="font-weight:bold;">
  ///   - </p>
  factory Tag.decodeTag(String tag) {
    String tagClean =
        tag.substring(1, tag.length - 1).replaceAll("\s+", " ").trim();

    if (RegExProvider.startTagRegex.hasMatch(tag)) {
      List<String> tagParts = tagClean.split(" ");

      String tagName = tagParts[0];

      Map<String, dynamic> properties = {};

      for (int i = 1; i < tagParts.length; i++) {
        List<String> property = tagParts[i].split("=");

        String key = property[0];
        String value = property.length == 2
            ? property[1].substring(1, property[1].length - 1)
            : "";

        properties[key] = value;
      }

      return Tag(tagName, tag, properties, true, tag.length);
    } else if (RegExProvider.endTagRegex.hasMatch(tag)) {
      return Tag(tag.substring(2, tag.length - 1), tag, {}, false, tag.length);
    }

    throw Exception("Tag $tag was not decodeable!");
  }
}
