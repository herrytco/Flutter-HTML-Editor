import 'package:flutter/material.dart';

///
/// Editor-button where the content of the button is an asset-image.
///
class FontIconButton extends StatelessWidget {
  // empty click handler
  static void _doNothing() {}

  ///
  /// Creates a new button with an AssetImage of path [icon]
  ///
  const FontIconButton({
    Key? key,
    this.onClick = _doNothing,
    this.icon = "Label",
  }) : super(key: key);

  /// path to the image
  final String icon;

  /// What to do if the button is clicked
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(
            color: Colors.black,
          ),
        ),
        width: 30,
        height: 30,
        child: Image.asset(
          icon,
          fit: BoxFit.cover,
          package: "light_html_editor",
        ),
      ),
    );
  }
}
