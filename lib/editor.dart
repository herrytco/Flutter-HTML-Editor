import 'dart:math';

import 'package:flutter/material.dart';
import 'package:light_html_editor/button_row.dart';
import 'package:light_html_editor/data/editor_properties.dart';
import 'package:light_html_editor/data/text_constants.dart';
import 'package:light_html_editor/placeholder.dart';
import 'package:light_html_editor/renderer.dart';
import 'package:light_html_editor/ui/selectable_textfield.dart';

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
    this.textStyle,
    this.showPreview = true,
    this.showHeaderButton = true,
    this.initialValue,
    this.maxLength,
    this.placeholderMarker = "\\\$",
    this.placeholders = const [],
    this.onChanged = RichTextEditor._doNothingWithResult,
    this.editorDecoration = const EditorDecoration(),
    this.availableColors = TextConstants.defaultColors,
    this.alwaysShowButtons = false,
    this.controller,
  }) : super(key: key);
  final TextStyle? textStyle;
  final bool showPreview;
  final bool showHeaderButton;
  final String? initialValue;
  final int? maxLength;
  final String placeholderMarker;
  final List<RichTextPlaceholder> placeholders;
  final List<String> availableColors;
  final TextEditingController? controller;
  final bool alwaysShowButtons;

  final EditorDecoration editorDecoration;

  final Function(String) onChanged;

  @override
  _RichTextEditorState createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  /// used to control the HTML text and cursor position/selection
  TextEditingController _textEditingController = TextEditingController();

  /// focusNode of the editor input field
  FocusNode _focusNode = FocusNode();

  /// handles visibility of editor-controls
  bool _areButtonsVisible = false;

  // currently selected text
  TextSelection? _selection;

  ScrollController _previewScrollController = ScrollController();

  @override
  void initState() {
    _areButtonsVisible = widget.alwaysShowButtons;

    // use external controller, if provided
    if (widget.controller != null) _textEditingController = widget.controller!;

    // copy in initial value if provided
    if (_textEditingController.text.isEmpty)
      _textEditingController.text = widget.initialValue ?? "";

    // initialize event handler for hiding buttons
    if (!widget.alwaysShowButtons)
      _focusNode.addListener(() {
        setState(() {
          _areButtonsVisible = _focusNode.hasFocus;
        });
      });

    // initialize event handler for new input
    _textEditingController.addListener(() {
      setState(() {});

      widget.onChanged(_textEditingController.text);

      // get last character
      int position = _textEditingController.selection.extentOffset;

      if (position > 0) {
        String lastChar = _textEditingController
            .text[_textEditingController.selection.extentOffset - 1];

        if (lastChar == "\n" || true) {
          List<String> lines = _textEditingController.text.split("\n");
          int buffer = 0, lineIndex = -1;

          for (int i = 0; i < lines.length; i++) {
            String line = lines[i];

            buffer += line.length + 1;

            if (buffer > position) {
              lineIndex = i;
              break;
            }
          }

          if (lineIndex > 0) {
            double scrollAmount = lineIndex / (lines.length - 1);

            _previewScrollController.animateTo(
              _previewScrollController.position.maxScrollExtent * scrollAmount,
              duration: Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
            );
          }
        }
      }
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
    TextSelection? selection = _selection;

    int start = selection == null
        ? -1
        : min(selection.baseOffset, selection.extentOffset);
    int end = selection == null
        ? -1
        : max(selection.baseOffset, selection.extentOffset);

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

    _selection = _textEditingController.selection;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.editorDecoration.backgroundColor,
      width: double.infinity,
      child: Column(
        children: [
          if (_areButtonsVisible)
            ButtonRow(
              _wrapWithTag,
              _wrapWithStartAndEnd,
              widget.availableColors,
            ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Content",
                        style: widget.textStyle,
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Container(
                        constraints: BoxConstraints(
                            maxHeight: 445, minHeight: 60, maxWidth: 659),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 8.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        child: SelectableTextfield(
                          widget.editorDecoration,
                          _textEditingController,
                          (TextSelection selection) => _selection = selection,
                          _focusNode,
                          maxLength: widget.maxLength,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 4.0,
                ),
                if (widget.showPreview)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Preview",
                          style: widget.textStyle,
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        SingleChildScrollView(
                          controller: _previewScrollController,
                          child: Container(
                            constraints: BoxConstraints(
                                maxHeight: 445, minHeight: 60, maxWidth: 659),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            child: RichtextRenderer.fromRichtext(
                              _textEditingController.text,
                              placeholders: widget.placeholders,
                              placeholderMarker: widget.placeholderMarker,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
