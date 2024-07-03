**Update Notice:** With the now available
[lpm](https://github.com/lite-xl/lite-xl-plugin-manager) package manager, the
installation path for the Widgets has changed to: `{DATADIR}/libraries/widget`.
Users and package maintainers are encouraged to point the widgets library
to this new location as all plugins making use of it will be updated to use
the new location.

# Lite XL Widgets

A widgets plugin that can be used by plugin writers to more easily implement
interactive UI elements. The plugin leverages lite-xl __View__ system and
provides ready to use components to reduce code duplication for stuff that
most of the time is the same and simplify the process of writing your own
GUI controls.

## Some Features

* dragging
* floating view
* on hover event
* basic onclick event
* tooltip by using status view
* detection of widgets that don't need update or drawing which lowers cpu usage
* child widget coordinates calculations relative to the parent widget

Components currently provided by this plugin are:

* [Base Widget](init.lua)
* [Button](button.lua)
* [CheckBox](checkbox.lua)
* [ColorPicker](colorpicker.lua)
* [ColorPickerDialog](colorpickerdialog.lua)
* [Dialog](dialog.lua)
* [FilePicker](filepicker.lua)
* [FoldingBook](foldingbook.lua)
* [FontDialog](fontdialog.lua)
* [FontsList](fontslist.lua)
* [InputDialog](inputdialog.lua)
* [ItemsList](itemslist.lua)
* [KeybindDiialog](keybinddialog.lua)
* [Label](label.lua)
* [Line](line.lua)
* [ListBox](listbox.lua)
* [MessageBox](messagebox.lua)
* [NoteBook](notebook.lua)
* [NumberBox](numberbox.lua)
* [ProgressBar](progressbar.lua)
* [SelectBox](selectbox.lua)
* [TextBox](textbox.lua)
* [Toggle](toggle.lua)

You can also write your own re-usable components and share them back for
everyone to benefit by opening a Pull Request!

## Installation

Clone into the lite-xl configuration directory, for example on linux:

```sh
mkdir ~/.config/lite-xl/libraries
git clone https://github.com/lite-xl/lite-xl-widgets ~/.config/lite-xl/libraries/widget
```

## Usage

Until some form of documentation is written check the [examples](examples/)
directory which contains code samples to help you understand how to use the
plugin. A good starting point can be the [search mockup](examples/search.lua).

## Showcase Videos

Floating non blocking message boxes:

https://user-images.githubusercontent.com/1702572/160674291-cd13192d-d256-4a19-a641-166d4585be68.mp4

Floating parent widget with a ListBox inside:

https://user-images.githubusercontent.com/1702572/160674347-60d6d497-5612-4f5b-9d0d-65d417586c64.mp4

Non floating mockup of a search side bar:

https://user-images.githubusercontent.com/1702572/160674403-d0fcea4f-6b94-496c-b150-1c7372c93f29.mp4

A bottom NoteBook with tabs and various widgets inside.

https://user-images.githubusercontent.com/1702572/160674477-e89d4aa1-ce21-4e50-b1c7-b30ab58cbcde.mp4

ListBox with formatted text used in LSP plugin:

https://user-images.githubusercontent.com/1702572/160675168-c86dbcad-5b20-4f7c-9b07-7d092683ebb0.mp4
