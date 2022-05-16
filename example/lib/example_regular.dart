import 'package:flutter/material.dart';
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
  Html htmlBox = Html(data: "startwert");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 800,
              width: 1000,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RichTextEditor(
                      controller: controller,
                      availableColors: [],
                      placeholders: [
                        RichTextPlaceholder(
                          "VAR",
                          "Some longer text that got shortened!",
                        ),
                      ],
                      onChanged: (String html) {
                        setState(() {
                          this.htmlBox = Html(
                            data: html,
                            key: UniqueKey(),
                          );
                        });
                      },
                      alwaysShowButtons: true,
                      showPreview: false,
                      showHeaderButton: true,
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    height: 500,
                    child: htmlBox,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.insertAtCursor("Hello world!");
              },
              child: const Text("Insert hello world at cursor"),
            ),
            Text(htmlBox.data ?? ""),
          ],
        ),
      ),
    );
  }
}
