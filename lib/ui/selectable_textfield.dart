import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:light_html_editor/data/editor_properties.dart';

///
/// Widget that serves as a temporary solution for the Flutter bug, where
/// TextEditingController.selection does not work properly anymore on web.
///
class SelectableTextfield extends StatefulWidget {
  ///
  /// initializes a new [SelectableTextfield].
  ///
  /// [editorDecoration] contains style information for the textfield to look
  /// properly.
  ///
  /// [controller] handles selection changes
  ///
  /// [focusNode] is used to check if the field is focused or not
  ///
  /// [onSelectionChange] is fired each time the selection changes to notify the
  /// caller
  ///
  const SelectableTextfield(
    this.editorDecoration,
    this.controller,
    // this.onSelectionChange,
    this.focusNode, {
    Key? key,
    this.maxLength,
    required this.autofocus,
  }) : super(key: key);

  final bool autofocus;
  final int? maxLength;
  final EditorDecoration editorDecoration;
  final TextEditingController controller;
  final FocusNode focusNode;

  // final Function(TextSelection) onSelectionChange;

  @override
  _SelectableTextfieldState createState() => _SelectableTextfieldState();
}

class _SelectableTextfieldState extends State<SelectableTextfield> {
  @override
  void initState() {
    // widget.controller.addListener(() {
    //   if (widget.focusNode.hasFocus)
    //     widget.onSelectionChange(widget.controller.selection);
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: widget.autofocus,
      buildCounter: (
        context, {
        int? currentLength,
        bool? isFocused,
        int? maxLength,
      }) {
        if (currentLength != null && widget.maxLength != null)
          return Text(
            "$currentLength/${widget.maxLength}",
            style: widget.editorDecoration.labelStyle,
          );

        if (currentLength != null)
          return Text(
            "$currentLength",
            style: widget.editorDecoration.labelStyle,
          );

        return SizedBox();
      },
      controller: widget.controller,
      focusNode: widget.focusNode,
      maxLines: widget.editorDecoration.maxLines,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        isDense: true,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        counterText: "",
        contentPadding: EdgeInsets.symmetric(vertical: 14.0),
      ),
      cursorColor: widget.editorDecoration.cursorColor,
      style: GoogleFonts.getFont('Ubuntu Mono').copyWith(
        color: widget.editorDecoration.inputStyle.color,
      ),
    );
  }
}
