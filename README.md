Plugins for [Lite XL](https://github.com/franko/lite-xl)

*Note: if you make a pull request, the table should be updated and kept in
alphabetical order. If your plugin is large (or you'd otherwise prefer it to
have its own repo), the table can simply be updated to add a link to the repo;
otherwise the plugin file itself can be submitted. If a plugin's link resolves
to something other than a raw file it should be marked with an asterisk.
If a plugin has modifications specific to Lite XL or is otherwise incompatible
with the official version of lite, format the name in italic.*

---

Plugin | Description
-------|-----------------------------------------
[`autoinsert`](plugins/autoinsert.lua?raw=1) | Automatically inserts closing brackets and quotes. Also allows selected text to be wrapped with brackets or quotes.
*[`autosave`](plugins/autosave.lua?raw=1)* | Automatically saves files when they are changed
*[`autosaveonfocuslost`](plugins/autosaveonfocuslost.lua?raw=1)* | Automatically saves files that were changed when the main window loses focus by switching to another application
[`autowrap`](plugins/autowrap.lua?raw=1) | Automatically hardwraps lines when typing
*[`bigclock`](plugins/bigclock.lua?raw=1)* | Shows the current time and date in a view with large text *([screenshot](https://user-images.githubusercontent.com/3920290/82752891-3318df00-9db9-11ea-803f-261d80d5cf53.png))*
[`black`](https://git.sr.ht/~tmpod/black-lite)* | Integrates the [black](https://github.com/psf/black) Python formatter with lite
[`bracketmatch`](plugins/bracketmatch.lua?raw=1) | Underlines matching pair for bracket under the caret *([screenshot](https://user-images.githubusercontent.com/3920290/80132745-0c863f00-8594-11ea-8875-c455c6fd7eae.png))*
[`centerdoc`](plugins/centerdoc.lua?raw=1) | Centers document's content on the screen *([screenshot](https://user-images.githubusercontent.com/3920290/82127896-bf6e4500-97ae-11ea-97fc-ba9a552bc9a4.png))*
~~[`closeconfirmx`](plugins/closeconfirmx.lua?raw=1)~~ | Replaced by NagView dialog ~~Replaces a system close confirmation dialog with a command view, like for individual files *([screenshot](https://user-images.githubusercontent.com/1689801/107596774-afa76280-6c53-11eb-80ab-22e73058c097.png))*~~
[`colorpreview`](plugins/colorpreview.lua?raw=1) | Underlays color values (eg. `#ff00ff` or `rgb(255, 0, 255)`) with their resultant color. *([screenshot](https://user-images.githubusercontent.com/3920290/80743752-731bd780-8b15-11ea-97d3-847db927c5dc.png))*
*[`console`](https://github.com/franko/console)* | A console for running external commands and capturing their output *([gif](https://user-images.githubusercontent.com/3920290/81343656-49325a00-90ad-11ea-8647-ff39d8f1d730.gif))*
[`contextmenu`](https://github.com/takase1121/lite-contextmenu)* | Simple context menu *([screenshot](https://github.com/takase1121/lite-contextmenu/blob/master/assets/screenshot.jpg?raw=true))*
*[`copyfilelocation`](plugins/copyfilelocation.lua?raw=1)* | Copy file location to clipboard
[`datetimestamps`](plugins/datetimestamps.lua?raw=1) | Insert date-, time- and date-time-stamps
~~[`detectindent`](plugins/detectindent.lua?raw=1)~~ | Included with lite-xl ~~Automatically detects and uses the indentation size and tab type of a loaded file~~
*[`discord-presence`](https://github.com/vincens2005/lite-xl-discord)** | Adds the current workspace and file to your Discord Rich Presence
[`dragdropselected`](plugins/dragdropselected.lua?raw=1) | Provides basic drag and drop of selected text (in same document)
~~*[`drawwhitespace`](plugins/drawwhitespace.lua?raw=1)*~~ | Integrated with lite-xl reducing CPU usage ~~Draws tabs and spaces *([screenshot](https://user-images.githubusercontent.com/3920290/80573013-22ae5800-89f7-11ea-9895-6362a1c0abc7.png))*~~
[`eofnewline`](https://github.com/bokunodev/lite_modules/blob/master/plugins/eofnewline-xl.lua?raw=1) | Make sure the file ends with one blank line.
[`eval`](plugins/eval.lua?raw=1) | Replaces selected Lua code with its evaluated result
[`exec`](plugins/exec.lua?raw=1) | Runs selected text through shell command and replaces with result
[`ephemeraldocviews`](plugins/ephemeraldocviews.lua?raw=1) | Preview tabs. Opening a doc will replace the contents of the preview tab. Marks tabs as non-preview on any change.
[`fallbackfonts`](https://github.com/takase1121/lite-fallback-fonts)* | Adds support for fallback fonts *([gif](https://raw.githubusercontent.com/takase1121/lite-fallback-fonts/master/assets/Iw18fI57J0.gif))*
[`fontconfig`](plugins/fontconfig.lua?raw=1) | Allows users to load fonts with [fontconfig](https://www.freedesktop.org/software/fontconfig/fontconfig-user.html).
[`formatter`](https://github.com/vincens2005/lite-formatters)* | formatters for various languages
[`ghmarkdown`](plugins/ghmarkdown.lua?raw=1) | Opens a preview of the current markdown file in a browser window *([screenshot](https://user-images.githubusercontent.com/3920290/82754898-f7394600-9dc7-11ea-8278-2305363ed372.png))*
*[`gitdiff_highlight`](https://github.com/vincens2005/lite-xl-gitdiff-highlight)** | highlight changed lines from git *([screenshot](https://raw.githubusercontent.com/vincens2005/lite-xl-gitdiff-highlight/master/screenshot.png))*
*[`gitstatus`](plugins/gitstatus.lua?raw=1)* | Displays git branch and insert/delete count in status bar *([screenshot](https://user-images.githubusercontent.com/3920290/81107223-bcea3080-8f0e-11ea-8fc7-d03173f42e33.png))*
[`gofmt`](plugins/gofmt.lua?raw=1) | Auto-formats the current go file, adds the missing imports and the missing return cases
[`hidelinenumbers`](plugins/hidelinenumbers.lua?raw=1) | Hides the line numbers on the left of documents *([screenshot](https://user-images.githubusercontent.com/3920290/81692043-b8b19c00-9455-11ea-8d74-ad99be4b9c5f.png))*
[`hidestatus`](plugins/hidestatus.lua?raw=1) | Hides the status bar at the bottom of the window
~~[`inanimate`](plugins/inanimate.lua?raw=1)~~ | Integrated in lite-xl using `config.transitions = false` ~~Disables all transition animations~~
*[`indentguide`](plugins/indentguide.lua?raw=1)* | Adds indent guides *([screenshot](https://user-images.githubusercontent.com/3920290/79640716-f9860000-818a-11ea-9c3b-26d10dd0e0c0.png))*
*[`Kinc Projects`](https://github.com/Kode-Community/kinc_plugin)** | Adds [Kinc](https://github.com/Kode/Kinc) Project generation with basic build commands(depends on [`console`](https://github.com/franko/console))
[`language_angelscript`](plugins/language_angelscript.lua?raw=1) | Syntax for the [Angelscript](https://www.angelcode.com/angelscript/) programming language
[`language_batch`](plugins/language_batch.lua?raw=1) | Syntax for Windows [Batch Files](https://en.wikipedia.org/wiki/Batch_file)
[`language_bib`](plugins/language_bib.lua?raw=1) | Syntax for [BibTex](https://en.wikipedia.org/wiki/BibTeX) files
[`language_cmake`](plugins/language_cmake.lua?raw=1) | Syntax for the CMake build system language
[`language_cpp`](plugins/language_cpp.lua?raw=1) | Syntax for the [C++](https://isocpp.org/) programming language
[`language_csharp`](plugins/language_csharp.lua?raw=1) | Syntax for the [C#](http://csharp.net) programming language
[`language_d`](plugins/language_d.lua?raw=1) | Syntax for the [D](https://dlang.org/) programming language
[`language_dart`](plugins/language_dart.lua?raw=1) | Syntax for the [Dart](https://dart.dev/) programming languiage
[`language_elixir`](plugins/language_elixir.lua?raw=1) | Syntax for the [Elixir](https://elixir-lang.org) programming language
[`language_elm`](plugins/language_elm.lua?raw=1) | Syntax for the [Elm](https://elm-lang.org) programming language
[`language_fe`](plugins/language_fe.lua?raw=1) | Syntax for the [fe](https://github.com/rxi/fe) programming language
[`language_fennel`](plugins/language_fennel.lua?raw=1) | Syntax for the [fennel](https://fennel-lang.org) programming language
[`language_gdscript`](plugins/language_gdscript.lua?raw=1) | Syntax for the [Godot Engine](https://godotengine.org/)'s GDScript scripting language
[`language_glsl`](plugins/language_glsl.lua?raw=1) | Syntax for the [GLSL](https://www.khronos.org/registry/OpenGL/specs/gl/) programming language
[`language_go`](plugins/language_go.lua?raw=1) | Syntax for the [Go](https://golang.org/) programming language
[`language_hlsl`](plugins/language_hlsl.lua?raw=1) | Syntax for the [HLSL](https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl) programming language
[`language_hs`](plugins/language_hs.lua?raw=1) | Syntax for the [Haskell](https://www.haskell.org/) programming language
[`language_ini`](plugins/language_ini.lua?raw=1) | Syntax for [ini](https://en.wikipedia.org/wiki/INI_file) files
[`language_java`](plugins/language_java.lua?raw=1) | Syntax for the [Java](https://en.wikipedia.org/wiki/Java_(programming_language)) programming language
[`language_jiyu`](plugins/language_jiyu.lua?raw=1) | Syntax for the [jiyu](https://github.com/machinamentum/jiyu) programming language
[`language_jsx`](plugins/language_jsx.lua?raw=1) | Syntax for the [JSX](https://reactjs.org/docs/introducing-jsx.html) language for the React framework in JavaScript
[`language_ksy`](https://raw.githubusercontent.com/whiteh0le/lite-plugins/main/plugins/language_ksy.lua?raw=1) | Syntax for [Kaitai](http://kaitai.io/) struct files
[`language_liquid`](plugins/language_liquid.lua?raw=1) | Syntax for [Liquid](https://shopify.github.io/liquid/) templating language
[`language_lobster`](plugins/language_lobster.lua?raw=1) | Syntax for [Lobster](https://strlen.com/lobster/) programming language
[`language_make`](plugins/language_make.lua?raw=1) | Syntax for the Make build system language
[`language_meson`](plugins/language_meson.lua?raw=1) | Syntax for the [Meson](https://mesonbuild.com) build system language
[`language_moon`](plugins/language_moon.lua?raw=1) | Syntax for the [MoonScript](https://moonscript.org) scripting language
[`language_nginx`](plugins/language_nginx.lua?raw=1) | Syntax for [Nginx](https://www.nginx.com/) config files
[`language_nim`](plugins/language_nim.lua?raw=1) | Syntax for the [Nim](https://nim-lang.org) programming language
[`language_objc`](plugins/language_objc.lua?raw=1) | Syntax for the [Objective C](https://en.wikipedia.org/wiki/Objective-C) programming language
[`language_odin`](plugins/language_odin.lua?raw=1) | Syntax for the [Odin](https://github.com/odin-lang/Odin) programming language
[`language_perl`](plugins/language_perl.lua?raw=1) | Syntax for the [Perl](https://perl.org) programming language
[`language_php`](plugins/language_php.lua?raw=1) | Syntax for the [PHP](https://php.net) programming language
[`language_pico8`](plugins/language_pico8.lua?raw=1) | Syntax for [Pico-8](https://www.lexaloffle.com/pico-8.php) cartridge files
[`language_po`](plugins/language_po.lua?raw=1) | Syntax for [PO](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html) translation files
[`language_pony`*](https://github.com/MrAnyx/lite-plugin-pony) | Syntax for [Pony](https://www.ponylang.io/) programming language
[`language_powershell`](plugins/language_powershell.lua?raw=1) | Syntax for [PowerShell](https://docs.microsoft.com/en-us/powershell) scripting language
[`language_psql`](plugins/language_psql.lua?raw=1) | Syntax for the postgresql database access language
[`language_r`](plugins/language_R.lua?raw=1) | Syntax for [R](https://www.r-project.org/) scripting language
[`language_rescript`](plugins/language_rescript.lua?raw=1) | Syntax for the [ReScript](https://rescript-lang.org/) programming language
[`language_rust`](plugins/language_rust.lua?raw=1) | Syntax for the [Rust](https://rust-lang.org/) programming language
[`language_ruby`](plugins/language_ruby.lua?raw=1) | Syntax for the [Ruby](https://www.ruby-lang.org/) programming language
[`language sass`](plugins/language_sass.lua?raw=1) | Syntax for the [Sass](https://sass-lang.com/) CSS preprocessor
[`language_sh`](plugins/language_sh.lua?raw=1) | Syntax for shell scripting language
[`language_tcl`](plugins/language_tcl.lua?raw=1) | Syntax for the [Tcl](https://www.tcl.tk/) programming language
[`language_teal`](plugins/language_teal.lua?raw=1) | Syntax for the [Teal](https://github.com/teal-language/tl) programming language, a typed dialect of Lua.
[`language_ts`](plugins/language_ts.lua?raw=1) | Syntax for the [TypeScript](https://www.typescriptlang.org/) programming language, a typed dialect of JavaScript.
[`language_tex`](plugins/language_tex.lua?raw=1) | Syntax for the [LaTeX](https://www.latex-project.org/) typesetting language
[`language_toml`](plugins/language_toml.lua?raw=1) | Syntax for the [TOML](https://toml.io/en/) configuration language
[`language_tsx`](plugins/language_tsx.lua?raw=1) | Syntax for [TSX](https://www.typescriptlang.org/docs/handbook/jsx.html) language
[`language_v`](plugins/language_v.lua?raw=1) | Syntax for the [V](https://vlang.io/) programming language
[`language_wren`](plugins/language_wren.lua?raw=1) | Syntax for the [Wren](http://wren.io/) programming language
[`language_yaml`](plugins/language_yaml.lua?raw=1) | Syntax for [YAML](https://yaml.org/) serialization language
[`language_zig`](plugins/language_zig.lua?raw=1) | Syntax for the [Zig](https://ziglang.org/) programming language
~~[`lastproject`](plugins/lastproject.lua?raw=1)~~ | Integrated with lite-xl ~~Loads the last loaded project if lite is launched without any arguments~~
[`lfautoinsert`](plugins/lfautoinsert.lua?raw=1) | Automatically inserts indentation and closing bracket/text after newline
[`linecopypaste`](plugins/linecopypaste.lua?raw=1) | Copy, cut and paste the current line when nothing is selected
~~[*`lineguide`*](plugins/lineguide.lua?raw=1)~~ | Integrated with lite-xl ~~Displays a line-guide at the line limit offset *([screenshot](https://user-images.githubusercontent.com/3920290/81476159-2cf70000-9208-11ea-928b-9dae3884c477.png))*~~
[`linenumbers`](plugins/linenumbers.lua?raw=1) | The ability to change the display of the line number *([screenshot](https://user-images.githubusercontent.com/5556081/129493788-6a4cbd7a-9074-4133-bab7-110ed55f18f7.png))*
[`linter`](https://github.com/drmargarido/linters)* | Linters for multiple languages
[`lint+`](https://github.com/liquid600pgm/lintplus)* | Advanced linter with ErrorLens-like error reporting. Compatible with linters made for `linter` *([screenshot](https://raw.githubusercontent.com/liquid600pgm/lintplus/master/screenshots/1.png))*
[`macmodkeys`](plugins/macmodkeys.lua?raw=1) | Remaps mac modkeys `command/option` to `ctrl/alt`
[`markers`](plugins/markers.lua?raw=1) | Add markers to docs and jump between them quickly *([screenshot](https://user-images.githubusercontent.com/3920290/82252149-5faaa200-9946-11ea-9199-bea2efb7ee23.png))*
[`memoryusage`](plugins/memoryusage.lua?raw=1) | Show memory usage in the status view
[`minimap`](plugins/minimap.lua?raw=1) | Shows a minimap on the right-hand side of the docview. Taken from [@andsve](https://github.com/andsve/lite-plugins/tree/minimap-plugin), and improved upon.
[`motiontrail`](plugins/motiontrail.lua?raw=1) | Adds a motion-trail to the caret *([screenshot](https://user-images.githubusercontent.com/3920290/83256814-085ccb00-a1ab-11ea-9e35-e6633cbed1a9.gif))*
~~[`nagbar`](https://github.com/takase1121/lite-nagbar)*~~ | integrated in lite-xl ~~consistent and _beautiful_ confirmation dialogs for lite and lite-xl *([gif](https://raw.githubusercontent.com/takase1121/lite-nagbar/master/assets/preview.gif))*~~
[`navigate`](plugins/navigate.lua?raw=1) | Allows moving back and forward between document positions, reducing the amount of scrolling
[`open_ext`](plugins/open_ext.lua?raw=1) | Automatically prompts you if you tried to open a binary file in the editor
[`openfilelocation`](plugins/openfilelocation.lua?raw=1) | Opens the parent directory of the current file in the file manager
[`openselected`](plugins/openselected.lua?raw=1) | Opens the selected filename or url
~~[`projectmanager`](plugins/projectmanager.lua?raw=1)~~ | Integrated in lite-xl with improvements ~~Save projects and load/reload them quickly~~
[`pdfview`](plugins/pdfview.lua?raw=1) | PDF preview for TeX files
[`rainbowparen`](plugins/rainbowparen.lua?raw=1) | Show nesting of parentheses with rainbow colours
[`regexreplaceplugin`](plugins/regexreplaceplugin.lua?raw=1) | Allows for you to write a regex and its replacement in one go, and live preview the results.
[`restoretabs`](plugins/restoretabs.lua?raw=1) | Keep a list of recently closed tabs, and restore the tab in order on cntrl+shift+t.
~~`scale`~~ | Integrated in lite-xl with improvements ~~Provides support for dynamically adjusting the scale of the code font / UI (`ctrl+-`, `ctrl+=`)~~
[`scalestatus`](plugins/scalestatus.lua?raw=1) | Displays current scale (zoom) in status view (depends on scale plugin)
[`selectionhighlight`](plugins/selectionhighlight.lua?raw=1) | Highlights regions of code that match the current selection *([screenshot](https://user-images.githubusercontent.com/3920290/80710883-5f597c80-8ae7-11ea-97f0-76dfacc08439.png))*
[`smallclock`](plugins/smallclock.lua?raw=1) | Displays the current time in the corner of the status view
[`sort`](plugins/sort.lua?raw=1) | Sorts selected lines alphabetically
[`spellcheck`](plugins/spellcheck.lua?raw=1) | Underlines misspelt words *([screenshot](https://user-images.githubusercontent.com/3920290/79923973-9caa7400-842e-11ea-85d4-7a196a91ca50.png))* *— note: on Windows a [`words.txt`](https://github.com/dwyl/english-words/blob/master/words.txt) dictionary file must be placed beside the exe*
[`tabnumbers`](plugins/tabnumbers.lua?raw=1) | Displays tab numbers from 1–9 next to their names *([screenshot](https://user-images.githubusercontent.com/16415678/101285362-007a8500-37e5-11eb-869b-c10eb9d9d902.png))
[`texcompile`](plugins/texcompile.lua?raw=1) | Compile Tex files into PDF
[`theme16`](https://github.com/monolifed/theme16)* | Theme manager with base16 themes
[`themescheduler`](https://github.com/BenStigsen/lite-config/blob/main/plugins/themescheduler.lua?raw=1) | Schedule themes to be used at certain times
[`themeselect`](plugins/themeselect.lua?raw=1) | Select a theme based on filename of active document
[`titleize`](plugins/titleize.lua?raw=1) | Titleizes selected string (`hello world` => `Hello World`)
[`todotreeview`](https://github.com/drmargarido/TodoTreeView)* | Todo tree viewer for annotations in code like `TODO`, `BUG`, `FIX`, `IMPROVEMENT`
[`togglesnakecamel`](plugins/togglesnakecamel.lua?raw=1) | Toggles symbols between `snake_case` and `camelCase`
[`unboundedscroll`](plugins/unboundedscroll.lua?raw=1) | Allows scrolling outside the bounds of a document
*[`updatechecker`](https://github.com/vincens2005/lite-xl-updatechecker)** | Automatically checks for updates and notifies you
*[`vibe`](https://github.com/eugenpt/lite-xl-vibe)** | VI(vim?) bindings with a hint of DOOM Emacs, for lite-xl
~~[`workspace`](plugins/workspace.lua?raw=1)~~ | Integrated in lite-xl ~~Retains project's layout and open documents between sessions~~
