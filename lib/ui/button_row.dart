import 'package:flutter/material.dart';
import 'package:light_html_editor/api/operations/property_operation.dart';
import 'package:light_html_editor/api/operations/tag_operation.dart';
import 'package:light_html_editor/data/editor_properties.dart';
import 'package:light_html_editor/api/html_editor_controller.dart';
import 'package:light_html_editor/ui/buttons/background_color_button.dart';
import 'package:light_html_editor/ui/buttons/color_button.dart';
import 'package:light_html_editor/ui/buttons/custom_button.dart';
import 'package:light_html_editor/ui/buttons/icon_button.dart';

///
/// one entry per displayable button-type in editor
///
enum ButtonRowType {
  bold,
  italics,
  underline,
  paragraph,
  link,
  headers,
  colors,
  backgroundColors,
}

///
/// A row of buttons controlling text-operations available in the editor
///
class ButtonRow extends StatelessWidget {
  const ButtonRow(
    this.controller,
    this.availableColors,
    this.additionalButtons, {
    Key? key,
    this.availableButtons = ButtonRowType.values,
    required this.decoration,
  }) : super(key: key);

  final List<String> availableColors;
  final List<Widget> additionalButtons;
  final LightHtmlEditorController controller;
  final EditorDecoration decoration;
  final List<ButtonRowType> availableButtons;

  /// wraps the current selection with <b></b>
  void _onBold() => controller.wrapWithTag("b");

  /// wraps the current selection with <i></i>
  void _onItalics() => controller.wrapWithTag("i");

  /// wraps the current selection with <u></u>
  void _onUnderline() => controller.wrapWithTag("u");

  /// wraps the current selection with <p></p>
  void _onParagraph() => controller.wrapWithTag("p");

  /// wraps the current selection with <h1></h1>
  void _onH1() => controller.wrapWithTag("h1");

  /// wraps the current selection with <h2></h2>
  void _onH2() => controller.wrapWithTag("h2");

  /// wraps the current selection with <h3></h3>
  void _onH3() => controller.wrapWithTag("h3");

  /// wraps the current selection with <span style="color:[hex]"></span>
  void _onColor(String hex) {
    hex = hex.startsWith("#") ? hex : "#" + hex;
    controller.insertStyleProperty(StylePropertyOperation("color", hex));
  }

  /// wraps the current selection with <span style="background-color:[hex]"></span>
  void _onBackgroundColor(String hex) {
    hex = hex.startsWith("#") ? hex : "#" + hex;
    controller
        .insertStyleProperty(StylePropertyOperation("background-color", hex));
  }

  void _onLink() =>
      controller.wrapWithStartAndEnd(TagOperation('<a href="">', '</a>', 'a'));

  void _onUndo() => controller.undo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      width: double.infinity,
      // color: decoration.backgroundColor,
      child: Wrap(
        spacing: 1,
        runSpacing: 1,
        children: [
          if (availableButtons.contains(ButtonRowType.bold))
            FontCustomButton(
              onClick: _onBold,
              icon: Text(
                "B",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: decoration.buttonColor,
                ),
              ),
            ),
          if (availableButtons.contains(ButtonRowType.italics))
            FontCustomButton(
              onClick: _onItalics,
              icon: Text(
                "I",
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: decoration.buttonColor,
                ),
              ),
            ),
          if (availableButtons.contains(ButtonRowType.underline))
            FontCustomButton(
              onClick: _onUnderline,
              icon: Text(
                "U",
                style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                  color: decoration.buttonColor,
                ),
              ),
            ),
          if (availableButtons.contains(ButtonRowType.paragraph))
            FontCustomButton(
              onClick: _onParagraph,
              icon: Text(
                "P",
                style: TextStyle(
                  fontSize: 20,
                  color: decoration.buttonColor,
                ),
              ),
            ),
          if (availableButtons.contains(ButtonRowType.headers)) ...[
            FontCustomButton(
              onClick: _onH1,
              icon: Text(
                "H1",
                style: TextStyle(
                  fontSize: 20,
                  color: decoration.buttonColor,
                ),
              ),
            ),
            FontCustomButton(
              onClick: _onH2,
              icon: Text(
                "H2",
                style: TextStyle(
                  fontSize: 20,
                  color: decoration.buttonColor,
                ),
              ),
            ),
            FontCustomButton(
              onClick: _onH3,
              icon: Text(
                "H3",
                style: TextStyle(
                  fontSize: 20,
                  color: decoration.buttonColor,
                ),
              ),
            ),
          ],
          if (availableButtons.contains(ButtonRowType.link))
            FontIconButton(
              Icons.link,
              onClick: _onLink,
              color: decoration.buttonColor,
            ),
          if (availableButtons.contains(ButtonRowType.colors))
            for (String color in availableColors)
              FontColorButton.fromColor(
                color,
                () => _onColor(color),
              ),
          if (availableButtons.contains(ButtonRowType.backgroundColors))
            for (String color in availableColors)
              FontBackgroundColorButton.fromColor(
                color,
                () => _onBackgroundColor(color),
              ),
          if (controller.canUndo)
            FontIconButton(
              Icons.undo,
              onClick: _onUndo,
              color: decoration.buttonColor,
            ),
          ...additionalButtons,
        ],
      ),
    );
  }
}
