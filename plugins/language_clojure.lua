-- Author: https://github.com/RohanVashisht1234/
-- mod-version:3
local syntax = require "core.syntax"
syntax.add {
  name = "Clojure",
  comment = ";;",
  files = {
    "%.clojure$",
  },
  patterns = {
    { pattern = ';;.*',                                   type = 'comment' },
    { pattern = ';.*',                                    type = 'comment' },
    { pattern = { '#"', '"', '\\' },                      type = 'string' },
    { pattern = { '"', '"', '\\' },                       type = 'string' },
    { pattern = { '"""', '"""', '\\' },                   type = 'string' },
    { pattern = 'Retention()%s+()[%a_][%w_/]*',             type = { 'keyword', 'normal', 'literal' } },
    { pattern = ':[%a_][%w_/%-]*',                        type = { 'keyword2', 'literal' } },
    { pattern = '[%a_][%w_]*()%.()[%a_][%w_/%-]*',        type = { 'keyword','operator', 'keyword2' } },
    { pattern = "%(()def()%s+()[%a_][%w_%-]*",            type = { "normal", "keyword", "literal", 'literal' } }, -- tested ok
    { pattern = "%(()def[%a_][%w_]*()%s+()[%a_][%w_%-]*", type = { "normal", "keyword", "literal", 'literal' } }, -- tested ok
    { pattern = '%(()require()%s+()[%a_][%w_]*',          type = { 'normal', 'keyword', 'literal', 'literal' } },
    { pattern = '%(()[%a_][%w_/]*',                       type = { 'normal', 'literal' } },
    { pattern = '-?0x%x+',                                type = 'number' },
    { pattern = '-?%d+[%d%.eE]*f?',                       type = 'number' },
    { pattern = '-?%.?%d+f?',                             type = 'number' },
    { pattern = '[!%#%$%%&*+./%<=>%?@\\%^|%-~:]',         type = 'operator' },
    { pattern = "[%a_'][%w_']*",                          type = 'normal' },
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
