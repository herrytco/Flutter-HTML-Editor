import 'package:flutter/material.dart';
import 'package:light_html_editor/light_html_editor.dart';

class LinkExample extends StatelessWidget {
  const LinkExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SizedBox(
          width: 400,
          child: LightHtmlRichTextEditor(
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
            initialValue:
                'Read more at <a href="https://www.google.at">Google</a>',
          ),
        ),
      ),
    );
  }
}
