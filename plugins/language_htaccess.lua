-- mod-version:2 -- lite-xl 2.0
local syntax = require "core.syntax"

local keywords = {
  "AddCharset", "AddDefaultCharset", "AddHandler", "AddOutputFilterByType", "AddType", "Allow",
  "AuthName", "AuthType", "AuthUserFile", "BrowserMatch", "CheckSpelling", "DefaultLanguage",
  "Deny", "DirectoryIndex", "ErrorDocument", "ExpiresActive", "ExpiresByType", "ExpiresDefault",
  "FallbackResource", "FileETag", "ForceType", "from", "Header", "IndexIgnore", "LimitRequestBody",
  "LoadModule", "Options", "Order", "php_flag", "php_value", "Redirect", "RedirectMatch",
  "RequestHeader", "Require", "RewriteBase", "RewriteCond", "RewriteEngine", "RewriteRule",
  "Satisfy", "ServerSignature", "SetEnv", "SetEnvIf", "SetEnvIfNoCase",
}
local literals = {
  "on", "off", "deny", "denied", "all", "All", "allow", "Basic", "valid-user", "append", "unset",
  "set", "DEFLATE",
}

local symbols = {}
for _,kw in ipairs(keywords) do
  symbols[kw] = "keyword"
end
for _,lt in ipairs(literals) do
  symbols[lt] = "literal"
end

local url_syntax = {
  patterns = {
    { pattern = "[%%$]%{?[%w_]+%}?", type = "keyword2" },
    { pattern = "[^%%$%s]", type = "string" }
  },
  symbols = {}
}
local xml_syntax = {
  patterns = {{ pattern = { '"', '"', '\\' }, type = "string" }},
  symbols = {}
}

syntax.add {
  name = ".htaccess File",
  files = { "%.htaccess$" },
  comment = "#",
  patterns = {
    -- Comments
    { pattern = "#.*\n",                  type = "comment"  },
    -- Strings
    { pattern = { '"', '"', '\\' },       type = "string"   },
    { pattern = { "'", "'", '\\' },       type = "string"   },
    { pattern = { '`', '`', '\\' },       type = "string"   },
    -- URLs
    { pattern = { "%w-://", "%s" },       type = "string", syntax = url_syntax },
    { pattern = { "%s/", "%s" },          type = "string", syntax = url_syntax },
    -- Mime types
    { pattern = "application/[%w%._+-]+", type = "keyword2" },
    { pattern = "font/[%w%._+-]+",        type = "keyword2" },
    { pattern = "image/[%w%._+-]+",       type = "keyword2" },
    { pattern = "text/[%w%._+-]+",        type = "keyword2" },
    { pattern = "audio/[%w%._+-]+",       type = "keyword2" },
    { pattern = "video/[%w%._+-]+",       type = "keyword2" },
    -- IPs
    { pattern = "%d+.%d+.%d+.%d+",        type = "keyword2" },
    { pattern = "%d+.%d+.%d+.%d+/%d+",    type = "keyword2" },
    -- Regex (TODO: improve this, it's pretty naive and only works on some regex)
    { pattern = "%^%S*",                  type = "literal" },
    { pattern = "%S*%$",                  type = "literal" },
    { pattern = "%b()",                   type = "literal" },
    -- Rewrite option sections
    { pattern = "%b[]",                   type = "number" },
    -- XML tags
    { pattern = { "</?%w+", ">" },        type = "literal", syntax = xml_syntax },
    -- Variables
    { pattern = "[%%$][%w_%{%}]+",        type = "keyword2" },
    -- Everything else
    { pattern = "[%a_][%w_-]*",           type = "symbol"   },
  },
  symbols = symbols
}
