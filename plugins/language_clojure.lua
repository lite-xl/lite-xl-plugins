-- Author: Rohan Vashisht: https://github.com/RohanVashisht1234/

-- mod-version:3
local syntax = require "core.syntax"
syntax.add {
    name = "Clojure",
    comment = ";;",
    files = { 
        "%.clj$",
        "%.cljs$", 
        "%.clc$", 
        "%.edn$",
    },
    patterns = {
        { pattern = ';;.*',                                   type = 'comment' },                                     -- Single-line Comment
        { pattern = ';.*',                                    type = 'comment' },                                     -- Single-line Comment
        { pattern = { '#"', '"', '\\' },                      type = 'string' },                                      -- Multiline String
        { pattern = { '"', '"', '\\' },                       type = 'string' },                                      -- Multiline String
        { pattern = { '"""', '"""', '\\' },                   type = 'string' },                                      -- Multiline String
        { pattern = ':[%a_][%w_/%-]*',                        type = 'keyword2' },                                    -- word after ':' a.k.a (Var metadata)
        { pattern = '[%a_][%w_]*()%.()[%a_][%w_/%-]*',        type = { 'keyword', 'operator', 'keyword2' } },         -- Things like something.something
        { pattern = "%(()def()%s+()[%a_][%w_%-]*",            type = { "normal", "keyword", "literal", 'literal' } }, -- function definition
        { pattern = "%(()def[%a_][%w_]*()%s+()[%a_][%w_%-]*", type = { "normal", "keyword", "literal", 'literal' } }, -- function definition but with something along with def like: defn, defmacro etc.
        { pattern = '%(()require()%s+()[%a_][%w_]*',          type = { 'normal', 'keyword', 'literal', 'literal' } }, -- highlight the word after require keyword
        { pattern = '%(()[%a_][%w_/]*',                       type = { 'normal', 'literal' } },                       -- patterns that are like this: (my_function/subdir_1)
        { pattern = '-?0x%x+',                                type = 'number' },                                      -- Hexadecimal
        { pattern = '-?%d+[%d%.eE]*f?',                       type = 'number' },                                      -- Floating-point numbers
        { pattern = '-?%.?%d+f?',                             type = 'number' },                                      -- Floating-point numbers
        { pattern = '[!%#%$%%&*+./%<=>%?@\\%^|%-~:]',         type = 'operator' },                                    -- Character classes
        { pattern = "[%a_'][%w_']*",                          type = 'normal' },                                      -- Normal
    },
    symbols = {
        ['def']        = 'keyword',  -- tested ok
        ['defn']       = 'keyword',  -- tested ok
        ['str']        = 'keyword',  -- tested ok
        ['fn']         = 'keyword',  -- tested ok
        ['println']    = 'keyword',  -- tested ok
        ['if']         = 'keyword',  -- tested ok
        ['cond']       = 'keyword',  -- tested ok
        ['vector']     = 'keyword',  -- tested ok
        ['apply']      = 'keyword',  -- tested ok
        ['String']     = 'keyword',  -- tested ok
        ['ns']         = 'keyword',  -- tested ok
        ['try']        = 'keyword',  -- tested ok
        ['let']        = 'keyword',  -- tested ok
        ['get']        = 'keyword',  -- tested ok
        ['catch']      = 'keyword',  -- tested ok
        ['Retention']  = 'keyword',  -- tested ok
        ['Deprecated'] = 'keyword',  -- tested ok
        ['require']    = 'keyword2', -- tested ok
        ['true']       = 'keyword2', -- tested ok
        ['false']      = 'keyword2', -- tested ok
        ['nil']        = 'literal',  -- tested ok
        ['int']        = 'literal',  -- tested ok
    },
}
