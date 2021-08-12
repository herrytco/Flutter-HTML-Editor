import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:light_html_editor/placeholder.dart';
import 'package:light_html_editor/richtext/buttons/color_button.dart';
import 'package:light_html_editor/richtext/buttons/font_button.dart';
import 'package:light_html_editor/richtext/buttons/text_button.dart';
import 'package:light_html_editor/renderer.dart';
import 'package:light_html_editor/richtext/richtext_node.dart';
import 'package:light_html_editor/richtext/text_constants.dart';

///
/// Lightweight HTML editor with optional preview function. Uses all width
/// available and the minimal height. Needs bounded width.
///
class RichTextEditor extends StatefulWidget {
  ///
  /// empty method
  ///
  static void _doNothingWithResult(String value) => {};

  ///
  /// Creates a new instance of a HTML text editor.
  /// [editorLabel] is displayed at the text input, styled by [labelStyle] when
  /// not focused, styled by [focusedLabelStyle] else
  ///
  /// [cursorColor] is the color of the cursor of the text input
  ///
  /// [inputStyle] text-style of the written code
  ///
  /// A rendered preview is displayed, when [showPreview] is set to [true], with
  /// an optional [previewLabel] is displayed below it
  ///
  /// [onChanged] is called each time, the HTML input changes providing the
  /// written code as parameter
  ///
  /// An optional [maxLength] can be provided, which is applied in the code input,
  /// not at the rendered text.
  ///
  /// If [initialValue] is set, the provided text is loaded into the editor.
  /// 
  /// It is possible to use placeholders in the code. They have to be enclosed
  /// with [placeholderMarker]. If the marker is set to "$" for example, it could
  /// look like $VARIABLE$, which would get substituted in the richtext. 
  ///
  const RichTextEditor({
    Key? key,
    this.editorLabel,
    this.backgroundColor = Colors.white,
    this.cursorColor = Colors.black,
    this.inputStyle = TextConstants.labelStyle,
    this.labelStyle = TextConstants.labelStyle,
    this.focusedLabelStyle = TextConstants.labelStyle,
    this.previewLabelStyle = TextConstants.labelStyle,
    this.showPreview = true,
    this.previewLabel = "Preview",
    this.onChanged = RichTextEditor._doNothingWithResult,
    this.maxLength,
    this.initialValue,
    this.placeholderMarker = "\\\$",
    this.placeholders = const [],
  }) : super(key: key);

  final Color backgroundColor;
  final Color cursorColor;
  final String? editorLabel;
  final bool showPreview;
  final String previewLabel;
  final String? initialValue;
  final TextStyle previewLabelStyle;
  final TextStyle inputStyle;
  final TextStyle labelStyle;
  final TextStyle focusedLabelStyle;
  final int? maxLength;
  final String placeholderMarker;
  final List<RichTextPlaceholder> placeholders;

  final Function(String) onChanged;

  @override
  _RichTextEditorState createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  /// used to control the HTML text and cursor position/selection
  TextEditingController _textEditingController = TextEditingController();

  /// focusNode of the editor input field
  FocusNode _focusNode = FocusNode();

  /// root of the parse-tree
  DocumentNode? _node;

  /// handles visibility of editor-controls
  bool _areButtonsVisible = false;

  @override
  void initState() {
    _textEditingController.text = widget.initialValue ?? "";

    _focusNode.addListener(() {
      setState(() {
        _areButtonsVisible = _focusNode.hasFocus;
      });
    });

    _textEditingController.addListener(() {
      setState(() {
        _node = Parser().parse(_textEditingController.text);
      });

      widget.onChanged(_textEditingController.text);
    });
    super.initState();
  }

  ///
  /// wraps the current text-selection with the provided tags. If no text is
  /// selected, an empty tag-pair is inserted at the current cursor position.
  /// If the field is not focused, the empty tag-pair is appended to the current
  /// text.
  ///
  /// Start- and End-Tag do not have to be the same, allowing properties in the
  /// tag.
  ///
  void _wrapWithStartAndEnd(String startTag, String endTag) {
    TextSelection selection = _textEditingController.selection;

    int start = min(selection.baseOffset, selection.extentOffset);
    int end = max(selection.baseOffset, selection.extentOffset);

    String before = _textEditingController.text;
    String after;

    if (before.length == 0) {
      after = "$startTag$endTag";
    } else if (start == -1 && end == -1) {
      after = "$before$startTag$endTag";
    } else if (start == end) {
      if (start == 0)
        after = "$startTag$endTag$before";
      else {
        String a = before.substring(0, start);
        String b = before.substring(start);

        after = "$a$startTag$endTag$b";
      }
    } else {
      String a = before.substring(0, start);
      String b = before.substring(start, end);
      String c = before.substring(end);

      after = "$a$startTag$b$endTag$c";
    }

    _textEditingController.text = after;

    if (!_focusNode.hasFocus) FocusScope.of(context).requestFocus(_focusNode);

    if (before.length == 0) {
      _textEditingController.selection = TextSelection(
        baseOffset: startTag.length,
        extentOffset: startTag.length,
      );
    } else if (start == -1 && end == -1) {
      _textEditingController.selection = TextSelection(
        baseOffset: "$before$startTag".length,
        extentOffset: "$before$startTag".length,
      );
    } else if (start == end) {
      if (start == 0)
        _textEditingController.selection = TextSelection(
          baseOffset: startTag.length,
          extentOffset: startTag.length,
        );
      else {
        String a = before.substring(0, start);

        _textEditingController.selection = TextSelection(
          baseOffset: "$a$startTag".length,
          extentOffset: "$a$startTag".length,
        );
      }
    } else {
      String a = before.substring(0, start);
      String b = before.substring(start, end);

      _textEditingController.selection = TextSelection(
        baseOffset: "$a$startTag".length,
        extentOffset: "$a$startTag$b".length,
      );
    }
  }

  ///
  /// wraps the current text-selection a symmetric pair of tags. If no text is
  /// selected, an empty tag-pair is inserted at the current cursor position.
  /// If the field is not focused, the empty tag-pair is appended to the current
  /// text.
  ///
  void _wrapWithTag(String tagname) {
    String startTag = "<$tagname>";
    String endTag = "</$tagname>";

    _wrapWithStartAndEnd(startTag, endTag);
  }

  /// wraps the current selection with <b></b>
  void _onBold() => _wrapWithTag("b");

  /// wraps the current selection with <i></i>
  void _onItalics() => _wrapWithTag("i");

  /// wraps the current selection with <u></u>
  void _onUnderline() => _wrapWithTag("u");

  /// wraps the current selection with <h1></h1>
  void _onH1() => _wrapWithTag("h1");

  /// wraps the current selection with <h2></h2>
  void _onH2() => _wrapWithTag("h2");

  /// wraps the current selection with <h3></h3>
  void _onH3() => _wrapWithTag("h3");

  /// wraps the current selection with <span style="color:[hex]"></span>
  void _onColor(String hex) =>
      _wrapWithStartAndEnd('<span style="color:$hex;">', '</span>');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_areButtonsVisible)
            Container(
              padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
              width: double.infinity,
              child: Wrap(
                children: [
                  FontIconButton(
                    onClick: _onBold,
                    icon: "assets/icons/editor/bold.png",
                  ),
                  FontIconButton(
                    onClick: _onItalics,
                    icon: "assets/icons/editor/italics.png",
                  ),
                  FontIconButton(
                    onClick: _onUnderline,
                    icon: "assets/icons/editor/underline.png",
                  ),
                  FontTextButton(
                    onClick: _onH1,
                    icon: "H1",
                  ),
                  FontTextButton(
                    onClick: _onH2,
                    icon: "H2",
                  ),
                  FontTextButton(
                    onClick: _onH3,
                    icon: "H3",
                  ),
                  for (String color in TextConstants.colors)
                    FontColorButton.fromColor(color, () => _onColor(color)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              buildCounter: (
                context, {
                int? currentLength,
                bool? isFocused,
                int? maxLength,
              }) {
                if (currentLength != null && widget.maxLength != null)
                  return Text(
                    "$currentLength/${widget.maxLength}",
                    style: widget.labelStyle,
                  );

                if (currentLength != null)
                  return Text(
                    "$currentLength",
                    style: widget.labelStyle,
                  );

                return SizedBox();
              },
              controller: _textEditingController,
              focusNode: _focusNode,
              minLines: 1,
              maxLines: 8,
              maxLength: widget.maxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: InputDecoration(
                labelText: widget.editorLabel,
                labelStyle: _focusNode.hasFocus
                    ? widget.focusedLabelStyle
                    : widget.labelStyle,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
              ),
              cursorColor: widget.cursorColor,
              style: widget.inputStyle,
            ),
          ),
          if (widget.showPreview)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichtextRenderer(
                root: _node,
                label: widget.previewLabel,
                labelStyle: widget.previewLabelStyle,
                placeholders: widget.placeholders,
                placeholderMarker: widget.placeholderMarker,
              ),
            ),
        ],
      ),
    );
  }
}
