## 0.4.3

* fix overflow issue in font color buttons
* fix linebreak issue on subtags
* updated dependencies

## 0.4.2

* various small API changes and adaptions

## 0.4.1

* added utility functions back
* added `LightHtmlParserV3` to the export

## 0.4.0

* renamed symbols
* reorganized editor widget to be less convoluted and verbose
* changed default selection behavior: if multiple nodes are edited/inserted, only the first affected node will hold the selection
* changed API and styling options of visual elements


## 0.3.3

* dependency updates

## 0.3.0

* added an enum to control what button-types are visible in the editor
* ensured that a `#` is added before every hex-color

## 0.2.0

* added the style-property `background-color`, that controls the `backgroundColor` attribute of the `Text` displayed
* changed the styling of the widget a bit, removed odd spacings

## 0.1.2

* added a fake `<sub>` tag that makes the font 1/2 of the default font, will be replaced by the actual subscript feature in the future

## 0.1.0

* Added error handling. Now, errors can be displayed in the renderer to indicate invalid HTML.
* Fixed linebreaks
* Added selection-persistence again

## 0.0.21

* Implemented a new parser to convert the raw HTML into a tree
* `Parser.cleanTagsFromRichtext(String)` and `Parser.replaceVariables(String, List<RichTextPlaceholder>, String)` are now static methods
* Added serialization of a `NodeV2` back to HTML enabling operations on the DOM directly instead of operating on the raw HTML
* Added graph analysis steps to not add unneccessary `<span>` tags if there is already a wrapping tag present
* Added property-operations. These add a property (currently style="..." to an existing tag, if the selection encloses a node fully)
* Added multi-node operations. If a random section of text is selected, multiple tags are added to the text in order to not break the DOM

## 0.0.20

* Applied padding of `EditorDecoration` to renderer preview
* Added undo-button that gets activated once a Tag has been inserted and undoes the insertion 

## 0.0.19

* Added possibility to define font-family

## 0.0.18

* Fixed ```showHeaderButton``` setting

## 0.0.17

* Added options to provide font-sizes for header tags
* Bumped version of ```url_launcher``` to version ```6.1.2```

## 0.0.16

* Added ```autofocus``` property to the Editor
* Various changes in styling

## 0.0.13

* Added ```maxLines``` property (to the Editor) to control how large the textfield can grow (null as default for infinite lines)
* Refactoring, extracted button row into its own component
* Widget takes all available height now

## 0.0.12

* Added ```maxLines``` property (to the Renderer) to control not only the length but also the maximum number of displayed lines
* Removed old linebreak system which worked with ```Column()``` and introduced RichText linebreaks.

## 0.0.11

* Workaround for a Flutter bug concerning the TextSelection property of TextEditingController

## 0.0.10

* Workaround for a Flutter bug concerning the TextSelection property of TextEditingController
* Added link support
* Added customizable indicator for overlong text in RichtextRenderer

## 0.0.9

* Bugfix where some initial empty space was shown

## 0.0.8

* Extracted Parsing into its own class where context is stored in the class' instance variables
* Fixed a parsing problem on nested strings

## 0.0.7

* changed style of editor buttons with InkWells for better UX
* changed parsing behaviour to better support linebreaks in tags
* added property to always show editor buttons if desired

## 0.0.6

* added maxHeight property to the renderer to have a scrolling preview when the content exceeds the desired maximum height
* added property to override the existing color-presets
* added option to pass a TextEditingController to the editor

## 0.0.5

* extracted logic to replace variables into parser class
* created aggregated import class to import all needed file at once
* added GitHub Link 

## 0.0.4

* fixed the link to the example image

## 0.0.3

* extracted styling properties into configuration classes

## 0.0.2

* Added maxLength property

## 0.0.1

* Initial Release

