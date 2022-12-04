# EditorConfig

This plugin implements the [EditorConfig](https://editorconfig.org/) spec
purely on lua by leveraging lua patterns and the regex engine on lite-xl.
Installing additional dependencies is not required.

The EditorConfig spec was implemented as best understood,
if you find any bugs please report them on this repository
[issue tracker](https://github.com/lite-xl/lite-xl-plugins/issues).

## Implemented Features

Global options:

* root - prevents upward searching of .editorconfig files

Applied to documents indent info:

* indent_style
* indent_size
* tab_width

Applied on document save:

* end_of_line - if set to `cr` it is ignored
* trim_trailing_whitespace
* insert_final_newline boolean

## Not implemented

* charset - this feature would need the encoding
  [PR](https://github.com/lite-xl/lite-xl/pull/1161) or
  [plugin](https://github.com/jgmdev/lite-xl-encoding)

## Extras

* Supports multiple project directories
* Implements hot reloading, so modifying an .editorconfig file from within
  the editor will re-apply all rules to currently opened files.
