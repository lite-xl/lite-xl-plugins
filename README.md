Plugins for the [lite text editor](https://github.com/rxi/lite)

*Note: if you make a pull request, the table should be updated and kept in
alphabetical order. If your plugin is large (or you'd otherwise prefer it to
have its own repo), the table can simply be updated to add a link to the repo;
otherwise the plugin file itself can be submitted. If a plugin's link resolves
to a something other than a raw file it should be marked with an asterisk.*

---

Plugin | Description
-------|-----------------------------------------
[`autowrap`](plugins/autowrap.lua?raw=1) | Automatically hardwraps lines when typing
[`bracketmatch`](plugins/bracketmatch.lua?raw=1) | Underlines matching right-bracket of left-bracket under caret *([screenshot](https://user-images.githubusercontent.com/3920290/80132745-0c863f00-8594-11ea-8875-c455c6fd7eae.png))*
[`colorpreview`](plugins/colorpreview.lua?raw=1) | Underlays color values (eg. `#ff00ff` or `rgb(255, 0, 255)`) with their resultant color. *([screenshot](https://user-images.githubusercontent.com/3920290/80743752-731bd780-8b15-11ea-97d3-847db927c5dc.png))*
[`console`](https://github.com/rxi/console)* | A console for running external commands and capturing their output *([gif](https://user-images.githubusercontent.com/3920290/81343656-49325a00-90ad-11ea-8647-ff39d8f1d730.gif))*
[`detectindent`](plugins/detectindent.lua?raw=1) | Automatically detects and uses the indentation size and tab type of a loaded file
[`drawwhitespace`](plugins/drawwhitespace.lua?raw=1) | Draws tabs and spaces *([screenshot](https://user-images.githubusercontent.com/3920290/80573013-22ae5800-89f7-11ea-9895-6362a1c0abc7.png))*
[`eval`](plugins/eval.lua?raw=1) | Replaces selected Lua code with its evaluated result
[`gitstatus`](plugins/gitstatus.lua?raw=1) | Displays git branch and insert/delete count in status bar *([screenshot](https://user-images.githubusercontent.com/3920290/81107223-bcea3080-8f0e-11ea-8fc7-d03173f42e33.png))*
[`gofmt`](plugins/gofmt.lua?raw=1) | Auto-formats the current go file, adds the missing imports and the missing return cases
[`hidestatus`](plugins/hidestatus.lua?raw=1) | Hides the status bar at the bottom of the window
[`indentguide`](plugins/indentguide.lua?raw=1) | Adds indent guides *([screenshot](https://user-images.githubusercontent.com/3920290/79640716-f9860000-818a-11ea-9c3b-26d10dd0e0c0.png))*
[`language_angelscript`](plugins/language_angelscript.lua?raw=1) | Syntax for the [Angelscript](https://www.angelcode.com/angelscript/) programming language
[`language_cpp`](plugins/language_cpp.lua?raw=1) | Syntax for the [C++](https://isocpp.org/) programming language
[`language_fe`](plugins/language_fe.lua?raw=1) | Syntax for the [fe](https://github.com/rxi/fe) programming language
[`language_go`](plugins/language_go.lua?raw=1) | Syntax for the [Go](https://golang.org/) programming language
[`language_jiyu`](plugins/language_jiyu.lua?raw=1) | Syntax for the [jiyu](https://github.com/machinamentum/jiyu) programming language
[`language_odin`](plugins/language_odin.lua?raw=1) | Syntax for the [Odin](https://github.com/odin-lang/Odin) programming language
[`language_php`](plugins/language_php.lua?raw=1) | Syntax for the [PHP](https://php.net) programming language
[`language_psql`](plugins/language_psql.lua?raw=1) | Syntax for the postgresql database access language
[`language_rust`](plugins/language_rust.lua?raw=1) | Syntax for the [Rust](https://rust-lang.org/) programming language
[`language_sh`](plugins/language_sh.lua?raw=1) | Syntax for shell scripting language
[`language_wren`](plugins/language_wren.lua?raw=1) | Syntax for the [Wren](http://wren.io/) programming language
[`lfautoinsert`](plugins/lfautoinsert.lua?raw=1) | Automatically inserts indentation and closing bracket/text after newline
[`lineguide`](plugins/lineguide.lua?raw=1) | Displays a line-guide at the line limit offset *([screenshot](https://user-images.githubusercontent.com/3920290/81476159-2cf70000-9208-11ea-928b-9dae3884c477.png))*
[`linter`](https://github.com/drmargarido/linters)* | Linters for multiple languages
[`macmodkeys`](plugins/macmodkeys.lua?raw=1) | Remaps mac modkeys `command/option` to `ctrl/alt`
[`selectionhighlight`](plugins/selectionhighlight.lua?raw=1) | Highlights regions of code that match the current selection *([screenshot](https://user-images.githubusercontent.com/3920290/80710883-5f597c80-8ae7-11ea-97f0-76dfacc08439.png))*
[`sort`](plugins/sort.lua?raw=1) | Sorts selected lines alphabetically
[`spellcheck`](plugins/spellcheck.lua?raw=1) | Underlines misspelt words *([screenshot](https://user-images.githubusercontent.com/3920290/79923973-9caa7400-842e-11ea-85d4-7a196a91ca50.png))*
[`theme16`](https://github.com/monolifed/theme16)* | Theme manager with base16 themes
[`titleize`](plugins/titleize.lua?raw=1) | Titleizes selected string (`hello world` => `Hello World`)
[`todotreeview`](https://github.com/drmargarido/TodoTreeView)* | Todo tree viewer for annotations in code like `TODO`, `BUG`, `FIX`, `IMPROVEMENT`
[`togglesnakecamel`](plugins/togglesnakecamel.lua?raw=1) | Toggles symbols between `snake_case` and `camelCase`
[`unboundedscroll`](plugins/unboundedscroll.lua?raw=1) | Allows scrolling outside the bounds of a document


