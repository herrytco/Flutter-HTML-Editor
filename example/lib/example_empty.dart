import 'package:flutter/material.dart';
import 'package:light_html_editor/html_editor_controller.dart';
import 'package:light_html_editor/light_html_editor.dart';
import 'package:flutter_html/flutter_html.dart';

class EmptyExample extends StatefulWidget {
  const EmptyExample({Key? key}) : super(key: key);

  @override
  State<EmptyExample> createState() => _EmptyExampleState();
}

class _EmptyExampleState extends State<EmptyExample> {
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
          width: 800,
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
                'regular text<h1>Header <p>asfdasdfasdfasdasdf</p> jköljlkjöljkölkjöj</h1>should have its own line',
          ),
        ),
      ),
    );
  }
}
