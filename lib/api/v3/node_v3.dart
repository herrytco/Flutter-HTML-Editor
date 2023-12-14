import 'package:light_html_editor/api/tag.dart';

class NodeV3 {
  NodeV3? parent;

  ///
  /// start index (inclusive), end index (exclusive)
  ///
  int start, end;
  final Tag? tag;
  final String? content;

  bool get isFirstChild => (parent == null) || (parent!.children.first == this);
  bool get isLastChild => (parent == null) || (parent!.children.last == this);

  /// Children nodes.
  final List<NodeV3> children = [];

  NodeV3(
    this.start,
    this.end, {
    this.tag,
    this.content,
    this.parent,
  }) {
    if (tag != null && content != null)
      throw Exception("content and tag cannot both be != null");
  }

  int get scopeStart => start;

  int get scopeEnd {
    int result = end;

    int latestChild = children.isNotEmpty
        ? children
            .map((e) => e.scopeEnd)
            .reduce((value, element) => element > value ? element : value)
        : 0;

    if (latestChild > result) result = latestChild;

    return result + (tag != null ? tag!.endTagSize : 0);
  }

  ///
  /// used to group possible multiple tags on the root level under one node
  ///
  factory NodeV3.root() => NodeV3(0, 0);

  Tag? findFirstTag(List<String> tagList) {
    NodeV3? k = this;

    while (k != null) {
      if (k.tag != null) {
        if (tagList.contains(k.tag!.name)) {
          return k.tag;
        }
      }

      k = k.parent;
    }

    return null;
  }

  dynamic query(NodeQuery query) {
    NodeV3? k = this;

    while (k != null) {
      if (k.tag != null) {
        if (query.includedTypes.contains(QueryType.tag)) {
          if (query.includedValues.contains(k.tag!.name)) {
            return k.tag!.name;
          }
        }

        if (query.includedTypes.contains(QueryType.property)) {
          List<String> intersection = List<String>.from(query.includedValues);
          intersection.removeWhere(
            (element) => !k!.tag!.properties.containsKey(element),
          );

          if (intersection.isNotEmpty) {
            return k.tag!.properties[intersection.first];
          }
        }

        if (query.includedTypes.contains(QueryType.styleProperty)) {
          List<String> intersection = List<String>.from(query.includedValues);
          intersection.removeWhere(
            (element) => !k!.tag!.styleProperties.containsKey(element),
          );

          if (intersection.isNotEmpty) {
            return k.tag!.styleProperties[intersection.first];
          }
        }
      }

      k = k.parent;
    }
  }

  void addChild(NodeV3 child) {
    children.add(child);
  }

  bool get hasChildren => children.isNotEmpty;

  bool get isRoot => parent == null;

  bool get isPlaintext => content != null;
  bool get isTag => !isPlaintext;

  String get face {
    if (isRoot) return "ROOT";
    if (tag == null) return "<>";
    return tag!.name;
  }

  int get height {
    var childHeight = children.isEmpty
        ? -1
        : children
            .reduce((value, element) =>
                element.height > value.height ? element : value)
            .height;

    return childHeight + 1;
  }

  void printTree({int spaceOffset = 0}) {
    print(" " * spaceOffset + "$this");

    for (var child in children) {
      child.printTree(spaceOffset: spaceOffset + 2);
    }
  }

  @override
  String toString() {
    if (isPlaintext)
      return "$face ($start, $end): $content";
    else
      return "$face ($start, $end)";
  }
}

enum QueryType { property, styleProperty, tag }

class NodeQuery {
  final List<QueryType> includedTypes;
  final List<String> includedValues;

  NodeQuery(this.includedTypes, this.includedValues);
}
