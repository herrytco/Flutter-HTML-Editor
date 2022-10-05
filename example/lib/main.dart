import 'package:example/example_empty.dart';

import 'package:flutter/material.dart';

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
      home: EmptyExample(),
    );
  }
}
