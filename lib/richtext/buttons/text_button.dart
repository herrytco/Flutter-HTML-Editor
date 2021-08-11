import 'package:flutter/material.dart';

///
/// Editor-button where the content of the button is a string
///
class FontTextButton extends StatelessWidget {
  // empty click handler
  static void _doNothing() {}

  ///
  /// Creates a new button with [icon] as a child (text)
  ///
  const FontTextButton({
    Key? key,
    this.onClick = _doNothing,
    this.icon = "Label",
  }) : super(key: key);

  /// string displayed in the button
  final String icon;

  /// What to do if the button is clicked
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(
            color: Colors.black,
          ),
        ),
        width: 30,
        height: 30,
        child: Center(
          child: Text(
            icon,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
