
local core = require "core"

local dict = {languages = {}}


-- English
-- Source: https://github.com/fordsfords/moby_words_2/blob/main/crosswd.txt
local ok, t = pcall(require, "libraries.dictionaries.words-EN")
if ok then
	dict["EN"] = t
	table.insert(dict.languages, "EN")
	core.log("[Dictionaries]: Successfully loaded the English dictionary")
else
	core.error("[Dictionaries]: Failed to load the English dictionary")
end

-- French
-- Source: https://github.com/Taknok/French-Wordlist/blob/master/francais.txt


return dict
