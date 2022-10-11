import 'package:flutter/material.dart';
import 'package:light_html_editor/api/v2/printer.dart';
import 'package:light_html_editor/html_editor_controller.dart';
import 'package:light_html_editor/light_html_editor.dart';
import 'package:flutter_html/flutter_html.dart';

class RegularExample extends StatefulWidget {
  const RegularExample({Key? key}) : super(key: key);

  @override
  State<RegularExample> createState() => _RegularExampleState();
}

class _RegularExampleState extends State<RegularExample> {
  final controller = HtmlEditorController();
  Html htmlBox = Html(
    data: "",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SizedBox(
          width: 400,
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
            initialValue:
                'Read more at <a href="https://www.google.at">Google</a>',
          ),
        ),
      ),
    );
  }
}
