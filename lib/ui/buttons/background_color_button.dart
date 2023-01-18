import 'package:flutter/material.dart';
import 'package:light_html_editor/ui/buttons/custom_button.dart';
import 'package:light_html_editor/data/color_utils.dart';

///
/// Editor-button where the content of the button is an "A" with a color-bar
/// at the bottom of it.
///
class FontBackgroundColorButton extends StatelessWidget {
  // empty click handler
  static void _doNothing() {}

  ///
  /// Creates a new button with an "A" in the center, and a bar with the color
  /// [color] underneath. If no arguments are passed, it defaults to black.
  ///
  const FontBackgroundColorButton({
    Key? key,
    this.hexCode = "#000000",
    this.color = Colors.black,
    this.onClick = _doNothing,
  }) : super(key: key);

  ///
  /// creates a [FontColorButton] from the HTML-color definition alone, which is
  /// then parsed to a Material Color
  ///
  factory FontBackgroundColorButton.fromColor(String color, Function onClick) =>
      FontBackgroundColorButton(
        hexCode: color,
        color: ColorUtils.colorForHex(color),
        onClick: onClick,
      );

  /// HTML representation
  final String hexCode;

  /// Material representation
  final Color color;

  /// What to do if the button is clicked
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return FontCustomButton(
      onClick: onClick,
      icon: Stack(
        children: [
          Container(
            color: color,
            margin: EdgeInsets.all(3),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "A",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
