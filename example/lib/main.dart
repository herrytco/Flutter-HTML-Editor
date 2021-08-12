import 'package:flutter/material.dart';
import 'package:light_html_editor/editor.dart';
import 'package:light_html_editor/placeholder.dart';
import 'package:light_html_editor/renderer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String rich =
      '<h1>1234567890</h1><b><i>abcdefghij</i></b><span style="color:#ff0000;">1234567890</span>abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij';

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
            child: RichtextRenderer.fromRichtext(
              rich,
              maxLength: 10,
            ),
            // child: RichTextEditor(
            //   placeholders: [
            //     RichTextPlaceholder(
            //         "VAR", "Some longer text that got shortened!"),
            //   ],
            //   onChanged: (String html) {
            //     // do something with the richtext
            //   },
            // ),
          ),
        ),
      ),
    );
  }
}
