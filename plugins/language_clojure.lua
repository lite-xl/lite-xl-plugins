-- Author: Rohan Vashisht: https://github.com/RohanVashisht1234/

-- mod-version:3
local syntax = require "core.syntax"
syntax.add {
    name = "Clojure", -- tested ok
    comment = ";;",   -- tested ok
    files = { 
        "%.clj$",
        "%.cljs$", 
        "%.clc$", 
        "%.edn$",
    },
    patterns = {
        { pattern = ';;.*',                                   type = 'comment' },                                     -- tested ok
        { pattern = ';.*',                                    type = 'comment' },                                     -- tested ok
        { pattern = { '#"', '"', '\\' },                      type = 'string' },                                      -- tested ok
        { pattern = { '"', '"', '\\' },                       type = 'string' },                                      -- tested ok
        { pattern = { '"""', '"""', '\\' },                   type = 'string' },                                      -- tested ok
        { pattern = 'Retention()%s+()[%a_][%w_/]*',           type = { 'keyword', 'normal', 'literal' } },            -- tested ok
        { pattern = ':[%a_][%w_/%-]*',                        type = 'keyword2' },                                    -- tested ok
        { pattern = '[%a_][%w_]*()%.()[%a_][%w_/%-]*',        type = { 'keyword', 'operator', 'keyword2' } },
        { pattern = "%(()def()%s+()[%a_][%w_%-]*",            type = { "normal", "keyword", "literal", 'literal' } }, -- tested ok
        { pattern = "%(()def[%a_][%w_]*()%s+()[%a_][%w_%-]*", type = { "normal", "keyword", "literal", 'literal' } }, -- tested ok
        { pattern = '%(()require()%s+()[%a_][%w_]*',          type = { 'normal', 'keyword', 'literal', 'literal' } }, -- tested ok
        { pattern = '%(()[%a_][%w_/]*',                       type = { 'normal', 'literal' } },                       -- tested ok
        { pattern = '-?0x%x+',                                type = 'number' },                                      -- tested ok
        { pattern = '-?%d+[%d%.eE]*f?',                       type = 'number' },                                      -- tested ok
        { pattern = '-?%.?%d+f?',                             type = 'number' },                                      -- tested ok
        { pattern = '[!%#%$%%&*+./%<=>%?@\\%^|%-~:]',         type = 'operator' },                                    -- tested ok
        { pattern = "[%a_'][%w_']*",                          type = 'normal' },                                      -- tested ok
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
