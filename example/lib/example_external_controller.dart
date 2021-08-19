import 'package:flutter/material.dart';
import 'package:light_html_editor/editor.dart';

class ExternalControllerDemo extends StatefulWidget {
  const ExternalControllerDemo({Key? key}) : super(key: key);

  @override
  _ExternalControllerDemoState createState() => _ExternalControllerDemoState();
}

class _ExternalControllerDemoState extends State<ExternalControllerDemo> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text =
        "<h1>Headline!</h1>and other text injected and controlled via outside.";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: RichTextEditor(
            controller: _controller,
          ),
        ),
      ),
    );
  }
}
