-- mod-version:3
-- Author: Rohan Vashisht: https://github.com/RohanVashisht1234/

local syntax = require "core.syntax"

syntax.add {
  name = "Brainfuck", -- tested ok
  files = {
    "%.bf$",          -- tested ok
  },
  patterns = {
    { pattern = '%[',                type = 'operator' }, -- tested ok
    { pattern = '%]',                type = 'operator' }, -- tested ok
    { pattern = '%-',                type = 'keyword' },  -- tested ok
    { pattern = '<',                 type = 'keyword2' }, -- tested ok
    { pattern = '>',                 type = 'keyword2' }, -- tested ok
    { pattern = '+',                 type = 'string' },   -- tested ok
    { pattern = ',',                 type = 'literal' },  -- tested ok
    { pattern = '%.',                type = 'string' },   -- tested ok
    { pattern = '[^%-%.<>%+,%[%]]+', type = 'comment' },  -- tested ok
  },
  symbols = {},
}
