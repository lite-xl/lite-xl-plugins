-- mod-version:3
local syntax = require "core.syntax"

local keywords = {
  "AcceptFilter", "AcceptMutex", "AcceptPathInfo", "AccessFileName", "Action", "AddAlt",
  "AddAltByEncoding", "AddAltByType", "AddCharset", "AddDefaultCharset", "AddDescription",
  "AddEncoding", "AddHandler", "AddIcon", "AddIconByType", "AddIconByEncoding", "AddIconByEncoding",
  "AddIconByType", "AddInputFilter", "AddLanguage", "AddModuleInfo", "AddOutputFilterByType",
  "AddOutputFilter", "AddOutputFilterByType", "AddType", "Alias", "ScriptAlias", "ServerAlias",
  "AliasMatch", "Allow", "AllowOverride", "AllowEncodedSlashes", "_ROUTING__allow_GET",
  "_ROUTING__allow_HEAD", "_ROUTING__allow_POST", "Allow", "AllowOverride", "AllowEncodedSlashes",
  "AllowCONNECT", "AllowEncodedSlashes", "AllowMethods", "AllowOverride", "AllowOverrideList",
  "Anonymous", "Anonymous_LogEmail", "Anonymous_NoUserID", "Anonymous_Authoritative",
  "Anonymous_LogEmail", "Anonymous_MustGiveEmail", "Anonymous_NoUserId", "Anonymous_VerifyEmail",
  "AssignUserID", "AsyncRequestWorkerFactor", "AuthAuthoritative", "AuthBasicAuthoritative",
  "AuthBasicFake", "AuthBasicProvider", "AuthBasicUseDigestAlgorithm", "AuthDBDUserPWQuery",
  "AuthDBDUserRealmQuery", "AuthDBMAuthoritative", "AuthDBMGroupFile", "AuthDBMType",
  "AuthDBMUserFile", "AuthDefaultAuthoritative", "AuthDigestAlgorithm", "AuthDigestDomain",
  "AuthDigestFile", "AuthDigestGroupFile", "AuthDigestNcCheck", "AuthDigestNonceFormat",
  "AuthDigestNonceLifetime", "AuthDigestProvider", "AuthDigestQop", "AuthDigestShmemSize",
  "AuthFormAuthoritative", "AuthFormBody", "AuthFormDisableNoStore", "AuthFormFakeBasicAuth",
  "AuthFormLocation", "AuthFormLoginRequiredLocation", "AuthFormLoginSuccessLocation",
  "AuthFormLogoutLocation", "AuthFormMethod", "AuthFormMimetype", "AuthFormPassword",
  "AuthFormProvider", "AuthFormSitePassphrase", "AuthFormSize", "AuthFormUsername", "AuthGroupFile",
  "AuthLDAPAuthoritative", "AuthLDAPAuthorizePrefix", "AuthLDAPAuthzEnabled",
  "AuthLDAPBindAuthoritative", "AuthLDAPBindDN", "AuthLDAPBindPassword", "AuthLDAPCharsetConfig",
  "AuthLDAPCompareAsUser", "AuthLDAPCompareDNOnServer", "AuthLDAPDereferenceAliases",
  "AuthLDAPEnabled", "AuthLDAPFrontPageHack", "AuthLDAPGroupAttribute", "AuthLDAPGroupAttributeIsDN",
  "AuthLDAPGroupAttributeIsDN", "AuthLDAPInitialBindAsUser", "AuthLDAPInitialBindPattern",
  "AuthLDAPMaxSubGroupDepth", "AuthLDAPRemoteUserAttribute", "AuthLDAPRemoteUserIsDN",
  "AuthLDAPSearchAsUser", "AuthLDAPSubGroupAttribute", "AuthLDAPSubGroupClass", "AuthLDAPURL",
  "AuthMerging", "AuthName", "AuthnCacheContext", "AuthnCacheEnable", "AuthnCacheProvideFor",
  "AuthnCacheProvider", "AuthnCacheSOCache", "AuthnCacheTimeout", "AuthnzFcgiCheckAuthnProvider",
  "AuthnzFcgiDefineProvider", "AuthType", "AuthUserFile", "AuthzDBDLoginToReferer", "AuthzDBDQuery",
  "AuthzDBDRedirectQuery", "AuthzDBMAuthoritative", "AuthzDBMType", "AuthzDefaultAuthoritative",
  "AuthzGroupFileAuthoritative", "AuthzLDAPAuthoritative", "AuthzOwnerAuthoritative",
  "AuthzSendForbiddenOnFailure", "AuthzUserAuthoritative", "BalancerGrowth", "BalancerInherit",
  "BalancerMember", "BalancerNonce", "BalancerPersist", "BrowserMatch", "BrowserMatchNoCase",
  "BrowserMatchNoCase", "BS2000Account", "BufferedLogs", "DeflateBufferSize", "BufferSize",
  "CacheDefaultExpire", "CacheDetailHeader", "CacheDirLength", "CacheDirLevels", "CacheDisable",
  "CacheEnable", "CacheExpiryCheck", "cachefile", "CacheForceCompletion", "CacheGcClean",
  "CacheGcDaily", "CacheGcInterval", "CacheGcMemUsage", "CacheGcUnused", "CacheHeader",
  "CacheIgnoreCacheControl", "CacheIgnoreHeaders", "CacheIgnoreNoLastMod", "CacheIgnoreQueryString",
  "CacheIgnoreURLSessionIdentifiers", "CacheKeyBaseURL", "CacheLastModifiedFactor", "CacheLock",
  "CacheLockMaxAge", "CacheLockPath", "CacheMaxExpire", "CacheMaxFileSize", "CacheMinExpire",
  "CacheMinFileSize", "CacheNegotiatedDocs", "CacheQuickHandler", "CacheReadSize", "CacheReadTime",
  "CacheRoot", "MCacheSize", "CacheSocache", "CacheSocacheMaxSize", "CacheSocacheMaxTime",
  "CacheSocacheMinTime", "CacheSocacheReadSize", "CacheSocacheReadTime", "CacheStaleOnError",
  "CacheStoreExpired", "CacheStoreNoStore", "CacheStorePrivate", "CacheTimeMargin", "CaseFilter",
  "CaseFilterIn", "CGIDScriptTimeout", "CGIMapExtension", "CGIPassAuth", "CGIVar", "CharsetDefault",
  "CharsetOptions", "CharsetSourceEnc", "CheckCaseOnly", "CheckSpelling", "ChildperUserID", "ChrootDir",
  "ClientRecheckTime", "ContentDigest", "CookieDomain", "CookieExpires", "CookieLog", "CookieName",
  "CookieStyle", "CookieTracking", "CoreDumpDirectory", "CustomLog", "DAV", "DAVDepthInfinity",
  "DAVGenericLockDB", "DAVLockDB", "DAVMinTimeout", "DBDExptime", "DBDInitSQL", "DBDKeep", "DBDMax",
  "DBDMin", "DBDParams", "DBDPersist", "DBDPrepareSQL", "DBDriver", "DefaultIcon", "DefaultLanguage",
  "DefaultRuntimeDir", "DefaultType", "Define", "DeflateBufferSize", "DeflateCompressionLevel",
  "DeflateFilterNote", "DeflateInflateLimitRequestBody", "DeflateInflateRatioBurst",
  "DeflateInflateRatioLimit", "DeflateMemLevel", "DeflateWindowSize", "Deny", "Deny", "DirectoryIndex",
  "DirectorySlash", "DirectoryCheckHandler", "DirectoryIndex", "DirectoryIndexRedirect", "DirectoryMatch",
  "DirectorySlash", "VirtualDocumentRoot", "DocumentRoot", "DTracePrivileges", "DumpIOInput",
  "DumpIOLogLevel", "DumpIOOutput", "EnableExceptionHook", "EnableMMAP", "EnableSendfile", "ErrorDocument",
  "ErrorLog", "ErrorLogFormat", "ExpiresActive", "ExpiresByType", "ExpiresDefault", "ExtendedStatus",
  "ExtFilterDefine", "ExtFilterOptions", "FallbackResource", "FancyIndexing", "FileETag", "Files",
  "FilesMatch", "FilterChain", "FilterDeclare", "FilterProtocol", "FilterProvider", "FilterTrace",
  "ForceLanguagePriority", "ForceType", "ForensicLog", "GlobalLog", "GprofDir", "AuthGroupFile", "Group",
  "AuthDBMGroupFile", "AuthLDAPGroupAttribute", "AuthLDAPGroupAttributeIsDN", "AuthzGroupFileAuthoritative",
  "H2AltSvc", "H2AltSvcMaxAge", "H2Direct", "H2MaxSessionStreams", "H2MaxWorkerIdleSeconds", "H2MaxWorkers",
  "H2MinWorkers", "H2ModernTLSOnly", "H2Push", "H2PushDiarySize", "H2PushPriority", "H2SerializeHeaders",
  "H2SessionExtraFiles", "H2StreamMaxMemSize", "H2TLSCoolDownSecs", "H2TLSWarmUpSize", "H2Upgrade",
  "H2WindowSize", "Header", "RequestHeader", "HeaderName", "HeaderName", "HeartbeatAddress",
  "HeartbeatListen", "HeartbeatMaxServers", "HeartbeatStorage", "HostnameLookups", "IdentityCheck",
  "IdentityCheckTimeout", "IfDefine", "IfModule", "IfVersion", "ImapBase", "ImapDefault", "ImapMenu",
  "Include", "IncludeOptional", "IndexHeadInsert", "IndexIgnore", "IndexIgnoreReset", "IndexOptions",
  "IndexOrderDefault", "IndexStyleSheet", "InputSed", "ISAPIAppendLogToErrors", "ISAPIAppendLogToQuery",
  "ISAPICacheFile", "ISAPIFakeAsync", "ISAPILogNotSupported", "ISAPIReadAheadBuffer", "KeepAlive",
  "KeepAliveTimeout", "MaxKeepAliveRequests", "KeepAliveTimeout", "KeptBodySize", "LanguagePriority",
  "ForceLanguagePriority", "LDAPCacheEntries", "LDAPCacheTTL", "LDAPConnectionPoolTTL",
  "LDAPConnectionTimeout", "LDAPLibraryDebug", "LDAPOpCacheEntries", "LDAPOpCacheTTL", "LDAPReferralHopLimit",
  "LDAPReferrals", "LDAPRetries", "LDAPRetryDelay", "LDAPSharedCacheFile", "LDAPSharedCacheSize",
  "LDAPTimeout", "LDAPTrustedCA", "LDAPTrustedCAType", "LDAPTrustedClientCert", "LDAPTrustedGlobalCert",
  "LDAPTrustedMode", "LDAPVerifyServerCert", "LimitRequestBody", "RLimitMEM", "LimitRequestFields",
  "LimitRequestFieldSize", "LimitRequestLine", "LimitExcept", "LimitInternalRecursion", "LimitRequestBody",
  "LimitRequestFields", "LimitRequestFieldsize", "LimitRequestLine", "LimitXMLRequestBody", "LoadFile",
  "LoadModule", "Location", "LocationMatch", "LockFile", "LogFormat", "LogIOTrackTTFB", "RewriteLogLevel",
  "LogLevel", "LogMessage", "LuaAuthzProvider", "Lua_____ByteCodeHack", "LuaCodeCache", "LuaHookAccessChecker",
  "LuaHookAuthChecker", "LuaHookCheckUserID", "LuaHookFixups", "LuaHookInsertFilter", "LuaHookLog",
  "LuaHookMapToStorage", "LuaHookTranslateName", "LuaHookTypeChecker", "LuaInherit", "LuaInputFilter",
  "LuaMapHandler", "LuaOutputFilter", "LuaPackageCPath", "LuaPackagePath", "LuaQuickHandler", "LuaRoot",
  "LuaScope", "MaxClientConnections", "MaxClients", "MaxConnectionsPerChild", "MaxKeepAliveRequests",
  "MaxMemFree", "MaxRangeOverlaps", "MaxRangeReversals", "MaxRanges", "MaxRequestsPerChild",
  "MaxRequestsPerThread", "MaxRequestWorkers", "MaxSpareServers", "MaxSpareThreads", "MaxThreads",
  "MaxThreadsPerChild", "MCacheMaxObjectCount", "MCacheMaxObjectSize", "MCacheMaxStreamingBuffer",
  "MCacheMinObjectSize", "MCacheRemovalAlgorithm", "MCacheSize", "MemcacheConnTTL", "MergeTrailers",
  "MetaDir", "MetaFiles", "MetaSuffix", "MimeMagicFile", "MinSpareServers", "MinSpareThreads", "mmapfile",
  "ModemStandard", "ModMimeUsePathInfo", "MultiviewsMatch", "Mutex", "NameVirtualHost", "NoProxy",
  "NumServers", "NWSSLTrustedCerts", "NWSSLUpgradeable", "Options", "RewriteOptions", "IndexOptions",
  "Order", "IndexOrderDefault", "Order", "IndexOrderDefault", "OutputSed", "PassEnv", "php_admin_flag",
  "php_admin_value", "php_flag", "php_value", "PidFile", "Port", "PrivilegesMode", "FilterProtocol",
  "Protocol", "ProtocolEcho", "Protocols", "ProtocolsHonorOrder", "ProxyPass", "ProxyPassMatch",
  "ProxyPassReverse", "ProxyRequests", "ProxyAddHeaders", "ProxyBadHeader", "ProxyBlock", "ProxyDomain",
  "ProxyErrorOverride", "ProxyExpressDBMFile", "ProxyExpressDBMType", "ProxyExpressEnable",
  "ProxyFtpDirCharset", "ProxyFtpEscapeWildcards", "ProxyFtpListOnWildcard", "ProxyHCExpr", "ProxyHCTemplate",
  "ProxyHCTPsize", "ProxyHTMLBufSize", "ProxyHTMLCharsetOut", "ProxyHTMLDoctype", "ProxyHTMLEnable",
  "ProxyHTMLEvents", "ProxyHTMLExtended", "ProxyHTMLFixups", "ProxyHTMLInterp", "ProxyHTMLLinks",
  "ProxyHTMLMeta", "ProxyHTMLStripComments", "ProxyHTMLURLMap", "ProxyIOBufferSize", "ProxyMatch",
  "ProxyMaxForwards", "ProxyPass", "ProxyPassMatch", "ProxyPassReverse", "ProxyPassInherit",
  "ProxyPassInterpolateEnv", "ProxyPassMatch", "ProxyPassReverse", "ProxyPassReverseCookieDomain",
  "ProxyPassReverseCookiePath", "ProxyPreserveHost", "ProxyReceiveBufferSize", "ProxyRemote",
  "ProxyRemoteMatch", "ProxyRequests", "ProxySCGIInternalRedirect", "ProxySCGISendfile", "ProxySet",
  "ProxySourceAddress", "ProxyStatus", "ProxyTimeout", "ProxyVia", "QualifyRedirectURL", "ReadmeName",
  "Redirect", "RedirectMatch", "RedirectTemp", "RedirectPermanent", "RedirectMatch", "RedirectPermanent",
  "RedirectTemp", "ReflectorHeader", "RemoteIPHeader", "RemoteIPInternalProxy", "RemoteIPInternalProxyList",
  "RemoteIPProxiesHeader", "RemoteIPTrustedProxy", "RemoteIPTrustedProxyList", "RemoveCharset",
  "RemoveEncoding", "RemoveHandler", "RemoveInputFilter", "RemoveLanguage", "RemoveOutputFilter", "RemoveType",
  "RequestHeader", "RequestReadTimeout", "RequestTimeout", "Require", "RewriteBase", "RewriteCond",
  "RewriteEngine", "RewriteLock", "RewriteLog", "RewriteLogLevel", "RewriteLogLevel", "RewriteMap",
  "RewriteOptions", "RewriteRule", "RLimitCPU", "RLimitMEM", "RLimitNPROC", "Satisfy", "ScoreboardFile",
  "ScoreBoardFile", "Script", "ScriptAlias", "ScriptAlias", "ScriptAliasMatch", "ScriptInterpreterSource",
  "ScriptLog", "ScriptLogBuffer", "ScriptLogLength", "Scriptsock", "ScriptSock", "SecureListen",
  "SeeRequestTail", "SerfCluster", "SerfPass", "ServerAdmin", "ServerAlias", "ServerLimit", "ServerName",
  "ServerPath", "ServerRoot", "ServerSignature", "ServerTokens", "Session", "SessionCookieName",
  "SessionCookieName2", "SessionCookieRemove", "SessionCryptoCipher", "SessionCryptoDriver",
  "SessionCryptoPassphrase", "SessionCryptoPassphraseFile", "SessionDBDCookieName", "SessionDBDCookieName2",
  "SessionDBDCookieRemove", "SessionDBDDeleteLabel", "SessionDBDInsertLabel", "SessionDBDPerUser",
  "SessionDBDSelectLabel", "SessionDBDUpdateLabel", "SessionEnv", "SessionExclude", "SessionHeader",
  "SessionInclude", "SessionMaxAge", "SetEnvIfNoCase", "SetEnv", "SetEnvIf", "SetEnvIfNoCase", "SetEnvIf",
  "SetEnvIfExpr", "SetEnvIfNoCase", "SetHandler", "SetInputFilter", "SetOutputFilter", "SimpleProcCount",
  "SimpleThreadCount", "SSIAccessEnable", "SSIEndTag", "SSIErrorMsg", "SSIEtag", "SSILastModified",
  "SSILegacyExprParser", "SSIStartTag", "SSITimeFormat", "SSIUndefinedEcho", "SSLLog", "SSLLogLevel",
  "StartServers", "StartThreads", "Substitute", "SubstituteInheritBefore", "SubstituteMaxLineLength",
  "Suexec", "SuexecUserGroup", "ThreadLimit", "ThreadsPerChild", "ThreadStackSize", "KeepAliveTimeout",
  "AuthnCacheTimeout", "TraceEnable", "TransferLog", "TrustedProxy", "TypesConfig", "UnDefine", "UnsetEnv",
  "UseCanonicalName", "UseCanonicalPhysicalPort", "User", "AuthUserFile", "UserDir", "AuthDBMUserFile",
  "Anonymous_NoUserID", "UserDir", "VHostCGIMode", "VHostCGIPrivs", "VHostGroup", "VHostPrivs", "VHostSecure",
  "VHostUser", "VirtualDocumentRoot", "VirtualDocumentRootIP", "VirtualHost", "VirtualScriptAlias",
  "VirtualScriptAliasIP", "Win32DisableAcceptEx", "XBitHack", "xml2EncAlias", "xml2EncDefault",
  "xml2StartParse", "SecFilterEngine", "from", "SSLOptions", "SSLRequireSSL", "SSLRequire"
}
local literals = {
  "on", "off", "deny", "denied", "all", "allow", "basic", "valid-user", "append", "unset", "set", "eq",
  "any", "email"
}

local symbols = {}
for _,lt in ipairs(literals) do
  symbols[lt] = "literal"
  symbols[lt:gsub("%f[%w]%l", string.upper)] = "literal"
end
for _,kw in ipairs(keywords) do
  symbols[kw] = "keyword"
end

local url_syntax = {
  patterns = {
    { pattern = "[%%$]%d+",           type = "keyword2" },
    { pattern = "[%%$]%{[%w_:%-]+%}", type = "keyword2" },
    { pattern = "[^%%$%s]",           type = "string" }
  },
  symbols = {}
}
local xml_syntax = {
  patterns = {{ pattern = { '"', '"', '\\' }, type = "string" }},
  symbols = {}
}

syntax.add {
  name = ".htaccess File",
  files = { "^%.htaccess$" },
  comment = "#",
  patterns = {
    -- Comments
    { pattern = "#.*\n",                        type = "comment"  },
    -- Strings
    { pattern = { '"', '"', '\\' },             type = "string"   },
    { pattern = { "'", "'", '\\' },             type = "string"   },
    { pattern = { '`', '`', '\\' },             type = "string"   },
    -- URLs
    { pattern = { "%w-://", "%f[%s]" },         type = "string", syntax = url_syntax },
    { pattern = { "%f[%S]/", "%f[%s]" },        type = "string", syntax = url_syntax },
    -- Mime types
    { pattern = "%f[%w]application/[%w%._+-]+", type = "keyword2" },
    { pattern = "%f[%w]font/[%w%._+-]+",        type = "keyword2" },
    { pattern = "%f[%w]image/[%w%._+-]+",       type = "keyword2" },
    { pattern = "%f[%w]text/[%w%._+-]+",        type = "keyword2" },
    { pattern = "%f[%w]audio/[%w%._+-]+",       type = "keyword2" },
    { pattern = "%f[%w]video/[%w%._+-]+",       type = "keyword2" },
    -- IPs
    { pattern = "%d+%.%d+%.%d+%.%d+",           type = "keyword2" },
    { pattern = "%d+%.%d+%.%d+%.%d+/%d+",       type = "keyword2" },
    { regex   = "([a-f0-9:]+:+)+[a-f0-9]+",     type = "keyword2" },
    -- Emails
    { pattern = "%w+@%w+%.%w+",                 type = "keyword2" },
    -- Rewrite option sections
    { pattern = "%f[%S]%b[]",                   type = "number" },
    -- XML tags
    { pattern = { "</?%w+", ">" },              type = "literal", syntax = xml_syntax },
    -- Variables
    { pattern = "[%%$]%d+",                     type = "keyword2" },
    { pattern = "[%%$]%{[%w_:%-]+%}",           type = "keyword2" },
    -- Numbers
    { pattern = "A?%d+",                        type = "number" },
    -- Operators
    { pattern = "%f[%S][!=+%-]+",               type = "operator" },
    -- Regex (TODO: improve this, it's pretty naive and only works on some regex)
    { pattern = "%f[^%s!]%^%S*",                type = "literal" },
    { pattern = "%f[^%s!]%S*%$",                type = "literal" },
    { pattern = "%f[^%s!]%b()",                 type = "literal" },
    -- Everything else
    { pattern = "[%a_][%w_-]*",                 type = "symbol"   },
  },
  symbols = symbols
}
