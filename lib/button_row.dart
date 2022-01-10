import 'package:flutter/material.dart';
import 'package:light_html_editor/ui/buttons/color_button.dart';
import 'package:light_html_editor/ui/buttons/custom_button.dart';
import 'package:light_html_editor/ui/buttons/icon_button.dart';

class ButtonRow extends StatelessWidget {
  const ButtonRow(
      this.wrapWithTag, this.wrapWithStartAndEnd, this.availableColors,
      {Key? key})
      : super(key: key);

  final Function(String) wrapWithTag;
  final Function(String, String) wrapWithStartAndEnd;
  final List<String> availableColors;

  /// wraps the current selection with <b></b>
  void _onBold() => wrapWithTag("b");

  /// wraps the current selection with <i></i>
  void _onItalics() => wrapWithTag("i");

  /// wraps the current selection with <u></u>
  void _onUnderline() => wrapWithTag("u");

  /// wraps the current selection with <p></p>
  void _onParagraph() => wrapWithTag("p");

  /// wraps the current selection with <h1></h1>
  void _onH1() => wrapWithTag("h1");

  /// wraps the current selection with <h2></h2>
  void _onH2() => wrapWithTag("h2");

  /// wraps the current selection with <h3></h3>
  void _onH3() => wrapWithTag("h3");

  /// wraps the current selection with <span style="color:[hex]"></span>
  void _onColor(String hex) =>
      wrapWithStartAndEnd('<span style="color:$hex;">', '</span>');

  void _onLink() => wrapWithStartAndEnd('<a href="">', '</a>');

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
          for (String color in availableColors)
            FontColorButton.fromColor(color, () => _onColor(color)),
        ],
      ),
    );
  }
}
