-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "SSH config",
  files = { "sshd?/?_?config$" },
  comment = '#',
  patterns = {
    { pattern = "#.*\n",        type = "comment"  },
    { pattern = "%d+",          type = "number"   },
    { pattern = "[%a_][%w_]*",  type = "symbol"   },
    { pattern = "@",            type = "operator" },
  },
  symbols = {
    -- ssh config
    ["Host"]                         = "function",
    ["ProxyCommand"]                 = "function",

    ["HostName"]                     = "keyword",
    ["IdentityFile"]                 = "keyword",
    ["IdentitiesOnly"]               = "keyword",
    ["User"]                         = "keyword",
    ["Port"]                         = "keyword",

    ["ForwardAgent"]                 = "keyword",
    ["ForwardX11"]                   = "keyword",
    ["ForwardX11Trusted"]            = "keyword",
    ["HostbasedAuthentication"]      = "keyword",
    ["GSSAPIAuthentication"]         = "keyword",
    ["GSSAPIDelegateCredentials"]    = "keyword",
    ["GSSAPIKeyExchange"]            = "keyword",
    ["GSSAPITrustDNS"]               = "keyword",
    ["BatchMode"]                    = "keyword",
    ["CheckHostIP"]                  = "keyword",
    ["AddressFamily"]                = "keyword",
    ["ConnectTimeout"]               = "keyword",
    ["StrictHostKeyChecking"]        = "keyword",
    ["Ciphers"]                      = "keyword",
    ["MACs"]                         = "keyword",
    ["EscapeChar"]                   = "keyword",
    ["Tunnel"]                       = "keyword",
    ["TunnelDevice"]                 = "keyword",
    ["PermitLocalCommand"]           = "keyword",
    ["VisualHostKey"]                = "keyword",
    ["RekeyLimit"]                   = "keyword",
    ["SendEnv"]                      = "keyword",
    ["HashKnownHosts"]               = "keyword",
    ["GSSAPIAuthentication"]         = "keyword",

    -- sshd config
    ["Subsystem"]                    = "keyword2",


    ["yes"]      = "literal",
    ["no"]       = "literal",
    ["any"]      = "literal",
    ["ask"]      = "literal",
  },
}
