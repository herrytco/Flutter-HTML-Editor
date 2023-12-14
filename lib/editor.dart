import 'package:flutter/material.dart';
import 'package:light_html_editor/ui/button_row.dart';
import 'package:light_html_editor/data/text_constants.dart';
import 'package:light_html_editor/light_html_editor.dart';

import 'api/html_editor_controller.dart';

///
/// Lightweight HTML editor with optional preview function. Uses all width
/// available and the minimal height. Needs bounded width.
///
class LightHtmlRichTextEditor extends StatefulWidget {
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
  /// If [animatePreviewToEditorPosition] is set AND [showPreview] is true, the
  /// preview will scroll along with the text input of the editor.
  ///
  /// It is possible to use placeholders in the code. They have to be enclosed
  /// with [placeholderMarker]. If the marker is set to "$" for example, it could
  /// look like $VARIABLE$, which would get substituted in the richtext.
  ///
  /// Per default, all button types are displayed above the editor textfield.
  /// [availableButtons] can be provided to specify the visible buttons
  ///
  const LightHtmlRichTextEditor({
    Key? key,
    this.labelTextStyle,
    this.showPreview = true,
    this.initialValue,
    this.maxLength,
    this.placeholderMarker = "\\\$",
    this.placeholders = const [],
    this.onChanged = LightHtmlRichTextEditor._doNothingWithResult,
    this.editorDecoration = const EditorDecoration(),
    this.availableColors = TextConstants.defaultColors,
    this.alwaysShowButtons = false,
    this.controller,
    this.additionalActionButtons,
    this.animatePreviewToEditorPosition = true,
    this.autofocus = false,
    this.previewDecoration = const RendererStyle(),
    this.availableButtons = ButtonRowType.values,
  }) : super(key: key);
  final TextStyle? labelTextStyle;
  final bool autofocus;
  final bool showPreview;
  final String? initialValue;
  final int? maxLength;
  final String placeholderMarker;
  final List<RichTextPlaceholder> placeholders;
  final List<String> availableColors;
  final bool alwaysShowButtons;
  final bool animatePreviewToEditorPosition;
  final List<Widget>? additionalActionButtons;
  final List<ButtonRowType> availableButtons;

  final EditorDecoration editorDecoration;
  final LightHtmlEditorController? controller;

  final RendererStyle previewDecoration;

  final void Function(String valueNew) onChanged;

  @override
  _LightHtmlRichTextEditorState createState() =>
      _LightHtmlRichTextEditorState();
}

class _LightHtmlRichTextEditorState extends State<LightHtmlRichTextEditor> {
  /// used to control the HTML text and cursor position/selection
  late LightHtmlEditorController _controller;

  /// focusNode of the editor input field
  FocusNode _focusNode = FocusNode();

  /// handles visibility of editor-controls
  bool _areButtonsVisible = false;

  ScrollController _previewScrollController = ScrollController();

  @override
  void initState() {
    _controller = widget.controller ?? LightHtmlEditorController();
    _controller.text = widget.initialValue ?? "";

    _controller.addListener(() {
      setState(() {
        widget.onChanged(_controller.text);
      });
    });

    _areButtonsVisible = widget.alwaysShowButtons;

    // initialize event handler for hiding buttons
    if (!widget.alwaysShowButtons)
      _focusNode.addListener(() {
        setState(() {
          _areButtonsVisible = _focusNode.hasFocus;
        });
      });

    _setupAutoScroll();

    super.initState();
  }

  ///
  /// initialize event handler for new input
  ///
  /// animate to the currently edited line in the preview
  ///
  void _setupAutoScroll() {
    if (widget.previewDecoration.autoScroll && widget.showPreview) {
      _controller.addListener(() {
        // get last character
        int position = _controller.selection.extentOffset;

        if (position > 0) {
          String lastChar =
              _controller.text[_controller.selection.extentOffset - 1];

          if (lastChar == "\n" || true) {
            List<String> lines = _controller.text.split("\n");
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
                _previewScrollController.position.maxScrollExtent *
                    scrollAmount,
                duration: Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
              );
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.editorDecoration.backgroundColor,
      child: Column(
        children: [
          if (_areButtonsVisible) ...[
            ButtonRow(
              _controller,
              widget.availableColors,
              widget.additionalActionButtons ?? [],
              decoration: widget.editorDecoration,
              availableButtons: widget.availableButtons,
            ),
            SizedBox(height: widget.editorDecoration.buttonEditorSpacing),
          ],
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        widget.editorDecoration.editorLabel ?? "Raw",
                        style: widget.labelTextStyle,
                      ),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: widget.editorDecoration.borderRadius,
                            border: widget.editorDecoration.border,
                          ),
                          child: LightHtmlEditorTextField(
                            autofocus: widget.autofocus,
                            editorDecoration: widget.editorDecoration,
                            onChanged: widget.onChanged,
                            controller: _controller,
                            initialValue: widget.initialValue,
                            maxLength: widget.maxLength,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.showPreview) ...[
                  SizedBox(width: widget.editorDecoration.editorPreviewSpacing),
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.previewDecoration.label ?? "Preview",
                            style: widget.labelTextStyle,
                          ),
                          Expanded(
                            child: LightHtmlRenderer.fromRichtext(
                              _controller.text,
                              placeholders: widget.placeholders,
                              placeholderMarker: widget.placeholderMarker,
                              rendererDecoration: widget.previewDecoration,
                              scrollController: _previewScrollController,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
