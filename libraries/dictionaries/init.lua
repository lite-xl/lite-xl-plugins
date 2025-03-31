
local core = require "core"

local dict = {languages = {}}

local ok, t


-- English
-- Source: https://github.com/fordsfords/moby_words_2/blob/main/crosswd.txt
-- Source 2: https://www.freelang.com/download/misc/liste_francais.zip
ok, t = pcall(require, "libraries.dictionaries.words-EN")
if ok then
	dict["EN"] = t
	table.insert(dict.languages, "EN")
	core.log("[Dictionaries]: Successfully loaded the English dictionary")
else
	core.error("[Dictionaries]: Failed to load the English dictionary")
end

-- French
-- Source: https://github.com/Taknok/French-Wordlist/blob/master/francais.txt
ok, t = pcall(require, "libraries.dictionaries.words-FR")
if ok then
	dict["FR"] = t
	table.insert(dict.languages, "FR")
	core.log("[Dictionaries]: Successfully loaded the English dictionary")
else
	core.error("[Dictionaries]: Failed to load the English dictionary")
end

return dict
