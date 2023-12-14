import 'package:flutter/material.dart';
import 'package:light_html_editor/light_html_editor.dart';

class RendererExample extends StatelessWidget {
  const RendererExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SizedBox(
          width: 400,
          child: LightHtmlRenderer.fromRichtext(
            "<b>some text to be rendered as a RichText widget</b>",
            maxLength: 10,
            rendererDecoration: RendererStyle(
              overflowIndicator: "More...",
            ),
          ),
        ),
      ),
    );
  }
}
