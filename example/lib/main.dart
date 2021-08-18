import 'package:flutter/material.dart';
import 'package:light_html_editor/editor.dart';
import 'package:light_html_editor/placeholder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTML Editor Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
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
              availableColors: ["#ff00ff"],
              onChanged: (String html) {
                // do something with the richtext
              },
            ),
          ),
        ),
      ),
    );
  }
}
