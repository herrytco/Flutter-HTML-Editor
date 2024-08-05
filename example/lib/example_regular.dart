import 'package:flutter/material.dart';
import 'package:light_html_editor/api/html_editor_controller.dart';
import 'package:light_html_editor/light_html_editor.dart';
import 'package:flutter_html/flutter_html.dart';

class RegularExample extends StatefulWidget {
  const RegularExample({Key? key}) : super(key: key);

  @override
  State<RegularExample> createState() => _RegularExampleState();
}

class _RegularExampleState extends State<RegularExample> {
  final controller = LightHtmlEditorController();
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
            availableColors: [
              "000000",
            ],
            editorDecoration: EditorDecoration(
              inputStyle: TextStyle(
                color: Colors.blue,
              ),
            ),
            alwaysShowButtons: true,
            initialValue:
                '<h2>Demon Shard: <b style="color:#00ff00;">Emerald</b></h2>',
          ),
        ),
      ),
    );
  }
}
