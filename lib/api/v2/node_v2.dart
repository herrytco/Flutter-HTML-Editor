import 'package:flutter/cupertino.dart';
import 'package:light_html_editor/api/richtext_node.dart';
import 'package:light_html_editor/data/color_utils.dart';

class NodeV2 {
  final String tag;

  final List<SimpleProperty> properties;

  final NodeV2? parent;
  final List<NodeV2> children = [];

  StyleProperty? _cacheStyleProperty;

  StyleProperty? get styleProperty {
    if (_cacheStyleProperty == null) {
      List<StyleProperty> style =
          properties.whereType<StyleProperty>().toList();

      if (style.isNotEmpty) _cacheStyleProperty = style.first;
    }

    return _cacheStyleProperty;
  }

  String get prettyTag {
    String props = "";

    for (SimpleProperty p in properties) {
      props += " ${p.name}:${p.value}";
    }

    return "<$tag$props>";
  }

  NodeV2._(
    this.parent,
    this.tag,
    this.properties,
  );

  factory NodeV2.root() {
    return NodeV2._(null, "", []);
  }

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

    return NodeV2._(parent, tag.name, properties);
  }

  double? _fontSize(Map<String, double> tagSizes) {
    // 1. check a dedicated style-tag
    if (styleProperty != null) {
      if (styleProperty!.value["font-size"] != null)
        return double.tryParse(styleProperty!.value["font-size"]!);
    }

    // 2. check if it is a predefined tag
    if (tagSizes.containsKey(tag)) return tagSizes[tag]!;

    return null;
  }
}

class SimpleNode extends NodeV2 {
  final String body;

  FontWeight get fontWeight {
    NodeV2? k = this;

    while (k != null) {
      if (k.tag == "b" || k.tag.startsWith("h")) return FontWeight.bold;

      if (k.styleProperty != null) {
        StyleProperty prop = k.styleProperty!;

        dynamic weight = prop.getProperty("font-weight");

        if (weight == "bold") return FontWeight.bold;
      }

      k = k.parent;
    }

    return FontWeight.normal;
  }

  TextDecoration get textDecoration {
    NodeV2? k = this;

    while (k != null) {
      if (k.tag == "u") return TextDecoration.underline;

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

  double fontSize(Map<String, double> sizes) {
    NodeV2? k = parent;

    while (k != null) {
      double? fontSize = k._fontSize(sizes);

      if (fontSize != null) return fontSize;

      k = k.parent;
    }

    return sizes[""]!;
  }

  bool get isLink => hasTagInPath("a");

  bool get isHeader {
    return parent!.tag.startsWith("h");
  }

  bool get isParagraph {
    return parent!.tag == "p";
  }

  String? get linkTarget {
    NodeV2? k = this;

    while (k != null) {
      if (k.tag == "a") {
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

  bool hasTagInPath(String tag) => hasAnyTagInPath([tag]);

  bool hasAnyTagInPath(List<String> tags) {
    NodeV2? k = this;

    while (k != null) {
      if (tags.contains(k.tag)) return true;

      k = k.parent;
    }

    return false;
  }

  Color? get textColor {
    NodeV2? k = this;

    while (k != null) {
      if (k.styleProperty != null) {
        StyleProperty prop = k.styleProperty!;

        dynamic color = prop.getProperty("color");

        if (color != null) return ColorUtils.colorForHex(color);
      }

      k = k.parent;
    }

    return null;
  }

  SimpleNode(NodeV2 parent, this.body) : super._(parent, "", []);
}

class SimpleProperty {
  final String name;
  final dynamic value;

  SimpleProperty(this.name, this.value);
}

class StyleProperty extends SimpleProperty {
  StyleProperty._(Map<String, dynamic> styleProperties)
      : super("style", styleProperties);

  dynamic getProperty(String key) {
    Map<String, dynamic> p = value;

    return p[key];
  }

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
