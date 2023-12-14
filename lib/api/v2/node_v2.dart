import 'dart:math';
import 'dart:ui';

import 'package:light_html_editor/api/tag.dart';
import 'package:light_html_editor/data/color_utils.dart';
import 'package:light_html_editor/data/text_constants.dart';

///
/// Representation of a node in the DOM. This class contains everything passed
/// in the HTML text and can be serialized to valid HTML
///
class NodeV2 {
  /// tag-type. A '<a href="abcd">' tag in HTML would result in the value of "a"
  final String tagName;

  /// full tag specification. A '<a href="abcd">' tag in HTML would result in
  /// the value of '<a href="abcd">'
  final String fullTag;

  /// text-properties of the tag
  final List<SimpleProperty> properties;

  /// Parent node. All nodes in the DOM except the root node will have a parent
  final NodeV2? parent;

  /// Children nodes.
  final List<NodeV2> children = [];

  /// markers on which positions in the source-code the actual text starts/ends
  /// both indices are inclusive values
  int _textIndexStart = 0, _textIndexEnd = 0;

  int get textIndexStart => _textIndexStart;

  bool isFullySelected(int selectionStart, int selectionEnd) {
    return selectionStart <= textIndexStart && selectionEnd >= textIndexEnd;
  }

  set textIndexStart(int value) {
    _textIndexStart = value;

    if (this is SimpleNode) parent?._recalcIndices();
  }

  int get textIndexEnd => _textIndexEnd;

  /// markers on which position in the source-code this node starts/ends
  int nodeIndexStart = 0, nodeIndexEnd = 0;

  NodeV2._(
    this.parent,
    this.tagName,
    this.fullTag,
    this.properties,
  );

  /// constructs an empty node with a null parent
  factory NodeV2.root() {
    return NodeV2._(null, "", "", []);
  }

  /// creates a node from a parent and a tag.
  factory NodeV2.fromTag(NodeV2 parent, Tag tag) {
    List<SimpleProperty> properties = [];

    for (String propertyKey in tag.properties.keys) {
      if (propertyKey == "style") {
        properties
            .add(StyleProperty.fromStyleString(tag.properties[propertyKey]));
      } else {
        properties
            .add(SimpleProperty(propertyKey, tag.properties[propertyKey]));
      }
    }

    return NodeV2._(parent, tag.name, tag.rawTag, properties);
  }

  /// assigns this node the min/max value of all child start/end indices and
  /// triggers a recalc in the parent as well
  void _recalcIndices() {
    textIndexStart = children.map((e) => e.textIndexStart).reduce(min);
    _textIndexEnd = children.map((e) => e.textIndexEnd).reduce(max);

    nodeIndexStart = textIndexStart - fullTag.length;
    nodeIndexEnd = textIndexEnd + "$endHtmlTag".length;

    if (parent != null) parent!._recalcIndices();
  }

  /// adds a child-node to this node at an optional position. Triggers a recalc
  /// of node indices
  void addChild(NodeV2 node, [int? position]) {
    if (position == null) {
      children.add(node);
    } else {
      children.insert(position, node);
    }

    _recalcIndices();
  }

  /// cache for the style-property to avoid unneccessary searches
  StyleProperty? _cacheStyleProperty;

  /// returns the cached style (if present), searches for it in the properties
  /// otherwise
  StyleProperty? get styleProperty {
    if (_cacheStyleProperty == null) {
      List<StyleProperty> style =
          properties.whereType<StyleProperty>().toList();

      if (style.isNotEmpty) _cacheStyleProperty = style.first;
    }

    return _cacheStyleProperty;
  }

  /// returns a prettier version of the tag (no HTML)
  String get prettyTag {
    String props = "";

    for (SimpleProperty p in properties) {
      props += " ${p.name}:${p.value}";
    }

    return "<$tagName$props>";
  }

  /// creates a valid start-tag representation for this node (HTML)
  String get startHtmlTag {
    if (tagName.isEmpty) return "";

    String startTag = "<$tagName";

    for (SimpleProperty property in properties) {
      startTag += ' ${property.name}="${property.toHtml()}';
      startTag += '"';
    }

    return "$startTag>";
  }

  /// creates a valid end-tag representation for this node (HTML)
  String get endHtmlTag => tagName.isEmpty ? "" : "</$tagName>";

  /// serializes the tree back to a HTML string
  String toHtml() {
    String html = startHtmlTag;

    for (NodeV2 child in children) {
      html += child.toHtml();
    }

    return html + endHtmlTag;
  }

  /// checks if information about font-size exist in this node and returns them,
  /// null otherwise
  double? _fontSize(Map<String, double> tagSizes) {
    // 1. check if a dedicated style-property is set
    if (styleProperty != null) {
      if (styleProperty!.value["font-size"] != null)
        return double.tryParse(styleProperty!.value["font-size"]!);
    }

    // 2. check if it is a predefined tag
    if (tagSizes.containsKey(tagName)) return tagSizes[tagName]!;

    return null;
  }

  /// checks if information about font-weight exist in this node and returns them,
  /// null otherwise
  FontWeight? get _fontWeight {
    // 1. check if a dedicated style-property is set
    if (styleProperty != null) {
      if (styleProperty!.value["font-weight"] != null) {
        switch (styleProperty!.value["font-weight"]!) {
          case "bold":
            return FontWeight.bold;
        }
      }
    }

    // 2. check if it is a known tag
    if (["h1", "h2", "h3", "h4", "h5", "h6", "b"].contains(tagName))
      return FontWeight.bold;

    return null;
  }

  /// checks if information about font-style exist in this node and returns them,
  /// null otherwise
  FontStyle? get _fontStyle {
    // 1. check if a dedicated style-property is set
    if (styleProperty != null) {
      if (styleProperty!.value["font-style"] != null) {
        switch (styleProperty!.value["font-style"]!) {
          case "italic":
            return FontStyle.italic;
        }
      }
    }

    // 2. check if it is a known tag
    if (["i"].contains(tagName)) return FontStyle.italic;

    return null;
  }

  List<SimpleNode> getLeaves() {
    List<SimpleNode> result = [];

    List<NodeV2> toCheck = [this];

    while (toCheck.isNotEmpty) {
      NodeV2 k = toCheck[0];
      toCheck.remove(k);

      if (k is SimpleNode) {
        result.add(k);
      } else {
        toCheck.addAll(k.children);
      }
    }

    return result;
  }

  NodeV2 get root {
    NodeV2 k = this;

    while (k.parent != null) k = k.parent!;

    return k;
  }

  ///
  /// find all nodes that have their [textIndexStart] >= [start] and [startIndex+body.length] <= [end]
  ///
  List<SimpleNode> getNodesInSelection(int start, int end) {
    List<SimpleNode> result = [];

    List<NodeV2> toCheck = [this];

    while (toCheck.isNotEmpty) {
      NodeV2 k = toCheck[0];
      toCheck.remove(k);

      if (k is SimpleNode) {
        // full or partial selection
        if ((k.textIndexStart <= start && start <= k.textIndexEnd) ||
            (k.textIndexStart <= end && end <= k.textIndexEnd) ||
            (start <= k.textIndexStart && k.textIndexEnd <= end)) result.add(k);
      } else {
        toCheck.addAll(k.children);
      }
    }

    return result;
  }
}

/// Represents a leaf-node in the DOM. This node only contains text and is used
/// to separate styling logic from the actual textual information
class SimpleNode extends NodeV2 {
  static int _nextId = 1;

  /// id to find the node later again
  int id = _nextId++;

  void refreshId() {
    id = _nextId++;
  }

  /// Text contained in the node. Unstructured plaintext containing no HTML
  final String body;

  /// Index of the last text character
  int get textIndexEnd => textIndexStart + (body.length - 1);

  @override
  String get prettyTag => super.prettyTag;

  @override
  String toHtml() => body;

  /// Searches the path to the root for the first occurance of a node with a
  /// font-style information. Returns [FontStyle.normal] if no information is
  /// present
  FontStyle get fontStyle {
    NodeV2? k = this;

    while (k != null) {
      FontStyle? localStyle = k._fontStyle;

      if (localStyle != null) return localStyle;

      k = k.parent;
    }

    return FontStyle.normal;
  }

  /// Searches the path to the root for the first occurance of a node with a
  /// font-weight information. Returns [FontWeight.normal] if no information is
  /// present
  FontWeight get fontWeight {
    NodeV2? k = this;

    while (k != null) {
      FontWeight? localWeight = k._fontWeight;

      if (localWeight != null) return localWeight;

      k = k.parent;
    }

    return FontWeight.normal;
  }

  /// Searches the path to the root for the first occurance of a node with a
  /// text-decoration information. Returns [TextDecoration.none] if no
  /// information is present
  TextDecoration get textDecoration {
    NodeV2? k = this;

    while (k != null) {
      if (k.tagName == "u") return TextDecoration.underline;

      if (k.styleProperty != null) {
        StyleProperty prop = k.styleProperty!;

        dynamic weight = prop.getProperty("text-decoration");

        switch (weight) {
          case "underline":
            return TextDecoration.underline;

          case "line-through":
            return TextDecoration.lineThrough;

          case "overline":
            return TextDecoration.overline;
        }
      }

      k = k.parent;
    }

    return TextDecoration.none;
  }

  /// Searches the path to the root for the first occurance of a node with a
  /// font-family information. Returns [null] if no information is
  /// present
  String? get fontFamily {
    NodeV2? k = this;

    while (k != null) {
      if (k.styleProperty != null) {
        StyleProperty prop = k.styleProperty!;

        dynamic fontFamily = prop.getProperty("font-family");

        if (fontFamily != null) return fontFamily;
      }

      k = k.parent;
    }

    return null;
  }

  /// Searches the path to the root for the first occurance of a node with a
  /// font-size information. The parameter is a map of tagNames to default
  /// font-sizes. This map must contain an entry for [""], which is used
  /// if no information is found.
  double fontSize(Map<String, double> sizes) {
    NodeV2? k = parent;

    while (k != null) {
      double? fontSize = k._fontSize(sizes);

      if (fontSize != null) return fontSize;

      k = k.parent;
    }

    return sizes[""]!;
  }

  /// Gathers all <sub> and <sup> nodes and adds the corresponding [FontFeature]
  /// to the result set
  Set<FontFeature> get fontFeatures {
    NodeV2? k = parent;

    Set<FontFeature> result = {};

    while (k != null) {
      if (k.tagName == "sup") result.add(FontFeature.superscripts());
      if (k.tagName == "sub") result.add(FontFeature.subscripts());

      k = k.parent;
    }

    return result;
  }

  /// returns true iff this node is the first child of the parent or of the
  /// parent is null
  bool get isFirstChild {
    if (parent == null) return true;

    return parent!.children.first == this;
  }

  /// returns true iff this node is the last child of the parent or of the
  /// parent is null
  bool get isLastChild {
    if (parent == null) return true;

    return parent!.children.last == this;
  }

  Color? get backgroundColor {
    NodeV2? k = this;

    while (k != null) {
      if (k.styleProperty != null) {
        StyleProperty prop = k.styleProperty!;

        dynamic color = prop.getProperty("background-color");

        if (color != null) {
          try {
            return ColorUtils.colorForHex(color);
          } catch (e) {
            return TextConstants.defaultColor;
          }
        }
      }

      k = k.parent;
    }

    return null;
  }

  /// Searches the path to the root for the first occurance of a node with a
  /// color information. Returns [null] if no information is present
  Color? get textColor {
    NodeV2? k = this;

    while (k != null) {
      if (k.styleProperty != null) {
        StyleProperty prop = k.styleProperty!;

        dynamic color = prop.getProperty("color");

        if (color != null) {
          try {
            return ColorUtils.colorForHex(color);
          } catch (e) {
            return TextConstants.defaultColor;
          }
        }
      }

      k = k.parent;
    }

    return null;
  }

  /// is true, iff the node is an "a" node
  bool get isLink => hasTagInPath("a");

  /// is true, iff the tagname starts with an "h"
  bool get isHeader => parent!.tagName.startsWith("h");

  /// is true, iff the node is an "p" node
  bool get isParagraph {
    return parent!.tagName == "p";
  }

  /// contains the content of the "href" attribute, if present, null otherwise
  String? get linkTarget {
    NodeV2? k = this;

    while (k != null) {
      if (k.tagName == "a") {
        List<SimpleProperty> hrefs =
            k.properties.where((element) => element.name == "href").toList();

        if (hrefs.length > 0) {
          return hrefs.first.value;
        }

        return "";
      }

      k = k.parent;
    }

    return null;
  }

  /// searches the path for a specific tag [tag]
  bool hasTagInPath(String tag) => hasAnyTagInPath([tag]);

  /// searches the path for any tag specified in [tags] and returns true, iff
  /// one of the parent nodes contains at least one of these tags
  bool hasAnyTagInPath(List<String> tags) {
    NodeV2? k = this;

    while (k != null) {
      if (tags.contains(k.tagName)) return true;

      k = k.parent;
    }

    return false;
  }

  SimpleNode(NodeV2 parent, int textIndexStart, this.body)
      : super._(parent, "", "", []) {
    _textIndexStart = textIndexStart;
  }

  @override
  String toString() {
    return "<id=$id>$body</>";
  }
}

/// Contains information about a specific property of a tag.
class SimpleProperty {
  /// Name of the property. href="http://www.example.com" would have a name of
  /// "href"
  final String name;

  /// Value of the property. href="http://www.example.com" would have a value of
  /// "http://www.example.com"
  final dynamic value;

  String toHtml() => value;

  SimpleProperty(this.name, this.value);
}

/// Contains information of a specific style-attribute in a node. This class is
/// used to retrieve/add specific styling values from/to the attribute
class StyleProperty extends SimpleProperty {
  StyleProperty._(Map<String, dynamic> styleProperties)
      : super("style", styleProperties);

  /// adds a new property to the attribute, overwrites the value set if it
  /// already exists. Retuns true, if a new property was added.
  bool putProperty(String key, String sValue) {
    Map<String, dynamic> p = value;

    bool wasAdded = !p.containsKey(key);

    p[key] = sValue;

    return wasAdded;
  }

  /// Searches for a specific property. Returns null if it does not exist.
  dynamic getProperty(String key) {
    Map<String, dynamic> p = value;

    return p[key];
  }

  @override
  String toHtml() {
    String result = "";

    Map<String, dynamic> p = value;

    bool first = true;

    for (String key in p.keys) {
      if (!first)
        result += ";";
      else
        first = false;

      result += "$key:${p[key]}";
    }

    return result;
  }

  /// Decodes a style string to a specific map. This string can look like the
  /// following value: "font-size:12;color:#ffffff"
  factory StyleProperty.fromStyleString(String styleString) {
    Map<String, dynamic> styleProperties = {};

    List<String> sParts = styleString.split(";");
    for (String property in sParts) {
      List<String> parts = property.split(":");
      String key = parts[0].trim();
      String value = parts.length == 2 ? parts[1].trim() : "";

      if (key.isNotEmpty && value.isNotEmpty) styleProperties[key] = value;
    }

    return StyleProperty._(styleProperties);
  }
}
