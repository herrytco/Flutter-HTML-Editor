import 'package:flutter/material.dart';
import 'package:light_html_editor/data/color_utils.dart';
import 'package:light_html_editor/data/text_constants.dart';

///
/// one node of an HTML ParseTree. contains all text-pieced in the current layer
/// and a list of other [DocumentNode]'s which lie in-between of them
///
class DocumentNode {
  /// id of next instantiated [DocumentNode]
  static int _nextId = 1;

  /// tag-information of the tag which created this instance
  final Tag scope;

  /// text-pieces on the current layer
  List<String> text = [];

  /// possible parent-node
  final DocumentNode? parent;

  /// possible child nodes
  List<DocumentNode> children = [];

  /// id of the current node. Used for debug-purposes
  int id = _nextId++;

  ///
  /// instantiates a new [DocumentNode] with the given information.
  ///
  DocumentNode(this.scope, this.parent) {
    parent?.children.add(this);
  }

  ///
  /// returns the last available parent
  ///
  DocumentNode get root {
    DocumentNode k = this;

    while (k.parent != null) {
      k = k.parent!;
    }

    return k;
  }

  ///
  /// checks the path from the current node (including) to the root, if at least
  /// one tag in [taglist] is in it.
  ///
  bool _containsNodeRootPathAtLeastOneTag(List<String> taglist) {
    DocumentNode? workingNode = this;

    while (workingNode != null) {
      if (taglist.contains(workingNode.scope.name)) return true;

      workingNode = workingNode.parent;
    }

    return false;
  }

  bool _nodeTagIsOneOf(List<String> taglist) {
    return taglist.contains(this.scope.name);
  }

  ///
  /// checks the path from the current node (including) to the root, if one of
  /// the following tags is present: "b", "h1", "h2", "h3"
  ///
  bool get isBold =>
      _containsNodeRootPathAtLeastOneTag(["b", "h1", "h2", "h3"]);

  ///
  /// checks the path from the current node (including) to the root, if one of
  /// the following tags is present: "i"
  ///
  bool get isItalics => _containsNodeRootPathAtLeastOneTag(["i"]);

  ///
  /// checks the path from the current node (including) to the root, if one of
  /// the following tags is present: "u"
  ///
  TextDecoration get underline {
    if (_containsNodeRootPathAtLeastOneTag(["u"]))
      return TextDecoration.underline;

    return TextDecoration.none;
  }

  ///
  /// checks the path from the current node (including) to the root, if it has
  /// a "style"-property and if in the "style"-property, [key] is set. If so,
  /// it will try to parse the property to a color.
  ///
  /// If the parsing fails, the property will be ignored.
  ///
  Color? _getStylePropertyColorOrDefault(String key) {
    DocumentNode? workingNode = this;

    while (workingNode != null) {
      if (workingNode.scope.properties.containsKey("style") &&
          workingNode.scope.styleProperties[key] != null &&
          workingNode.scope.styleProperties[key].isNotEmpty) {
        String colorHex = workingNode.scope.styleProperties[key];

        try {
          return ColorUtils.colorForHex(colorHex);
        } on FormatException catch (_) {}
      }

      workingNode = workingNode.parent;
    }

    return null;
  }

  ///
  /// checks the path from the current node (including) to the root, if one of
  /// the following tags is present: "h1", "h2", "h3", "p"
  ///
  /// If one of them is present, a newline will be created after the end-tag
  ///
  bool get invokesNewline => _nodeTagIsOneOf(["h1", "h2", "h3", "p"]);

  ///
  /// checks the path from the current node (including) to the root, if either:
  ///   - a header-tag is encountered (h1, h2, h3), in that case, the
  ///     corresponding font-size is returned
  ///   - a style-property with a "font-size" is encoutnered. if that "font-size"
  ///     is a valid double, it will returned
  ///
  /// If no suitable candidate is found, [TextConstants.defaultFontSize] will be
  /// returned.
  ///
  double? get fontSize {
    DocumentNode? workingNode = this;
    String key = "font-size";

    while (workingNode != null) {
      if (TextConstants.headers.contains(workingNode.scope.name)) {
        double? headerFontSize =
            TextConstants.headerSizes[workingNode.scope.name];

        return headerFontSize != null
            ? headerFontSize
            : TextConstants.defaultFontSize;
      }

      if (workingNode.scope.properties.containsKey("style") &&
          workingNode.scope.styleProperties[key] != null &&
          workingNode.scope.styleProperties[key].isNotEmpty) {
        double? fontSize =
            double.tryParse(workingNode.scope.styleProperties[key]);

        if (fontSize != null) return fontSize;
      }

      workingNode = workingNode.parent;
    }

    return null;
  }

  ///
  /// checks the path from the current node (including) to the root, if a
  /// style-property with a "color" is encoutnered. if that "color"
  /// is a valid hex-representation of a color, it will returned
  ///
  /// If no suitable candidate is found, [TextConstants.defaultColor] will be
  /// returned.
  ///
  Color? get textColor => _getStylePropertyColorOrDefault("color");

  /// recursively prints the subtree into the console
  void printNode({intend = 0}) {
    for (int i = 0; i < text.length; i++) {
      String nodeText = "";
      for (int j = 0; j < intend; j++) nodeText += " ";

      nodeText += "<${scope.name}>${text[i]}</${scope.name}>";
      print(nodeText);

      if (i < children.length) children[i].printNode(intend: intend + 2);
    }
  }
}

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

  /// start, or end-tag
  final bool isStart;

  /// map of properties, mapping the html-key to it's value
  final Map<String, dynamic> properties;

  /// "style"-property with further split-up values
  Map<String, dynamic> styleProperties = {};

  /// the raw length of the tag for offset calculation
  final int rawTagLength;

  /// matches supported HTML tags
  static RegExp _startTagRegex =
      RegExp(r'<[a-zA-Z0-9]+(\s+[a-zA-Z0-9\-]+(="[a-zA-Z0-9#:;\-]*")?)*\s*>');

  /// matches supported end-tags
  static RegExp _endTagRegex = RegExp("</[a-zA-Z0-9]+>");

  /// creates a new tag-representation. and decodes the "style" tag if present
  Tag(this.name, this.properties, this.isStart, this.rawTagLength) {
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

  /// parses a tag-definition into a [Tag]
  static Tag decodeTag(String tag) {
    String tagClean =
        tag.substring(1, tag.length - 1).replaceAll("\s+", " ").trim();

    if (_startTagRegex.hasMatch(tag)) {
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

      return Tag(tagName, properties, true, tag.length);
    } else if (_endTagRegex.hasMatch(tag)) {
      return Tag(tag.substring(2, tag.length - 1), {}, false, tag.length);
    }

    throw Exception("Tag $tag was not decodeable!");
  }
}
