import 'package:flutter/material.dart';
import 'package:light_html_editor/html_editor_controller.dart';
import 'package:light_html_editor/ui/buttons/color_button.dart';
import 'package:light_html_editor/ui/buttons/custom_button.dart';
import 'package:light_html_editor/ui/buttons/icon_button.dart';

class ButtonRow extends StatelessWidget {
  const ButtonRow(
    this.controller,
    this.availableColors,
    this.additionalButtons, {
    Key? key,
  }) : super(key: key);

  final List<String> availableColors;
  final List<Widget> additionalButtons;
  final HtmlEditorController controller;

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
  void _onColor(String hex) =>
      controller.wrapWithStartAndEnd('<span style="color:$hex;">', '</span>');

  void _onLink() => controller.wrapWithStartAndEnd('<a href="">', '</a>');

  @override
  Widget build(BuildContext context) {
    return Container(
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
                color: Colors.black,
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
                color: Colors.black,
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
                color: Colors.black,
              ),
            ),
          ),
          FontCustomButton(
            onClick: _onParagraph,
            icon: Text(
              "P",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          FontCustomButton(
            onClick: _onH1,
            icon: Text(
              "H1",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          FontCustomButton(
            onClick: _onH2,
            icon: Text(
              "H2",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          FontCustomButton(
            onClick: _onH3,
            icon: Text(
              "H3",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          FontIconButton(
            Icons.link,
            onClick: _onLink,
          ),
          for (String color in availableColors)
            FontColorButton.fromColor(
              color,
              () => _onColor(color),
            ),
          ...additionalButtons,
        ],
      ),
    );
  }
}
