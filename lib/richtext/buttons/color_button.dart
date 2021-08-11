import 'package:flutter/material.dart';
import 'package:html_editor/richtext/buttons/custom_button.dart';
import 'package:html_editor/richtext/color_utils.dart';

///
/// Editor-button where the content of the button is an "A" with a color-bar
/// at the bottom of it.
///
class FontColorButton extends StatelessWidget {
  // empty click handler
  static void _doNothing() {}

  ///
  /// Creates a new button with an "A" in the center, and a bar with the color
  /// [color] underneath. If no arguments are passed, it defaults to black.
  ///
  const FontColorButton({
    Key? key,
    this.hexCode = "#000000",
    this.color = Colors.black,
    this.onClick = _doNothing,
  }) : super(key: key);

  ///
  /// creates a [FontColorButton] from the HTML-color definition alone, which is
  /// then parsed to a Material Color
  ///
  factory FontColorButton.fromColor(String color, Function onClick) =>
      FontColorButton(
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
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "A",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          FractionallySizedBox(
            widthFactor: .9,
            child: Container(
              width: double.infinity,
              height: 5,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
