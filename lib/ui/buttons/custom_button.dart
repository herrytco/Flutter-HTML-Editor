import 'package:flutter/material.dart';

///
/// Editor-button where the content of the button is freely settable
///
class FontCustomButton extends StatelessWidget {
  // empty click handler
  static void _doNothing() {}

  ///
  /// Creates a new button with [icon] as the content
  ///
  const FontCustomButton({
    Key? key,
    this.onClick = _doNothing,
    this.icon = const SizedBox(),
  }) : super(key: key);

  /// button content
  final Widget icon;

  /// What to do if the button is clicked
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => onClick(),
          child: Center(
            child: icon,
          ),
        ),
      ),
    );
  }
}
