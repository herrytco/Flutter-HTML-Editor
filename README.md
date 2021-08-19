# Flutter HTML Editor

Flutter HTML Editor is a simple HTML-based Richtext editor, which is able to edit and parse a selected set of HTML tags into a Flutter widget. 

Check out the [some usage examples](https://github.com/herrytco/Flutter-HTML-Editor/tree/main/example/lib) to see how the package can be used.

## Features

- Code Editor where HTML text can be written with an optional preview output
- Richtext-Renderer which takes in HTML produced by the editor and converts it into a widget
- Customization options for Editor and Renderer
- Use Variables in the text 

## Usage

1. Import the package ```import 'package:html_editor/editor.dart';``` for the editor or ```import 'package:html_editor/renderer.dart';``` for the renderer
2. Create an environment with a **finite width**, as the widgets will take up all available horizontal space
3. Instantiate ```RichTextEditor``` or ```RichTextRenderer```
4. Set desired parameters like the ```onChanged``` callbacks for retrieving the richtext

## Example


### Simple usage without fancy settings

    SizedBox(
        width: 400,
        child: RichTextEditor(
            onChanged: (String html) {
                // called every time the code in the input text is changed
                // do something with the richtext
            },
        ),
    ),

![Example Output of Flutter HTML Editor](https://github.com/herrytco/Flutter-HTML-Editor/blob/9b8d90fc9b42300e87449a1d3021179fdd35317b/.doc/example1.png?raw=true)

### Variables

    SizedBox(
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

![Example Output with variables](https://github.com/herrytco/Flutter-HTML-Editor/blob/main/.doc/example2.png?raw=true)