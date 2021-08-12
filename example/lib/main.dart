import 'package:flutter/material.dart';
import 'package:html_editor/editor.dart';
import 'package:html_editor/renderer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTML Editor Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            child: RichTextEditor(
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
