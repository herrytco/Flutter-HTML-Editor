import 'package:flutter/material.dart';
import 'package:light_html_editor/ui/buttons/custom_button.dart';

///
/// Editor-button where the content of the button is a string
///
class FontIconButton extends StatelessWidget {
  // empty click handler
  static void _doNothing() {}

  ///
  /// Creates a new button with [icon] as a child (text)
  ///
  const FontIconButton(
    this.icon, {
    Key? key,
    this.onClick = _doNothing,
  }) : super(key: key);

  /// string displayed in the button
  final IconData icon;

  /// What to do if the button is clicked
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return FontCustomButton(
      onClick: onClick,
      icon: Icon(icon),
    );
  }
}
