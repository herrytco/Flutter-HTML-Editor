import 'package:flutter/material.dart';
import 'package:light_html_editor/light_html_editor.dart';

class RegularExample extends StatelessWidget {
  const RegularExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SizedBox(
          child: RichTextEditor(
            placeholders: [
              RichTextPlaceholder(
                "VAR",
                "Some longer text that got shortened!",
              ),
            ],
            onChanged: (String html) {
              // do something with the richtext
            },
            alwaysShowButtons: true,
          ),
        ),
      ),
    );
  }
}
