## 0.0.19

* Added possibility to define font-family.

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

