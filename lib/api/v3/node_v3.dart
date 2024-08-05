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

  /// path from this to root
  NodeV3 get root => pathToRoot.last;

  List<NodeV3> get pathToRoot {
    List<NodeV3> result = [];

    var k = this;

    while (!k.isRoot) {
      result.add(k);
      k = k.parent!;
    }

    result.add(k);

    return result;
  }

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

  /// creates a valid start-tag representation for this node (HTML)
  String get startHtmlTag {
    if (tag == null) return "";

    return tag!.rawTag;
  }

  void putStyleProperty(String stylePropertyKey, String value) {
    if (tag == null) {
      throw Exception("Cannot add style property to plaintext node!");
    }

    Tag t = tag!;
    t.styleProperties[stylePropertyKey] = value;
  }

  /// creates a valid end-tag representation for this node (HTML)
  String get endHtmlTag => tag == null ? "" : "</${tag!.name}>";

  String toHtml() {
    String html = startHtmlTag;

    if (content != null) html += content!;

    for (NodeV3 child in children) {
      html += child.toHtml();
    }

    return html + endHtmlTag;
  }

  NodeV3 deleteFromTree() {
    if (parent == null) {
      throw Exception("Cannot delete tree root!");
    }

    parent!.children.remove(this);

    return this;
  }

  void offset({
    int startOffset = 0,
    int endOffset = 0,
  }) {
    start += startOffset;
    end += endOffset;
  }

  NodeV3 insertTagNodeAbove(Tag tag) {
    int myIdx = parentIndex;
    deleteFromTree();

    NodeV3 nodeNew = NodeV3(
      scopeStart,
      scopeEnd,
      tag: tag,
      parent: parent,
    );

    parent!.addChild(nodeNew, myIdx);
    nodeNew.addChild(this);
    this.parent = nodeNew;

    return nodeNew;
  }

  int get parentIndex => parent == null ? -1 : parent!.children.indexOf(this);

  void splitForSelection(int selectionStart, int selectionEnd) {
    if (!hasPlaintextSelectionMatch(selectionStart, selectionEnd)) {
      throw Exception(
          "Selection ($selectionStart, $selectionEnd) has no match");
    }

    if (parent == null) {
      throw Exception("Cannot split root node");
    }

    List<int> splitPoints = [0];

    if (selectionStart > scopeStart) {
      splitPoints.add(selectionStart - scopeStart);
    }

    if (selectionEnd < scopeEnd) {
      splitPoints.add(selectionEnd - scopeStart);
    }

    splitPoints.add(scopeEnd - scopeStart);

    int myIdx = parentIndex;
    List<NodeV3> split = [];

    for (int i = 0; i < splitPoints.length - 1; i++) {
      int pStart = splitPoints[i];
      int pEnd = splitPoints[i + 1];

      String splitContent = content!.substring(pStart, pEnd);

      split.add(
        NodeV3(
          pStart + scopeStart,
          pEnd + scopeStart,
          content: splitContent,
          parent: parent,
        ),
      );
    }

    deleteFromTree();
    parent!.addChildren(split, myIdx);
  }

  List<NodeV3> select(int selectionStart, int selectionEnd) {
    if (hasPlaintextSelectionMatch(selectionStart, selectionEnd)) {
      return [this];
    }

    List<NodeV3> result = [];

    for (var child in children) {
      result.addAll(child.select(selectionStart, selectionEnd));
    }

    return result;
  }

  bool hasPlaintextSelectionMatch(int selectionStart, int selectionEnd) {
    return this.isPlaintext && isSelected(selectionStart, selectionEnd);
  }

  bool isFullySelected(int selectionStart, int selectionEnd) {
    return (selectionStart <= innerScopeStart && selectionEnd >= innerScopeEnd);
  }

  bool isSelected(int selectionStart, int selectionEnd) {
    return selectionEnd > scopeStart && selectionStart < scopeEnd;
  }

  int get innerScopeStart {
    if (!isTag) throw Exception("Plaintext nodes do not have inner scopes");

    return scopeStart + tag!.size;
  }

  int get innerScopeEnd {
    if (!isTag) throw Exception("Plaintext nodes do not have inner scopes");

    return scopeEnd - tag!.endTagSize;
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

  dynamic query(NodeQuery query, {int? maxDepth}) {
    NodeV3? k = this;

    int currentDepth = 0;

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

      currentDepth++;

      if (currentDepth == maxDepth) {
        return null;
      }
    }
  }

  void addChildren(List<NodeV3> elements, [int? position]) {
    if (position == null) {
      children.addAll(elements);
    } else {
      children.insertAll(position, elements);
    }
  }

  void addChild(NodeV3 child, [int? position]) {
    if (position == null) {
      children.add(child);
    } else {
      children.insert(position, child);
    }
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
