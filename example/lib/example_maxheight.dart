import 'package:flutter/material.dart';
import 'package:light_html_editor/light_html_editor.dart';

class MaxHeightExample extends StatelessWidget {
  const MaxHeightExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Container(
          width: 500,
          height: 600,
          color: Colors.blue,
          padding: EdgeInsets.all(8),
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
