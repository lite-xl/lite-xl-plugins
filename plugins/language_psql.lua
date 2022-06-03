-- mod-version:3
local syntax = require "core.syntax"

-- In sql symbols can be lower case and upper case
local keywords = {
  "CREATE", "SELECT", "INSERT", "INTO", "UPDATE",
  "DELETE", "TABLE", "DROP", "VALUES", "NOT",
  "NULL", "PRIMARY", "KEY", "REFERENCES",
  "DEFAULT", "UNIQUE", "CONSTRAINT", "CHECK",
  "ON", "EXCLUDE", "WITH", "USING", "WHERE",
  "GROUP", "BY", "HAVING", "DISTINCT", "LIMIT",
  "OFFSET", "ONLY", "CROSS", "JOIN", "INNER",
  "LEFT", "RIGHT", "FULL", "OUTER", "NATURAL",
  "AND", "OR", "AS", "ORDER", "ORDINALITY",
  "UNNEST", "FROM", "VIEW", "RETURNS", "SETOF",
  "LANGUAGE", "SQL", "LIKE", "LATERAL",
  "INTERVAL", "PARTITION", "UNION", "INTERSECT",
  "EXCEPT", "ALL", "ASC", "DESC", "NULLS",
  "FIRST", "LAST", "IN", "RECURSIVE", "ARRAY",
  "RETURNING", "SET", "ALSO", "INSTEAD",
  "ALTER", "SEQUENCE", "OWNED", "AT", "ZONE",
  "WITHOUT", "TO", "TIMEZONE", "TYPE", "ENUM",
  "DOCUMENT", "XMLPARSE", "XMLSERIALIZE",
  "CONTENT", "OPTION", "INDEX", "ANY",
  "EXTENSION", "ISNULL", "NOTNULL", "UNKNOWN",
  "CASE", "THEN", "WHEN", "ELSE", "END",
  "ROWS", "BETWEEN", "UNBOUNDED", "PRECEDING",
  "UNBOUNDED", "FOLLOWING", "EXISTS", "SOME",
  "COLLATION", "FOR", "TRIGGER", "BEFORE",
  "EACH", "ROW", "EXECUTE", "PROCEDURE",
  "FUNCTION", "DECLARE", "BEGIN", "LOOP",
  "RAISE", "NOTICE", "LOOP", "EVENT",
  "OPERATOR", "DOMAIN", "VARIADIC", "FOREIGN"
}

local types = {
  "BIGINT", "INT8", "BIGSERIAL", "SERIAL8",
  "BIT", "VARBIT", "BOOLEAN", "BOOL", "BOX",
  "BYTEA", "CHARACTER", "CHAR", "VARCHAR",
  "CIDR", "CIRCLE", "DATE", "DOUBLE",
  "PRECISION", "FLOAT8", "INET", "INTEGER",
  "INT", "INT4", "INTERVAL", "JSON", "JSONB",
  "LINE", "LSEG", "MACADDR", "MONEY", "NUMERIC",
  "DECIMAL", "PATH", "POINT", "POLYGON", "REAL",
  "FLOAT4", "INT2", "SMALLINT", "SMALLSERIAL",
  "SERIAL2", "SERIAL", "SERIAL4", "TEXT",
  "TIME", "TIMEZ", "TIMESTAMP", "TIMESTAMPZ",
  "TSQUERY", "TSVECTOR", "TXID_SNAPSHOT",
  "UUID", "XML", "INT4RANGE", "INT8RANGE",
  "NUMRANGE", "TSRANGE", "TSTZRANGE",
  "DATERANGE", "PG_LSN"
}

local literals = {
  "FALSE", "TRUE", "CURRENT_TIMESTAMP",
  "CURRENT_TIME", "CURRENT_DATE", "LOCALTIME",
  "LOCALTIMESTAMP"
}

local symbols = {}
for _, keyword in ipairs(keywords) do
  symbols[keyword:lower()] = "keyword"
  symbols[keyword] = "keyword"
end

for _, type in ipairs(types) do
  symbols[type:lower()] = "keyword2"
  symbols[type] = "keyword2"
end

for _, literal in ipairs(literals) do
  symbols[literal:lower()] = "literal"
  symbols[literal] = "literal"
end

syntax.add {
  name = "PostgreSQL",
  files = { "%.sql$", "%.psql$" },
  comment = "--",
  patterns = {
    { pattern = "%-%-.-\n",                type = "comment"  },
    { pattern = { "/%*", "%*/" },          type = "comment"  },
    { pattern = { "'", "'", '\\' },        type = "string"   },
    { pattern = "-?%d+[%d%.eE]*f?",        type = "number"   },
    { pattern = "-?%.?%d+f?",              type = "number"   },
    { pattern = "[%+%-=/%*%%<>!~|&@%?$#]", type = "operator" },
    { pattern = "[%a_][%w_]*%f[(]",        type = "function" },
    { pattern = "[%a_][%w_]*",             type = "symbol"   },
  },
  symbols = symbols,
}

