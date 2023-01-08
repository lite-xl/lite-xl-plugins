local tests = require "plugins.editorconfig.tests"

-- test tab_width default
tests.add("tab_width_default_ML", "properties/tab_width_default.in", "test.c",
    "indent_size=4[ \t]*[\n\r]+indent_style=space[ \t]*[\n\r]+tab_width=4[\t\n\r]*")

-- Tab_width should not be set to any value if indent_size is "tab" and
-- tab_width is not set
tests.add("tab_width_default_indent_size_tab_ML", "properties/tab_width_default.in",
    "test2.c", "indent_size=tab[ \t]*[\n\r]+indent_style=tab[ \t\n\r]*")

-- Test indent_size default. When indent_style is "tab", indent_size defaults to
-- "tab".
tests.add("indent_size_default_ML", "properties/indent_size_default.in", "test.c",
    "indent_size=tab[ \t]*[\n\r]+indent_style=tab[ \t\n\r]*")

-- Test indent_size default. When indent_style is "space", indent_size has no
-- default value.
tests.add("indent_size_default_space", "properties/indent_size_default.in", "test2.c",
    "^indent_style=space[ \t\n\r]*$")

-- Test indent_size default. When indent_style is "tab" and tab_width is set,
-- indent_size should default to tab_width
tests.add("indent_size_default_with_tab_width_ML",
    "properties/indent_size_default.in", "test3.c",
    "indent_size=2[ \t]*[\n\r]+indent_style=tab[ \t]*[\n\r]+tab_width=2[ \t\n\r]*")

-- test that same property values are lowercased (v0.9.0 properties)
tests.add("lowercase_values1_ML", "properties/lowercase_values.in", "test1.c",
    "end_of_line=crlf[ \t]*[\n\r]+indent_style=space[ \t\n\r]*")

-- test that same property values are lowercased (v0.9.0 properties)
tests.add("lowercase_values2_ML", "properties/lowercase_values.in", "test2.c",
    "charset=utf-8[ \t]*[\n\r]+insert_final_newline=true[ \t]*[\n\r]+trim_trailing_whitespace=false[ \t\n\r]*$")

-- test that same property values are not lowercased
tests.add("lowercase_values3", "properties/lowercase_values.in", "test3.c",
    "^test_property=TestValue[ \t\n\r]*$")

-- test that all property names are lowercased
tests.add("lowercase_names", "properties/lowercase_names.in", "test.c",
    "^testproperty=testvalue[ \t\n\r]*$")
