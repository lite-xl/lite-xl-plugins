local tests = require "plugins.editorconfig.tests"

-- Tests for *

-- matches a single characters
tests.add("star_single_ML", "glob/star.in", "ace.c", "key=value[ \t\n\r]+keyc=valuec[ \t\n\r]*")

-- matches zero characters
tests.add("star_zero_ML", "glob/star.in", "ae.c", "key=value[ \t\n\r]+keyc=valuec[ \t\n\r]*")

-- matches multiple characters
tests.add("star_multiple_ML", "glob/star.in", "abcde.c", "key=value[ \t\n\r]+keyc=valuec[ \t\n\r]*")

-- does not match path separator
tests.add("star_over_slash", "glob/star.in", "a/e.c", "^[ \t\n\r]*keyc=valuec[ \t\n\r]*$")

-- star after a slash
tests.add("star_after_slash_ML", "glob/star.in", "Bar/foo.txt", "keyb=valueb[ \t\n\r]+keyc=valuec[ \t\n\r]*")

-- star matches a dot file after slash
tests.add("star_matches_dot_file_after_slash_ML", "glob/star.in", "Bar/.editorconfig", "keyb=valueb[ \t\n\r]+keyc=valuec[ \t\n\r]*")

-- star matches a dot file
tests.add("star_matches_dot_file", "glob/star.in", ".editorconfig", "^keyc=valuec[ \t\n\r]*$")

-- Tests for ?

-- matches a single character
tests.add("question_single", "glob/question.in", "some.c", "^key=value[ \t\n\r]*$")

-- does not match zero characters
tests.add("question_zero", "glob/question.in", "som.c", "^[ \t\n\r]*$")

-- does not match multiple characters
tests.add("question_multiple", "glob/question.in", "something.c", "^[ \t\n\r]*$")

-- does not match slash
tests.add("question_slash", "glob/question.in", "som/.c", "^[ \t\n\r]*$")

-- Tests for [ and ]

-- close bracket inside
tests.add("brackets_close_inside", "glob/brackets.in", "].g", "^close_inside=true[ \t\n\r]*$")

-- close bracket outside
tests.add("brackets_close_outside", "glob/brackets.in", "b].g", "^close_outside=true[ \t\n\r]*$")

-- negative close bracket inside
tests.add("brackets_nclose_inside", "glob/brackets.in", "c.g", "^close_inside=false[ \t\n\r]*$")

-- negative close bracket outside
tests.add("brackets_nclose_outside", "glob/brackets.in", "c].g", "^close_outside=false[ \t\n\r]*$")

-- character choice
tests.add("brackets_choice", "glob/brackets.in", "a.a", "^choice=true[ \t\n\r]*$")

-- character choice 2
tests.add("brackets_choice2", "glob/brackets.in", "c.a", "^[ \t\n\r]*$")

-- negative character choice
tests.add("brackets_nchoice", "glob/brackets.in", "c.b", "^choice=false[ \t\n\r]*$")

-- negative character choice 2
tests.add("brackets_nchoice2", "glob/brackets.in", "a.b", "^[ \t\n\r]*$")

-- character range
tests.add("brackets_range", "glob/brackets.in", "f.c", "^range=true[ \t\n\r]*$")

-- character range 2
tests.add("brackets_range2", "glob/brackets.in", "h.c", "^[ \t\n\r]*$")

-- negative character range
tests.add("brackets_nrange", "glob/brackets.in", "h.d", "^range=false[ \t\n\r]*$")

-- negative character range 2
tests.add("brackets_nrange2", "glob/brackets.in", "f.d", "^[ \t\n\r]*$")

-- range and choice
tests.add("brackets_range_and_choice", "glob/brackets.in", "e.e",
    "^range_and_choice=true[ \t\n\r]*$")

-- character choice with a dash
tests.add("brackets_choice_with_dash", "glob/brackets.in", "-.f",
    "^choice_with_dash=true[ \t\n\r]*$")

-- slash inside brackets
tests.add("brackets_slash_inside1", "glob/brackets.in", "ab/cd.i",
    "^[ \t\n\r]*$")
tests.add("brackets_slash_inside2", "glob/brackets.in", "abecd.i",
    "^[ \t\n\r]*$")
tests.add("brackets_slash_inside3", "glob/brackets.in", "ab[e/]cd.i",
    "^slash_inside=true[ \t\n\r]*$")
tests.add("brackets_slash_inside4", "glob/brackets.in", "ab[/c",
    "^slash_half_open=true[ \t\n\r]*$")

-- Tests for { and }

-- word choice
tests.add("braces_word_choice1", "glob/braces.in", "test.py", "^choice=true[ \t\n\r]*$")
tests.add("braces_word_choice2", "glob/braces.in", "test.js", "^choice=true[ \t\n\r]*$")
tests.add("braces_word_choice3", "glob/braces.in", "test.html", "^choice=true[ \t\n\r]*$")
tests.add("braces_word_choice4", "glob/braces.in", "test.pyc", "^[ \t\n\r]*$")

-- single choice
tests.add("braces_single_choice", "glob/braces.in", "{single}.b", "^choice=single[ \t\n\r]*$")
tests.add("braces_single_choice_negative", "glob/braces.in", ".b", "^[ \t\n\r]*$")

-- empty choice
tests.add("braces_empty_choice", "glob/braces.in", "{}.c", "^empty=all[ \t\n\r]*$")
tests.add("braces_empty_choice_negative", "glob/braces.in", ".c", "^[ \t\n\r]*$")

-- choice with empty word
tests.add("braces_empty_word1", "glob/braces.in", "a.d", "^empty=word[ \t\n\r]*$")
tests.add("braces_empty_word2", "glob/braces.in", "ab.d", "^empty=word[ \t\n\r]*$")
tests.add("braces_empty_word3", "glob/braces.in", "ac.d", "^empty=word[ \t\n\r]*$")
tests.add("braces_empty_word4", "glob/braces.in", "a,.d", "^[ \t\n\r]*$")

-- choice with empty words
tests.add("braces_empty_words1", "glob/braces.in", "a.e", "^empty=words[ \t\n\r]*$")
tests.add("braces_empty_words2", "glob/braces.in", "ab.e", "^empty=words[ \t\n\r]*$")
tests.add("braces_empty_words3", "glob/braces.in", "ac.e", "^empty=words[ \t\n\r]*$")
tests.add("braces_empty_words4", "glob/braces.in", "a,.e", "^[ \t\n\r]*$")

-- no closing brace
tests.add("braces_no_closing", "glob/braces.in", "{.f", "^closing=false[ \t\n\r]*$")
tests.add("braces_no_closing_negative", "glob/braces.in", ".f", "^[ \t\n\r]*$")

-- nested braces
tests.add("braces_nested1", "glob/braces.in", "word,this}.g", "^[ \t\n\r]*$")
tests.add("braces_nested2", "glob/braces.in", "{also,this}.g", "^[ \t\n\r]*$")
tests.add("braces_nested3", "glob/braces.in", "word.g", "^nested=true[ \t\n\r]*$")
tests.add("braces_nested4", "glob/braces.in", "{also}.g", "^nested=true[ \t\n\r]*$")
tests.add("braces_nested5", "glob/braces.in", "this.g", "^nested=true[ \t\n\r]*$")

-- nested braces, adjacent at start
tests.add("braces_nested_start1", "glob/braces.in", "{{a,b},c}.k", "^[ \t\n\r]*$")
tests.add("braces_nested_start2", "glob/braces.in", "{a,b}.k", "^[ \t\n\r]*$")
tests.add("braces_nested_start3", "glob/braces.in", "a.k", "^nested_start=true[ \t\n\r]*$")
tests.add("braces_nested_start4", "glob/braces.in", "b.k", "^nested_start=true[ \t\n\r]*$")
tests.add("braces_nested_start5", "glob/braces.in", "c.k", "^nested_start=true[ \t\n\r]*$")

-- nested braces, adjacent at end
tests.add("braces_nested_end1", "glob/braces.in", "{a,{b,c}}.l", "^[ \t\n\r]*$")
tests.add("braces_nested_end2", "glob/braces.in", "{b,c}.l", "^[ \t\n\r]*$")
tests.add("braces_nested_end3", "glob/braces.in", "a.l", "^nested_end=true[ \t\n\r]*$")
tests.add("braces_nested_end4", "glob/braces.in", "b.l", "^nested_end=true[ \t\n\r]*$")
tests.add("braces_nested_end5", "glob/braces.in", "c.l", "^nested_end=true[ \t\n\r]*$")

-- closing inside beginning
tests.add("braces_closing_in_beginning", "glob/braces.in", "{},b}.h", "^closing=inside[ \t\n\r]*$")

-- missing closing braces
tests.add("braces_unmatched1", "glob/braces.in", "{{,b,c{d}.i", "^unmatched=true[ \t\n\r]*$")
tests.add("braces_unmatched2", "glob/braces.in", "{.i", "^[ \t\n\r]*$")
tests.add("braces_unmatched3", "glob/braces.in", "b.i", "^[ \t\n\r]*$")
tests.add("braces_unmatched4", "glob/braces.in", "c{d.i", "^[ \t\n\r]*$")
tests.add("braces_unmatched5", "glob/braces.in", ".i", "^[ \t\n\r]*$")

-- escaped comma
tests.add("braces_escaped_comma1", "glob/braces.in", "a,b.txt", "^comma=yes[ \t\n\r]*$")
tests.add("braces_escaped_comma2", "glob/braces.in", "a.txt", "^[ \t\n\r]*$")
tests.add("braces_escaped_comma3", "glob/braces.in", "cd.txt", "^comma=yes[ \t\n\r]*$")

-- escaped closing brace
tests.add("braces_escaped_brace1", "glob/braces.in", "e.txt", "^closing=yes[ \t\n\r]*$")
tests.add("braces_escaped_brace2", "glob/braces.in", "}.txt", "^closing=yes[ \t\n\r]*$")
tests.add("braces_escaped_brace3", "glob/braces.in", "f.txt", "^closing=yes[ \t\n\r]*$")

-- escaped backslash
tests.add("braces_escaped_backslash1", "glob/braces.in", "g.txt", "^backslash=yes[ \t\n\r]*$")
if PLATFORM ~= "Windows" then
tests.add("braces_escaped_backslash2", "glob/braces.in", "\\.txt", "^backslash=yes[ \t\n\r]*$")
end
tests.add("braces_escaped_backslash3", "glob/braces.in", "i.txt", "^backslash=yes[ \t\n\r]*$")

-- patterns nested in braces
tests.add("braces_patterns_nested1", "glob/braces.in", "some.j", "^patterns=nested[ \t\n\r]*$")
tests.add("braces_patterns_nested2", "glob/braces.in", "abe.j", "^patterns=nested[ \t\n\r]*$")
tests.add("braces_patterns_nested3", "glob/braces.in", "abf.j", "^patterns=nested[ \t\n\r]*$")
tests.add("braces_patterns_nested4", "glob/braces.in", "abg.j", "^[ \t\n\r]*$")
tests.add("braces_patterns_nested5", "glob/braces.in", "ace.j", "^patterns=nested[ \t\n\r]*$")
tests.add("braces_patterns_nested6", "glob/braces.in", "acf.j", "^patterns=nested[ \t\n\r]*$")
tests.add("braces_patterns_nested7", "glob/braces.in", "acg.j", "^[ \t\n\r]*$")
tests.add("braces_patterns_nested8", "glob/braces.in", "abce.j", "^patterns=nested[ \t\n\r]*$")
tests.add("braces_patterns_nested9", "glob/braces.in", "abcf.j", "^patterns=nested[ \t\n\r]*$")
tests.add("braces_patterns_nested10", "glob/braces.in", "abcg.j", "^[ \t\n\r]*$")
tests.add("braces_patterns_nested11", "glob/braces.in", "ae.j", "^[ \t\n\r]*$")
tests.add("braces_patterns_nested12", "glob/braces.in", ".j", "^[ \t\n\r]*$")

-- numeric brace range
tests.add("braces_numeric_range1", "glob/braces.in", "1", "^[ \t\n\r]*$")
tests.add("braces_numeric_range2", "glob/braces.in", "3", "^number=true[ \t\n\r]*$")
tests.add("braces_numeric_range3", "glob/braces.in", "15", "^number=true[ \t\n\r]*$")
tests.add("braces_numeric_range4", "glob/braces.in", "60", "^number=true[ \t\n\r]*$")
tests.add("braces_numeric_range5", "glob/braces.in", "5a", "^[ \t\n\r]*$")
tests.add("braces_numeric_range6", "glob/braces.in", "120", "^number=true[ \t\n\r]*$")
tests.add("braces_numeric_range7", "glob/braces.in", "121", "^[ \t\n\r]*$")
tests.add("braces_numeric_range8", "glob/braces.in", "060", "^[ \t\n\r]*$")

-- alphabetical brace range: letters should not be considered for ranges
tests.add("braces_alpha_range1", "glob/braces.in", "{aardvark..antelope}", "^words=a[ \t\n\r]*$")
tests.add("braces_alpha_range2", "glob/braces.in", "a", "^[ \t\n\r]*$")
tests.add("braces_alpha_range3", "glob/braces.in", "aardvark", "^[ \t\n\r]*$")
tests.add("braces_alpha_range4", "glob/braces.in", "agreement", "^[ \t\n\r]*$")
tests.add("braces_alpha_range5", "glob/braces.in", "antelope", "^[ \t\n\r]*$")
tests.add("braces_alpha_range6", "glob/braces.in", "antimatter", "^[ \t\n\r]*$")


-- Tests for **

-- test EditorConfig files with UTF-8 characters larger than 127
tests.add("utf_8_char", "glob/utf8char.in", "中文.txt", "^key=value[ \t\n\r]*$")

-- matches over path separator
tests.add("star_star_over_separator1", "glob/star_star.in", "a/z.c", "^key1=value1[ \t\n\r]*$")
tests.add("star_star_over_separator2", "glob/star_star.in", "amnz.c", "^key1=value1[ \t\n\r]*$")
tests.add("star_star_over_separator3", "glob/star_star.in", "am/nz.c", "^key1=value1[ \t\n\r]*$")
tests.add("star_star_over_separator4", "glob/star_star.in", "a/mnz.c", "^key1=value1[ \t\n\r]*$")
tests.add("star_star_over_separator5", "glob/star_star.in", "amn/z.c", "^key1=value1[ \t\n\r]*$")
tests.add("star_star_over_separator6", "glob/star_star.in", "a/mn/z.c", "^key1=value1[ \t\n\r]*$")

tests.add("star_star_over_separator7", "glob/star_star.in", "b/z.c", "^key2=value2[ \t\n\r]*$")
tests.add("star_star_over_separator8", "glob/star_star.in", "b/mnz.c", "^key2=value2[ \t\n\r]*$")
tests.add("star_star_over_separator9", "glob/star_star.in", "b/mn/z.c", "^key2=value2[ \t\n\r]*$")
tests.add("star_star_over_separator10", "glob/star_star.in", "bmnz.c", "^[ \t\n\r]*$")
tests.add("star_star_over_separator11", "glob/star_star.in", "bm/nz.c", "^[ \t\n\r]*$")
tests.add("star_star_over_separator12", "glob/star_star.in", "bmn/z.c", "^[ \t\n\r]*$")

tests.add("star_star_over_separator13", "glob/star_star.in", "c/z.c", "^key3=value3[ \t\n\r]*$")
tests.add("star_star_over_separator14", "glob/star_star.in", "cmn/z.c", "^key3=value3[ \t\n\r]*$")
tests.add("star_star_over_separator15", "glob/star_star.in", "c/mn/z.c", "^key3=value3[ \t\n\r]*$")
tests.add("star_star_over_separator16", "glob/star_star.in", "cmnz.c", "^[ \t\n\r]*$")
tests.add("star_star_over_separator17", "glob/star_star.in", "cm/nz.c", "^[ \t\n\r]*$")
tests.add("star_star_over_separator18", "glob/star_star.in", "c/mnz.c", "^[ \t\n\r]*$")

tests.add("star_star_over_separator19", "glob/star_star.in", "d/z.c", "^key4=value4[ \t\n\r]*$")
tests.add("star_star_over_separator20", "glob/star_star.in", "d/mn/z.c", "^key4=value4[ \t\n\r]*$")
tests.add("star_star_over_separator21", "glob/star_star.in", "dmnz.c", "^[ \t\n\r]*$")
tests.add("star_star_over_separator22", "glob/star_star.in", "dm/nz.c", "^[ \t\n\r]*$")
tests.add("star_star_over_separator23", "glob/star_star.in", "d/mnz.c", "^[ \t\n\r]*$")
tests.add("star_star_over_separator24", "glob/star_star.in", "dmn/z.c", "^[ \t\n\r]*$")
