-- mod-version:3
local syntax = require "core.syntax"

syntax.add {
  name = "Perl",
  files = { "%.pm$", "%.pl$" },
  headers = "^#!.*[ /]perl[%s-w]*",
  comment = "#",
  patterns = {
    { pattern = "%#.*",                              type = "comment" },
    { pattern = { '"', '"', '\\' },                  type = "string"  },
    { pattern = { "'", "'", '\\' },                  type = "string"  },
    { pattern = { "^=%w+", "=cut" },                 type = "comment" },
    -- hash
    { pattern = "[%$][%a_][%w_]*[{]()[%a%d_]+()[}]", type = { "normal", "string", "normal" } },
    { pattern = "->{()[%a%d_]+()}",                  type = { "normal", "string", "normal" } },
    -- q syntax
    { pattern = "q[qrxw]?()[%[]()[%a%d%s-_]+()[%]]", type = { "keyword", "normal", "string", "normal" } },
    { pattern = "q[qrxw]?()[(]()[%a%d%s-_]+()[)]",   type = { "keyword", "normal", "string", "normal" } },
    { pattern = "q[qrxw]?()[!]()[%a%d%s-_]+()[!]",   type = { "keyword", "normal", "string", "normal" }  },
    { pattern = "q[qrxw]?()[|]()[%a%d%s-_]+()[|]",   type = { "keyword", "normal", "string", "normal" }  },
    { pattern = "q[qrxw]?()[/]()[%a%d%s-_]+()[/]",   type = { "keyword", "normal", "string", "normal" }  },
    { pattern = "q[qrxw]?()[{]()[%a%d%s-_]+()[}]",   type = { "keyword", "normal", "string", "normal" }  },
    { pattern = "q[qrxw]?()[%%]()[%a%d%s-_]+()[%%]", type = { "keyword", "normal", "string", "normal" }  },
    -- until we can get this workign with s///, just don't do any of them.
    -- { pattern = { '/', '/', '\\' },       type = "string"   },
    { pattern = "-?%d+[%d%.eE]*",                    type = "number"    },
    { pattern = "-?%.?%d+",                          type = "number"    },
    { pattern = "[%a_][%w_]*%f[(]",                  type = "function"  },
    { pattern = "[%@%$%*%%]+[%a_][%w_]*",            type = "keyword2"  },
    { pattern = "%--[%a_][%w_]*",                    type = "symbol"    },
    { pattern = "[%a_][%w_]*%s+()=>",                type = { "string", "operator" } },
    { pattern = "sub%s+()[%w_]+",                    type = { "keyword", "operator" } },
    { pattern = "[<=>%+%-%*%/:%&%|%!%?%~]+",         type = "operator" }
  },
  symbols = {
    ["-A"] = "keyword",
    ["END"] = "keyword",
    ["length"] = "keyword",
    ["setpgrp"] = "keyword",
    ["-B"] = "keyword",
    ["endgrent"] = "keyword",
    ["link"] = "keyword",
    ["setpriority"] = "keyword",
    ["-b"] = "keyword",
    ["endhostent"] = "keyword",
    ["listen"] = "keyword",
    ["setprotoent"] = "keyword",
    ["-C"] = "keyword",
    ["endnetent"] = "keyword",
    ["local"] = "keyword",
    ["setpwent"] = "keyword",
    ["-c"] = "keyword",
    ["endprotoent"] = "keyword",
    ["localtime"] = "keyword",
    ["setservent"] = "keyword",
    ["-d"] = "keyword",
    ["endpwent"] = "keyword",
    ["log"] = "keyword",
    ["setsockopt"] = "keyword",
    ["-e"] = "keyword",
    ["endservent"] = "keyword",
    ["lstat"] = "keyword",
    ["shift"] = "keyword",
    ["-f"] = "keyword",
    ["eof$"] = "keyword",
    ["map"] = "keyword",
    ["shmctl"] = "keyword",
    ["-g"] = "keyword",
    ["eval"] = "keyword",
    ["mkdir"] = "keyword",
    ["shmget"] = "keyword",
    ["-k"] = "keyword",
    ["exec"] = "keyword",
    ["msgctl"] = "keyword",
    ["shmread"] = "keyword",
    ["-l"] = "keyword",
    ["exists"] = "keyword",
    ["msgget"] = "keyword",
    ["shmwrite"] = "keyword",
    ["-M"] = "keyword",
    ["exit"] = "keyword",
    ["msgrcv"] = "keyword",
    ["shutdown"] = "keyword",
    ["-O"] = "keyword",
    ["fcntl"] = "keyword",
    ["msgsnd"] = "keyword",
    ["sin"] = "keyword",
    ["-o"] = "keyword",
    ["fileno"] = "keyword",
    ["my"] = "keyword",
    ["sleep"] = "keyword",
    ["-p"] = "keyword",
    ["flock"] = "keyword",
    ["next"] = "keyword",
    ["socket"] = "keyword",
    ["package"] = "keyword",
    ["-r"] = "keyword",
    ["fork"] = "keyword",
    ["not"] = "keyword",
    ["socketpair"] = "keyword",
    ["-R"] = "keyword",
    ["format"] = "keyword",
    ["oct"] = "keyword",
    ["sort"] = "keyword",
    ["-S"] = "keyword",
    ["formline"] = "keyword",
    ["open"] = "keyword",
    ["splice"] = "keyword",
    ["-s"] = "keyword",
    ["getc"] = "keyword",
    ["opendir"] = "keyword",
    ["split"] = "keyword",
    ["-T"] = "keyword",
    ["getgrent"] = "keyword",
    ["ord"] = "keyword",
    ["sprintf"] = "keyword",
    ["-t"] = "keyword",
    ["getgrgid"] = "keyword",
    ["our"] = "keyword",
    ["sqrt"] = "keyword",
    ["-u"] = "keyword",
    ["getgrnam"] = "keyword",
    ["pack"] = "keyword",
    ["srand"] = "keyword",
    ["-w"] = "keyword",
    ["gethostbyaddr"] = "keyword",
    ["pipe"] = "keyword",
    ["stat"] = "keyword",
    ["-W"] = "keyword",
    ["gethostbyname"] = "keyword",
    ["pop"] = "keyword",
    ["state"] = "keyword",
    ["-X"] = "keyword",
    ["gethostent"] = "keyword",
    ["pos"] = "keyword",
    ["study"] = "keyword",
    ["-x"] = "keyword",
    ["getlogin"] = "keyword",
    ["print"] = "keyword",
    ["substr"] = "keyword",
    ["-z"] = "keyword",
    ["getnetbyaddr"] = "keyword",
    ["printf"] = "keyword",
    ["symlink"] = "keyword",
    ["abs"] = "keyword",
    ["getnetbyname"] = "keyword",
    ["prototype"] = "keyword",
    ["syscall"] = "keyword",
    ["accept"] = "keyword",
    ["getnetent"] = "keyword",
    ["push"] = "keyword",
    ["sysopen"] = "keyword",
    ["alarm"] = "keyword",
    ["getpeername"] = "keyword",
    ["quotemeta"] = "keyword",
    ["sysread"] = "keyword",
    ["atan2"] = "keyword",
    ["getpgrp"] = "keyword",
    ["rand"] = "keyword",
    ["sysseek"] = "keyword",
    ["AUTOLOAD"] = "keyword",
    ["getppid"] = "keyword",
    ["read"] = "keyword",
    ["system"] = "keyword",
    ["BEGIN"] = "keyword",
    ["getpriority"] = "keyword",
    ["readdir"] = "keyword",
    ["syswrite"] = "keyword",
    ["bind"] = "keyword",
    ["getprotobyname"] = "keyword",
    ["readline"] = "keyword",
    ["tell"] = "keyword",
    ["binmode"] = "keyword",
    ["getprotobynumber"] = "keyword",
    ["SUPER"] = "keyword",
    ["readlink"] = "keyword",
    ["telldir"] = "keyword",
    ["bless"] = "keyword",
    ["sub"] = "keyword",
    ["getprotoent"] = "keyword",
    ["readpipe"] = "keyword",
    ["tie"] = "keyword",
    ["getpwent"] = "keyword",
    ["recv"] = "keyword",
    ["tied"] = "keyword",
    ["caller"] = "keyword",
    ["getpwnam"] = "keyword",
    ["redo"] = "keyword",
    ["time"] = "keyword",
    ["chdir"] = "keyword",
    ["getpwuid"] = "keyword",
    ["ref"] = "keyword",
    ["times"] = "keyword",
    ["CHECK"] = "keyword",
    ["getservbyname"] = "keyword",
    ["rename"] = "keyword",
    ["truncate"] = "keyword",
    ["chmod"] = "keyword",
    ["getservbyport"] = "keyword",
    ["require"] = "keyword",
    ["uc"] = "keyword",
    ["chomp"] = "keyword",
    ["getservent"] = "keyword",
    ["reset"] = "keyword",
    ["ucfirst"] = "keyword",
    ["chop"] = "keyword",
    ["getsockname"] = "keyword",
    ["return"] = "keyword",
    ["umask"] = "keyword",
    ["chown"] = "keyword",
    ["getsockopt"] = "keyword",
    ["reverse"] = "keyword",
    ["undef"] = "keyword",
    ["chr"] = "keyword",
    ["glob"] = "keyword",
    ["rewinddir"] = "keyword",
    ["UNITCHECK"] = "keyword",
    ["chroot"] = "keyword",
    ["gmtime"] = "keyword",
    ["rindex"] = "keyword",
    ["unlink"] = "keyword",
    ["close"] = "keyword",
    ["goto"] = "keyword",
    ["rmdir"] = "keyword",
    ["unpack"] = "keyword",
    ["closedir"] = "keyword",
    ["grep"] = "keyword",
    ["say"] = "keyword",
    ["unshift"] = "keyword",
    ["connect"] = "keyword",
    ["hex"] = "keyword",
    ["scalar"] = "keyword",
    ["untie"] = "keyword",
    ["cos"] = "keyword",
    ["index"] = "keyword",
    ["seek"] = "keyword",
    ["use"] = "keyword",
    ["crypt"] = "keyword",
    ["INIT"] = "keyword",
    ["seekdir"] = "keyword",
    ["utime"] = "keyword",
    ["dbmclose"] = "keyword",
    ["int"] = "keyword",
    ["select"] = "keyword",
    ["values"] = "keyword",
    ["dbmopen"] = "keyword",
    ["ioctl"] = "keyword",
    ["semctl"] = "keyword",
    ["vec"] = "keyword",
    ["defined"] = "keyword",
    ["join"] = "keyword",
    ["semget"] = "keyword",
    ["wait"] = "keyword",
    ["delete"] = "keyword",
    ["keys"] = "keyword",
    ["semop"] = "keyword",
    ["waitpid"] = "keyword",
    ["DESTROY"] = "keyword",
    ["kill"] = "keyword",
    ["send"] = "keyword",
    ["wantarray"] = "keyword",
    ["die"] = "keyword",
    ["last"] = "keyword",
    ["setgrent"] = "keyword",
    ["warn"] = "keyword",
    ["dump"] = "keyword",
    ["lc"] = "keyword",
    ["sethostent"] = "keyword",
    ["write"] = "keyword",
    ["each"] = "keyword",
    ["lcfirst"] = "keyword",
    ["setnetent"] = "keyword",
    ["while"] = "keyword",
    ["for"] = "keyword",
    ["if"] = "keyword",
    ["else"] = "keyword",
    ["elsif"] = "keyword",
    ["unless"] = "keyword",
    ["no"] = "keyword",
    ["new"] = "keyword",
    ["do"] = "keyword",
    ["__PACKAGE__"] = "keyword",
    ["warnings"] = "keyword2",
    ["strict"] = "keyword2",
    ["eq"] = "operator",
    ["ne"] = "operator",
    ["lt"] = "operator",
    ["gt"] = "operator",
    ["le"] = "operator",
    ["ge"] = "operator",
    ["cmp"] = "operator",
    ["STDERR"] = "keyword2",
    ["STDOUT"] = "keyword2",
    ["qq"] = "keyword",
    ["q"] = "keyword",
    ["qr"] = "keyword",
    ["qx"] = "keyword",
    ["qw"] = "keyword"
  }
}
