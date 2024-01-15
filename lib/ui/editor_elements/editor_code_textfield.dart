import 'package:flutter/material.dart';
import 'package:light_html_editor/data/editor_properties.dart';
import 'package:light_html_editor/api/html_editor_controller.dart';

import 'package:light_html_editor/ui/selectable_textfield.dart';

class LightHtmlEditorTextField extends StatefulWidget {
  const LightHtmlEditorTextField({
    Key? key,
    this.controller,
    this.maxLength,
    this.initialValue,
    this.scrollController,
    required this.onChanged,
    required this.autofocus,
    required this.editorDecoration,
  }) : super(key: key);

  final EditorDecoration editorDecoration;
  final LightHtmlEditorController? controller;
  final int? maxLength;
  final bool autofocus;
  final String? initialValue;
  final void Function(String valueNew) onChanged;
  final ScrollController? scrollController;

  @override
  State<LightHtmlEditorTextField> createState() =>
      _LightHtmlEditorTextFieldState();
}

class _LightHtmlEditorTextFieldState extends State<LightHtmlEditorTextField> {
  late LightHtmlEditorController _controller;

  final _focusNode = FocusNode();

  @override
  void initState() {
    _controller = widget.controller ?? new LightHtmlEditorController();
    _controller.editorFocusNode = _focusNode;

    // setup new controller if none was provided
    if (widget.controller == null) {
      _controller.addListener(() {
        setState(() {
          widget.onChanged(_controller.text);
        });
      });
      if (_controller.text.isEmpty)
        _controller.text = widget.initialValue ?? "";
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: SelectableTextfield(
        widget.editorDecoration,
        _controller,
        _focusNode,
        maxLength: widget.maxLength,
        autofocus: widget.autofocus,
        scrollController: widget.scrollController,
      ),
    );
  }
}
