import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:light_html_editor/placeholder.dart';
import 'package:light_html_editor/ui/buttons/color_button.dart';
import 'package:light_html_editor/ui/buttons/custom_button.dart';
import 'package:light_html_editor/renderer.dart';
import 'package:light_html_editor/data/editor_properties.dart';
import 'package:light_html_editor/data/renderer_properties.dart';
import 'package:light_html_editor/data/text_constants.dart';
import 'package:light_html_editor/ui/buttons/icon_button.dart';
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
    this.showPreview = true,
    this.showHeaderButton = true,
    this.initialValue,
    this.maxLength,
    this.placeholderMarker = "\\\$",
    this.placeholders = const [],
    this.onChanged = RichTextEditor._doNothingWithResult,
    this.previewDecoration = const RendererDecoration(
      label: "Preview",
      labelStyle: TextConstants.labelStyle,
    ),
    this.editorDecoration = const EditorDecoration(),
    this.availableColors = TextConstants.defaultColors,
    this.alwaysShowButtons = false,
    this.controller,
  }) : super(key: key);

  final bool showPreview;
  final bool showHeaderButton;
  final String? initialValue;
  final int? maxLength;
  final String placeholderMarker;
  final List<RichTextPlaceholder> placeholders;
  final List<String> availableColors;
  final TextEditingController? controller;
  final bool alwaysShowButtons;

  final RendererDecoration previewDecoration;
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

  @override
  void initState() {
    _areButtonsVisible = widget.alwaysShowButtons;

    if (widget.controller != null) _textEditingController = widget.controller!;

    if (_textEditingController.text.isEmpty)
      _textEditingController.text = widget.initialValue ?? "";

    if (!widget.alwaysShowButtons)
      _focusNode.addListener(() {
        setState(() {
          _areButtonsVisible = _focusNode.hasFocus;
        });
      });

    _textEditingController.addListener(() {
      setState(() {});

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

  /// wraps the current selection with <b></b>
  void _onBold() => _wrapWithTag("b");

  /// wraps the current selection with <i></i>
  void _onItalics() => _wrapWithTag("i");

  /// wraps the current selection with <u></u>
  void _onUnderline() => _wrapWithTag("u");

  /// wraps the current selection with <p></p>
  void _onParagraph() => _wrapWithTag("p");

  /// wraps the current selection with <h1></h1>
  void _onH1() => _wrapWithTag("h1");

  /// wraps the current selection with <h2></h2>
  void _onH2() => _wrapWithTag("h2");

  /// wraps the current selection with <h3></h3>
  void _onH3() => _wrapWithTag("h3");

  /// wraps the current selection with <span style="color:[hex]"></span>
  void _onColor(String hex) =>
      _wrapWithStartAndEnd('<span style="color:$hex;">', '</span>');

  void _onLink() => _wrapWithStartAndEnd('<a href="">', '</a>');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.editorDecoration.backgroundColor,
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
                  FontCustomButton(
                    onClick: _onBold,
                    icon: Text(
                      "B",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FontCustomButton(
                    onClick: _onItalics,
                    icon: Text(
                      "I",
                      style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  FontCustomButton(
                    onClick: _onUnderline,
                    icon: Text(
                      "U",
                      style: TextStyle(
                        fontSize: 20,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  FontCustomButton(
                    onClick: _onParagraph,
                    icon: Text(
                      "P",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  FontCustomButton(
                    onClick: _onH1,
                    icon: Text(
                      "H1",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  FontCustomButton(
                    onClick: _onH2,
                    icon: Text(
                      "H2",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  FontCustomButton(
                    onClick: _onH3,
                    icon: Text(
                      "H3",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  FontIconButton(
                    Icons.link,
                    onClick: _onLink,
                  ),
                  for (String color in widget.availableColors)
                    FontColorButton.fromColor(color, () => _onColor(color)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableTextfield(
              widget.editorDecoration,
              _textEditingController,
              (TextSelection selection) => _selection = selection,
              _focusNode,
              maxLength: widget.maxLength,
            ),
          ),
          if (widget.showPreview)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: RichtextRenderer.fromRichtext(
                _textEditingController.text,
                rendererDecoration: widget.previewDecoration,
                placeholders: widget.placeholders,
                placeholderMarker: widget.placeholderMarker,
              ),
            ),
        ],
      ),
    );
  }
}
