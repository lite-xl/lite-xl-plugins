-- mod-version:3

local syntax = require "core.syntax"

syntax.add {
  name = "fstab",
  files = { "fstab" },
  comment = '#',
  patterns = {
    -- Only lines that start with a # are comments; you can have #'s in fuse
    -- filesystem strings that aren't comments, so shouldn't be highlighted as such.
    { regex   = "^#.*$",                    type = "comment" },
    { pattern = "[=/:.,]+",                 type = "operator" },
    { pattern = "/.*/",                     type = "string"  },
    { pattern = "#",                        type = "operator" },
    -- {
    --   pattern = "%g+%s+()%g+%s+()%g+%s+()%g+%s+()[01]%s+()[012]%s*",
    --   type = {
    --     -- filesystem
    --     "keyword",
    --     -- mount point
    --     "keyword2",
    --     -- fs type
    --     "symbol",
    --     -- options
    --     "keyword2",
    --     -- dump frequency
    --     "keyword",
    --     -- pass number
    --     "keyword2",
    --   }
    -- },

    -- UUID
    { pattern = "%w-%-%w-%-%w-%-%w-%-%w- ",   type = "string" },
    -- IPv4 Address
    { pattern = "%d+%.%d+%.%d+%.%d+",         type = "string" },

    { pattern = " %d+ ",                      type = "number" },
    { pattern = "[%w_]+",                     type = "symbol" },

  },
  symbols = {
    ["none"] = "literal",

    ["LABEL"] = "keyword",
    ["UUID"] = "keyword",

    -- filesystems
    ["aufs"] = "keyword2",
    ["autofs"] = "keyword2",
    ["bdev"] = "keyword2",
    ["binder"] = "keyword2",
    ["binfmt_misc"] = "keyword2",
    ["bpf"] = "keyword2",
    ["btrfs"] = "keyword2",
    ["cgroup"] = "keyword2",
    ["cgroup2"] = "keyword2",
    ["configfs"] = "keyword2",
    ["cpuset"] = "keyword2",
    ["debugfs"] = "keyword2",
    ["devpts"] = "keyword2",
    ["devtmpfs"] = "keyword2",
    ["ecryptfs"] = "keyword2",
    ["ext2"] = "keyword2",
    ["ext3"] = "keyword2",
    ["ext4"] = "keyword2",
    ["fuse"] = "keyword2",
    ["fuseblk"] = "keyword2",
    ["fusectl"] = "keyword2",
    ["hfs"] = "keyword2",
    ["hfsplus"] = "keyword2",
    ["hugetlbfs"] = "keyword2",
    ["jfs"] = "keyword2",
    ["minix"] = "keyword2",
    ["mqueue"] = "keyword2",
    ["msdos"] = "keyword2",
    ["nfs"] = "keyword2",
    ["nfs4"] = "keyword2",
    ["nfsd"] = "keyword2",
    ["ntfs"] = "keyword2",
    ["pipefs"] = "keyword2",
    ["proc"] = "keyword2",
    ["pstore"] = "keyword2",
    ["qnx4"] = "keyword2",
    ["ramfs"] = "keyword2",
    ["rpc_pipefs"] = "keyword2",
    ["securityfs"] = "keyword2",
    ["sockfs"] = "keyword2",
    ["squashfs"] = "keyword2",
    ["swap"] = "keyword2",
    ["sysfs"] = "keyword2",
    ["tmpfs"] = "keyword2",
    ["tracefs"] = "keyword2",
    ["ufs"] = "keyword2",
    ["vfat"] = "keyword2",
    ["xfs"] = "keyword2",
  },
}
